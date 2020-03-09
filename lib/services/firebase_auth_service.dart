import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final StorageReference _storageReference = FirebaseStorage.instance.ref();

  Stream<FirebaseUser> get onAuthStateChanged {
    return _firebaseAuth.onAuthStateChanged
        .where((user) => user.isEmailVerified);

  }

  Future<AuthResult> googleSignIn() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    try {
      GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<AuthResult> signInWithEmailAndPassword(
      String email, String password) async {
    return await _firebaseAuth
        .signInWithCredential(EmailAuthProvider.getCredential(
      email: email,
      password: password,
    ));
  }

  Future<AuthResult> createUserWithEmailAndPassword(
      String email, String password) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<FirebaseUser> currentUser() async {
    final FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<String> resetEmail(String email, BuildContext context) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email).then((_) {
      showSnackBar('Envoyer', context);
    });

    return 'sent';
  }

  Future<void> registerByProvider(FirebaseUser firebaseUser) async{

    await Firestore.instance
        .collection('users')
        .document(firebaseUser.uid)
        .setData({
      "id": firebaseUser.uid,
      'nom': firebaseUser.displayName,
      'imageUrl': firebaseUser.photoUrl,
      'email': firebaseUser.email,
      'password': '',
      'lastActivity': DateTime.now(),
      'provider': firebaseUser.providerId,
      'isLogin': false,
      'attended': [],
      'willAttend': [],
      'chat': [],
      'chatId': {}
    }, merge: true);


  }

  Future<String> register(String email, String password, String nom, File image,
      BuildContext context) async {
    //Si l'utilisateur est bien inconnu
    await _firebaseAuth
        .fetchSignInMethodsForEmail(email: email)
        .then((list) async {
      if (list.isEmpty) {
        //création du user
        await _firebaseAuth
            .createUserWithEmailAndPassword(email: email, password: password)
            .then((user) async {
          //création du path pour la photo profil
          String path = image.path.substring(image.path.lastIndexOf('/') + 1);

          StorageUploadTask uploadTask = _storageReference
              .child('imageProfile')
              .child(user.user.uid)
              .child("/$path")
              .putFile(image);
          //création de l'url pour la photo profil
          await uploadImage(uploadTask).then((url) async {
            //création du user dans la _db
            await Firestore.instance
                .collection('users')
                .document(user.user.uid)
                .setData({
              "id": user.user.uid,
              'nom': nom,
              'imageUrl': url,
              'email': email,
              'password': password,
              'lastActivity': DateTime.now(),
              'provider': user.user.providerId,
              'isLogin': false,
              'attended': [],
              'willAttend': [],
              'chat': [],
              'chatId': {}
            }, merge: true).then((_) async {
              //envoi de l'email de vérification
              await user.user.sendEmailVerification().then((_) {
                showSnackBar('un email de validation a été envoyé', context);
              }).catchError((e) {
                print(e);
                showSnackBar('Impossible d\'envoyer l\'e-mail', context);
              });
            });
          }).catchError((e) {
            print(e);
            showSnackBar('Impossible de joindre le serveur', context);
          });
        }).catchError((e) {
          print(e);
          showSnackBar('Impossible de joindre le serveur', context);
        });
      } else {
        showSnackBar('L\' email existe déjà', context);
      }
    }).catchError((e) {
      print(e);
    });

    return 'All done';
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

  Future<String> uploadImage(StorageUploadTask uploadTask) async {
    var url = await (await uploadTask.onComplete).ref.getDownloadURL();

    return url.toString();
  }
}
