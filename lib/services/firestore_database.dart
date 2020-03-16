import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:vanevents/models/event.dart';
import 'package:vanevents/models/formule.dart';
import 'package:vanevents/models/message.dart';
import 'package:vanevents/models/user.dart';
import 'package:vanevents/services/firestore_path.dart';
import 'package:vanevents/services/firestore_service.dart';

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

class FirestoreDatabase {
  FirestoreDatabase({@required this.uid}) : assert(uid != null);
  final String uid; //uid of user currently login

  final _service = FirestoreService.instance;
  final StorageReference _storageReference = FirebaseStorage.instance.ref();
  final Firestore _db = Firestore.instance;

  Firestore get db => _db;

  Future<void> setUser(User user) async => await _service.setData(
        path: FirestorePath.user(uid),
        data: user.toMap(),
      );

  Future<User> userFuture() async => await _service.documentFuture(
      path: FirestorePath.user(uid),
      builder: (data, documentId) => User.fromMap(data, documentId));

  Stream<User> userStream() => _service.documentStream(
        path: FirestorePath.user(uid),
        builder: (data, documentId) => User.fromMap(data, documentId),
      );

  Stream<List<Event>> eventsStream() => _service.collectionStream(
      path: FirestorePath.events(),
      builder: (data, documentId) => Event.fromMap(data, documentId));

  //afin d'obtenir tous les autres donc sauf moi
  Stream<List<User>> usersStream1() => _service.collectionStream(
      path: FirestorePath.users(),
      builder: (data, documentId) => User.fromMap(data, documentId),
      queryBuilder: (query) => query
          .where('id', isGreaterThan: uid)
          .where('chat', arrayContains: uid));

  Stream<List<User>> usersStream2() => _service.collectionStream(
      path: FirestorePath.users(),
      builder: (data, documentId) => User.fromMap(data, documentId),
      queryBuilder: (query) =>
          query.where('id', isLessThan: uid).where('chat', arrayContains: uid));

  Stream<Message> getLastChatMessage(String chatId) {
    return _db
        .collection('chats')
        .document(chatId)
        .collection('messages')
        .orderBy('date', descending: true)
        .limit(1)
        .snapshots()
        .map((doc) =>
            doc.documents.map((doc) => Message.fromMap(doc.data)).first);
  }

  Future<Message> getLastChatMessagesChatRoom(
      String chatId, DateTime lastTimestamp) async {
    return await _db
        .collection('chats')
        .document(chatId)
        .collection('messages')
        .where('date', isGreaterThan: Timestamp.fromDate(lastTimestamp))
        .orderBy('date', descending: true)
        .limit(1)
        .getDocuments()
        .then((doc) => doc.documents.map((doc) => Message.fromMap(doc.data)))
        .then((list) => list.isNotEmpty ? list.elementAt(0) : null);
  }

  Stream<List<Message>> getChatMessageNonLu(String chatId) {
    return _db
        .collection('chats')
        .document(chatId)
        .collection('messages')
        .where('state', isLessThan: 2)
        .where('idTo', isEqualTo: uid)
        .snapshots()
        .map((doc) => doc.documents.map((doc) => Message.fromMap(doc.data)));
  }

  Stream<Message> getChatMessageStream(String chatId, String id) {
    return _db
        .collection('chats')
        .document(chatId)
        .collection('messages')
        .where('id', isEqualTo: id)
        .snapshots()
        .map((doc) =>
            doc.documents.map((doc) => Message.fromMap(doc.data)).first);
  }

  Stream<List<Message>> getChatMessages(String chatId) {
    return _db
        .collection('chats')
        .document(chatId)
        .collection('messages')
        .orderBy('date', descending: true)
        .snapshots()
        .map((doc) =>
            doc.documents.map((doc) => Message.fromMap(doc.data)).toList());
  }

  Future<String> sendMessage(String chatId, String idSender, String text,
      String friendId, int type) async {
    String messageId = _db
        .collection('chats')
        .document(chatId)
        .collection('messages')
        .document()
        .documentID;

    await _db
        .collection('chats')
        .document(chatId)
        .collection('messages')
        .document(messageId)
        .setData({
      'id': messageId,
      'idFrom': idSender,
      'idTo': friendId,
      'message': text,
      'date': DateTime.now(),
      'type': type,
      'state': 0
    }).catchError((_) {
      //Fluttertoast.showToast(msg: 'Problème de connection');
    });

//    await _db.collection('chat').document(chatId).updateData({
//
//      'count' : FieldValue.increment(1),
//      'idUsers':[idSender,friendId],
//      'isRead' : false,
//
//      'messages': FieldValue.arrayUnion([
//        {
//          'userFrom': idSender,
//          'message': text,
//          'date': DateTime.now(),
//        }
//      ])
//    }).then((_){
//      //confirmation envoyé
//
//
//      return StatusMessage.send;
//
//    }).catchError((_){
//      return StatusMessage.error;
//    });
  }

  Future<User> getUserFirestore(String id) async {
    return await _db
        .collection('users')
        .document(id)
        .get()
        .then((doc) => User.fromMap(doc.data, id));
  }

  Future<String> creationChatRoom(String idFriend) async {
    DocumentReference myUserRef = _db.collection('users').document(uid);

    DocumentReference friendUserRef =
        _db.collection('users').document(idFriend);

    List<String> myChat = List<String>();

    //my id
    myChat = await myUserRef
        .get()
        .then((doc) => User.fromMap(doc.data, uid).chat)
        .then((list) => list.cast());

    String idChatRoom = '';

    if (myChat.contains(idFriend)) {
      //fetch idchat

      idChatRoom = await myUserRef.get().then(
          (doc) => User.fromMap(doc.data, uid).chatId[idFriend].toString());
    } else {
      //creation id chat
      //création d'un chatRoom
      DocumentReference chatRoom = _db.collection('chats').document();
      idChatRoom = chatRoom.documentID;
      await _db.collection('chats').document(idChatRoom).setData({
        'id': idChatRoom,
        'createdAt': DateTime.now(),
      });
      //Partage de l'ID chat room
      await myUserRef.updateData({
        'chat': FieldValue.arrayUnion([idFriend]),
        'chatId': FieldValue.arrayUnion([
          {idFriend: idChatRoom}
        ])
      });
      await friendUserRef.updateData({
        'chat': FieldValue.arrayUnion([uid]),
        'chatId': FieldValue.arrayUnion([
          {uid: idChatRoom}
        ])
      });
    }

//    sonChat = await friendUserRef
//        .get()
//        .then((doc) => User.fromMap(doc.data).chat)
//        .then((list) => list.cast());
//
//
//
//
//
//
//    if (sonChat != null && myChat != null) {
//      for (int j = 0; j < sonChat.length; j++) {
//        if (myChat.contains(sonChat[j])) {
//          idChatRoom = sonChat[j];
//          break;
//        }
//      }
//    }

    return idChatRoom;
  }

  void uploadImageChat(
      File image, String chatId, String idSender, String friendId) {
    String path = image.path.substring(image.path.lastIndexOf('/') + 1);

    StorageUploadTask uploadTask = _storageReference
        .child('chat')
        .child(chatId)
        .child("/$path")
        .putFile(image);

    uploadImage(uploadTask)
        .then((url) => sendMessage(chatId, idSender, url, friendId, 1))
        .catchError((err) {
      //Fluttertoast.showToast(msg: 'Ce n\'est pas une image');
    });
  }

  void uploadEvent(
      DateTime dateDebut,
      DateTime dateFin,
      String adresse,
      String titre,
      String description,
      File image,
      List<Formule> formules,
      BuildContext context) {
    //création du path pour le flyer
    String path = image.path.substring(image.path.lastIndexOf('/') + 1);

    StorageUploadTask uploadTask = _storageReference
        .child('imageFlyer')
        .child(dateDebut.toString())
        .child("/$path")
        .putFile(image);

    uploadImage(uploadTask).then((url) {
      DocumentReference reference = _db.collection("events").document();
      String idEvent = reference.documentID;

      _db.collection("events").document(idEvent).setData({
        "id": idEvent,
        "dateDebut": dateDebut,
        "dateFin": dateFin,
        "adresse": adresse,
        "titre": titre,
        "description": description,
        "imageUrl": url,
        "participants": [],
      }, merge: true).then((_) {
        formules.forEach((f) {
          DocumentReference reference = _db
              .collection("events")
              .document(idEvent)
              .collection("formules")
              .document();
          String idFormule = reference.documentID;

          _db
              .collection("events")
              .document(idEvent)
              .collection("formules")
              .document(idFormule)
              .setData({
            "id": idFormule,
            "prix": f.prix,
            "title": f.title,
            "nb": f.nombreDePersonne,
          }, merge: true);
        });
      }).then((_) {
        //création du chat room
        _db
            .collection("chats")
            .document(idEvent)
            .setData({'createdAt': DateTime.now(), 'id': idEvent}, merge: true);
      }).then((_) {
        showSnackBar("Event ajouter", context);
      }).catchError((e) {
        showSnackBar("impossible d'ajouter l'Event", context);
      });
    });
  }

  Future<String> uploadImage(StorageUploadTask uploadTask) async {
    var url = await (await uploadTask.onComplete).ref.getDownloadURL();

    return url.toString();
  }

  Future<void> updateUserDataFromProvider(
      FirebaseUser user, String password, String photoUrl) {
    DocumentReference documentReference = _db.collection('users').document(uid);

    documentReference.get().then((doc) {
      if (doc.exists) {
        documentReference.updateData({
          "id": user.uid,
          'nom': user.displayName,
          'imageUrl': photoUrl ?? user.photoUrl,
          'email': user.email,
          'password': password ?? '',
          'lastActivity': DateTime.now(),
          'provider': user.providerId,
          'isLogin': true,
        });
      } else {
        documentReference.setData({
          "id": user.uid,
          'nom': user.displayName,
          'imageUrl': photoUrl ?? user.photoUrl,
          'email': user.email,
          'password': password,
          'lastActivity': DateTime.now(),
          'provider': user.providerId,
          'isLogin': false,
          'attended': [],
          'willAttend': [],
          'chat': [],
          'chatId': {}
        }, merge: true);
      }
    });
  }

  void showSnackBar(String val, BuildContext context) {
    Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: Duration(seconds: 3),
        content: Text(
          val,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onError, fontSize: 16.0),
        )));
  }

  Future createUserOnDatabase(FirebaseUser user) async {
    await Firestore.instance
        .collection('users')
        .document(user.uid)
        .get()
        .then((doc) async {
      print(doc);
      if (!doc.exists) {
        await Firestore.instance
            .collection('users')
            .document(user.uid)
            .setData({
          "id": user.uid,
          'nom': user.displayName,
          'imageUrl': user.photoUrl,
          'email': user.email,
          'password': '',
          'lastActivity': DateTime.now(),
          'provider': user.providerId,
          'isLogin': false,
          'attended': [],
          'willAttend': [],
          'chat': [],
          'chatId': {}
        }, merge: true);
      }
    });
  }

  Stream<List<User>> participantsStream(String eventId) {
    return _db
        .collection('users')
        .where('events', arrayContains: eventId)
        .snapshots()
        .map((users) => users.documents
            .map((user) => User.fromMap(user.data, user.documentID))
            .toList());
  }

  void setMessageRead(String chatId, String id) {
    _db
        .collection('chats')
        .document(chatId)
        .collection('messages')
        .document(id)
        .setData({'state': 2}, merge: true);
  }
}
