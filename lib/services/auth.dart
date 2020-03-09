//import 'dart:io';
//
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_storage/firebase_storage.dart';
//import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
////import 'package:flutter_facebook_login/flutter_facebook_login.dart';
//import 'package:google_sign_in/google_sign_in.dart';
//
//import '../models/models.dart';
//
//
//class AuthService{
//
//  final GoogleSignIn _googleSignIn = GoogleSignIn(
//    scopes: <String>[
//      'email',
//      'https://www.googleapis.com/auth/contacts.readonly',
//    ],
//  );
//
//
//  final FirebaseAuth _auth = FirebaseAuth.instance;
//  FirebaseAuth get auth => _auth;
//  final Firestore _db = Firestore.instance;
//  Firestore get db => _db;
//  Stream<FirebaseUser> get user => _auth.onAuthStateChanged;
//  Future<FirebaseUser> get getUser => _auth.currentUser();
//  final StorageReference _storageReference = FirebaseStorage.instance.ref();
//
//
//
//  Future<void> updateUserDataFromProvider(
//      FirebaseUser user, String password, String photoUrl) {
//    DocumentReference documentReference =
//    db.collection('users').document(user.uid);
//
//    documentReference.get().then((doc) {
//      if (doc.exists) {
//        documentReference.updateData({
//          "id": user.uid,
//          'nom': user.displayName,
//          'imageUrl': photoUrl ?? user.photoUrl,
//          'email': user.email,
//          'password': password ?? '',
//          'lastActivity': DateTime.now(),
//          'provider': user.providerId,
//          'isLogin': true,
//        });
//      } else {
//        documentReference.setData({
//          "id": user.uid,
//          'nom': user.displayName,
//          'imageUrl': photoUrl ?? user.photoUrl,
//          'email': user.email,
//          'password': password,
//          'lastActivity': DateTime.now(),
//          'provider': user.providerId,
//          'isLogin': false,
//          'attended': [],
//          'willAttend': [],
//          'chat': [],
//          'chatId': {}
//        }, merge: true);
//      }
//    });
//  }
//
//  Future<FirebaseUser> signIn(String email, String password) async {
//    FirebaseUser user = (await _auth.signInWithEmailAndPassword(
//        email: email, password: password))
//        .user;
//    db
//        .collection('users')
//        .document(user.uid)
//        .updateData({'lastActivity': DateTime.now()});
//
//    return user;
//  }
//
//
//  Future<void> signOut() {
//    return _auth.signOut();
//  }
//
//
//  Future<FirebaseUser> googleSignIn() async {
//    try {
//      GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
//      GoogleSignInAuthentication googleAuth =
//      await googleSignInAccount.authentication;
//
//      final AuthCredential credential = GoogleAuthProvider.getCredential(
//        accessToken: googleAuth.accessToken,
//        idToken: googleAuth.idToken,
//      );
//
//      FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
//      updateUserDataFromProvider(user, null, null);
//
//      return user;
//    } catch (error) {
//      print(error);
//      return null;
//    }
//  }
//
////  Future<FirebaseUser> faceBookSignIn() async {
////    try {
////      SystemChannels.textInput.invokeMethod('TextInput.hide');
////      FacebookLogin facebookLogin = new FacebookLogin();
////      FacebookLoginResult result = await facebookLogin
////          .logIn(['email', 'public_profile']);
////      switch (result.status) {
////        case FacebookLoginStatus.loggedIn:
////          AuthCredential credential = FacebookAuthProvider.getCredential(
////              accessToken: result.accessToken.token);
////          FirebaseUser user =
////              (await FirebaseAuth.instance.signInWithCredential(credential))
////                  .user;
////          updateUserDataFromProvider(user, null, null);
////          return user;
////        case FacebookLoginStatus.cancelledByUser:
////        case FacebookLoginStatus.error:
////        default:
////          return null;
////      }
////    } catch (e) {
////      print("Error in facebook sign in: $e");
////      return null;
////    }
////  }
//
//  Stream getChatMessages(String chatId) {
//    return db
//        .collection('chats')
//        .document(chatId)
//        .collection('messages')
//        .snapshots();
//  }
//
//  Future<String> sendMessage(String chatId, String idSender, String text,
//      String friendId, int type) async {
//    String messageId = db
//        .collection('chats')
//        .document(chatId)
//        .collection('messages')
//        .document()
//        .documentID;
//
//    await db
//        .collection('chats')
//        .document(chatId)
//        .collection('messages')
//        .document(messageId)
//        .setData({
//      'id': messageId,
//      'idFrom': idSender,
//      'idTo': friendId,
//      'message': text,
//      'date': DateTime.now(),
//      'type': type,
//      'state': 0
//    }).catchError((_) {
//
//
//
//      //Fluttertoast.showToast(msg: 'Problème de connection');
//    });
//
////    await db.collection('chat').document(chatId).updateData({
////
////      'count' : FieldValue.increment(1),
////      'idUsers':[idSender,friendId],
////      'isRead' : false,
////
////      'messages': FieldValue.arrayUnion([
////        {
////          'userFrom': idSender,
////          'message': text,
////          'date': DateTime.now(),
////        }
////      ])
////    }).then((_){
////      //confirmation envoyé
////
////
////      return StatusMessage.send;
////
////    }).catchError((_){
////      return StatusMessage.error;
////    });
//  }
//
//  Future<User> getUserFirestore(String id) {
//    return db
//        .collection('users')
//        .document(id)
//        .get()
//        .then((doc) => User.fromMap(doc.data));
//  }
//
//  Future<String> creationChatRoom(String myId, String idFriend) async {
//    DocumentReference myUserRef = db.collection('users').document(myId);
//
//    DocumentReference friendUserRef = db.collection('users').document(idFriend);
//
//    List<String> myChat = List<String>();
//
//    //my id
//    myChat = await myUserRef
//        .get()
//        .then((doc) => User.fromMap(doc.data).chat)
//        .then((list) => list.cast());
//
//    String idChatRoom = '';
//
//    if (myChat.contains(idFriend)) {
//      //fetch idchat
//
//      idChatRoom = await myUserRef
//          .get()
//          .then((doc) => User.fromDocSnap(doc).chatId[idFriend].toString());
//
//    } else {
//
//      //creation id chat
//      //création d'un chatRoom
//      DocumentReference chatRoom = db.collection('chats').document();
//      idChatRoom = chatRoom.documentID;
//      await db.collection('chats').document(idChatRoom).setData({
//        'id': idChatRoom,
//        'createdAt': DateTime.now(),
//      });
//      //Partage de l'ID chat room
//      await myUserRef.updateData({
//        'chat': FieldValue.arrayUnion([idFriend]),
//        'chatId': FieldValue.arrayUnion([
//          {idFriend: idChatRoom}
//        ])
//      });
//      await friendUserRef.updateData({
//        'chat': FieldValue.arrayUnion([myId]),
//        'chatId': FieldValue.arrayUnion([
//          {myId: idChatRoom}
//        ])
//      });
//    }
//
////    sonChat = await friendUserRef
////        .get()
////        .then((doc) => User.fromMap(doc.data).chat)
////        .then((list) => list.cast());
////
////
////
////
////
////
////    if (sonChat != null && myChat != null) {
////      for (int j = 0; j < sonChat.length; j++) {
////        if (myChat.contains(sonChat[j])) {
////          idChatRoom = sonChat[j];
////          break;
////        }
////      }
////    }
//
//    return idChatRoom;
//  }
//
//  void showSnackBar(String val, BuildContext context) {
//
//    Scaffold.of(context).showSnackBar(SnackBar(
//        backgroundColor: Theme.of(context).colorScheme.error,
//        duration: Duration(seconds: 3),
//        content: Text(
//          val,
//          textAlign: TextAlign.center,
//          style: TextStyle(color: Theme.of(context).colorScheme.onError, fontSize: 16.0),
//        )));
//  }
//
//  void uploadImageChat(
//      File image, String chatId, String idSender, String friendId) {
//    String path = image.path.substring(image.path.lastIndexOf('/') + 1);
//
//    StorageUploadTask uploadTask = _storageReference
//        .child('chat')
//        .child(chatId)
//        .child("/$path")
//        .putFile(image);
//
//    uploadImage(uploadTask)
//        .then((url) => sendMessage(chatId, idSender, url, friendId, 1))
//        .catchError((err) {
//      //Fluttertoast.showToast(msg: 'Ce n\'est pas une image');
//    });
//  }
//
//  void uploadEvent(
//      DateTime dateDebut,
//      DateTime dateFin,
//      String adresse,
//      String titre,
//      String description,
//      File image,
//      List<Formule> formules,
//      BuildContext context) {
//    //création du path pour le flyer
//    String path = image.path.substring(image.path.lastIndexOf('/') + 1);
//
//    StorageUploadTask uploadTask = _storageReference
//        .child('imageFlyer')
//        .child(dateDebut.toString())
//        .child("/$path")
//        .putFile(image);
//
//    uploadImage(uploadTask).then((url) {
//      DocumentReference reference = db.collection("events").document();
//      String idEvent = reference.documentID;
//
//      db.collection("events").document(idEvent).setData({
//        "id": idEvent,
//        "dateDebut": dateDebut,
//        "dateFin": dateFin,
//        "adresse": adresse,
//        "titre": titre,
//        "description": description,
//        "image": url,
//        "participants": [],
//      }, merge: true).then((_) {
//        formules.forEach((f) {
//          DocumentReference reference = db
//              .collection("events")
//              .document(idEvent)
//              .collection("formules")
//              .document();
//          String idFormule = reference.documentID;
//
//          db
//              .collection("events")
//              .document(idEvent)
//              .collection("formules")
//              .document(idFormule)
//              .setData({
//            "id": idFormule,
//            "prix": f.prix,
//            "title": f.title,
//            "nb": f.nombreDePersonne,
//          }, merge: true);
//        });
//      }).then((_) {
//        //création du chat room
//        db.collection("chat").document(idEvent).setData(
//            {'createdAt': DateTime.now(), 'count': 0, 'messages': []},
//            merge: true);
//      }).then((_) {
//        showSnackBar("Event ajouter", context);
//      }).catchError((e) {
//        showSnackBar("impossible d'ajouter l'Event", context);
//      });
//    });
//  }
//
//  Future<String> resetEmail(String email, BuildContext context)async{
//
//    await auth.sendPasswordResetEmail(email: email).then((_){
//      showSnackBar('Envoyer', context);
//    });
//
//    return 'sent';
//
//  }
//
//  Future<String> register(String email, String password, String nom, File image,
//      BuildContext context)async{
//
//
//    //Si l'utilisateur est bien inconnu
//    await auth.fetchSignInMethodsForEmail(email: email).then((list) async{
//      if (list.isEmpty) {
//        //création du user
//        await auth
//            .createUserWithEmailAndPassword(email: email, password: password)
//            .then((user) async {
//          //création du path pour la photo profil
//          String path = image.path.substring(image.path.lastIndexOf('/') + 1);
//
//          StorageUploadTask uploadTask = _storageReference
//              .child('imageProfile')
//              .child(user.user.uid)
//              .child("/$path")
//              .putFile(image);
//          //création de l'url pour la photo profil
//          await uploadImage(uploadTask).then((url) async {
//            //création du user dans la db
//            await db.collection('users').document(user.user.uid).setData({
//              "id": user.user.uid,
//              'nom': nom,
//              'imageUrl': url,
//              'email': email,
//              'password': password,
//              'lastActivity': DateTime.now(),
//              'provider': user.user.providerId,
//              'isLogin': false,
//              'attended': [],
//              'willAttend': [],
//              'chat': [],
//              'chatId': {}
//            }, merge: true).then((_) async{
//
//              //envoi de l'email de vérification
//              await user.user.sendEmailVerification().then((_) {
//
//                showSnackBar('un email de validation a été envoyé', context);
//
//
//              }).catchError((e) {
//                print(e);
//                showSnackBar('Impossible d\'envoyer l\'e-mail', context);
//
//              });
//            });
//          }).catchError((e) {
//            print(e);
//            showSnackBar('Impossible de joindre le serveur', context);
//
//          });
//        }).catchError((e) {
//          print(e);
//          showSnackBar('Impossible de joindre le serveur', context);
//
//        });
//      } else {
//        showSnackBar('L\' email existe déjà', context);
//
//
//      }
//    }).catchError((e) {
//      print(e);
//
//    });
//
//    return 'All done';
//
//  }
//
//  Future<String> uploadImage(StorageUploadTask uploadTask) async {
//    var url = await (await uploadTask.onComplete).ref.getDownloadURL();
//
//    return url.toString();
//  }
//
//
//
//}