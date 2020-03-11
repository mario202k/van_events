// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:auto_route/auto_route.dart';
import 'package:vanevents/auth_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vanevents/screens/login.dart';
import 'package:vanevents/screens/reset_password.dart';
import 'package:vanevents/screens/sign_up.dart';
import 'package:vanevents/screens/base_screen.dart';
import 'package:vanevents/screens/home_events.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:vanevents/screens/chat.dart';
import 'package:vanevents/screens/chat_room.dart';
import 'package:vanevents/screens/full_photo.dart';
import 'package:vanevents/screens/profile.dart';
import 'package:vanevents/screens/tickets.dart';
import 'package:vanevents/screens/upload_event.dart';
import 'package:vanevents/screens/details.dart';
import 'package:vanevents/models/event.dart';

class Router {
  static const authWidget = '/';
  static const login = '/login';
  static const resetPassword = '/reset-password';
  static const signUp = '/sign-up';
  static const baseScreens = '/base-screens';
  static const homeEvents = '/home-events';
  static const chat = '/chat';
  static const chatRoom = '/chat-room';
  static const fullPhoto = '/full-photo';
  static const profile = '/profile';
  static const tickets = '/tickets';
  static const uploadEvent = '/upload-event';
  static const details = '/details';
  static final navigator = ExtendedNavigator();
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case Router.authWidget:
        if (hasInvalidArgs<AuthWidgetArguments>(args, isRequired: true)) {
          return misTypedArgsRoute<AuthWidgetArguments>(args);
        }
        final typedArgs = args as AuthWidgetArguments;
        return MaterialPageRoute<dynamic>(
          builder: (_) => AuthWidget(
              key: typedArgs.key,
              userSnapshot: typedArgs.userSnapshot,
              seenOnboarding: typedArgs.seenOnboarding),
          settings: settings,
        );
      case Router.login:
        return MaterialPageRoute<dynamic>(
          builder: (_) => Login(),
          settings: settings,
        );
      case Router.resetPassword:
        return MaterialPageRoute<dynamic>(
          builder: (_) => ResetPassword(),
          settings: settings,
        );
      case Router.signUp:
        return MaterialPageRoute<dynamic>(
          builder: (_) => SignUp(),
          settings: settings,
        );
      case Router.baseScreens:
        if (hasInvalidArgs<String>(args)) {
          return misTypedArgsRoute<String>(args);
        }
        final typedArgs = args as String;
        return MaterialPageRoute<dynamic>(
          builder: (_) => BaseScreens(typedArgs),
          settings: settings,
        );
      case Router.homeEvents:
        if (hasInvalidArgs<GlobalKey<InnerDrawerState>>(args)) {
          return misTypedArgsRoute<GlobalKey<InnerDrawerState>>(args);
        }
        final typedArgs = args as GlobalKey<InnerDrawerState>;
        return MaterialPageRoute<dynamic>(
          builder: (_) => HomeEvents(typedArgs),
          settings: settings,
        );
      case Router.chat:
        if (hasInvalidArgs<GlobalKey<InnerDrawerState>>(args)) {
          return misTypedArgsRoute<GlobalKey<InnerDrawerState>>(args);
        }
        final typedArgs = args as GlobalKey<InnerDrawerState>;
        return MaterialPageRoute<dynamic>(
          builder: (_) => Chat(typedArgs),
          settings: settings,
        );
      case Router.chatRoom:
        if (hasInvalidArgs<ChatRoomArguments>(args)) {
          return misTypedArgsRoute<ChatRoomArguments>(args);
        }
        final typedArgs = args as ChatRoomArguments ?? ChatRoomArguments();
        return MaterialPageRoute<dynamic>(
          builder: (_) => ChatRoom(typedArgs.myId, typedArgs.nomFriend,
              typedArgs.imageFriend, typedArgs.chatId, typedArgs.friendId),
          settings: settings,
        );
      case Router.fullPhoto:
        if (hasInvalidArgs<FullPhotoArguments>(args, isRequired: true)) {
          return misTypedArgsRoute<FullPhotoArguments>(args);
        }
        final typedArgs = args as FullPhotoArguments;
        return MaterialPageRoute<dynamic>(
          builder: (_) => FullPhoto(key: typedArgs.key, url: typedArgs.url),
          settings: settings,
        );
      case Router.profile:
        return MaterialPageRoute<dynamic>(
          builder: (_) => Profile(),
          settings: settings,
        );
      case Router.tickets:
        return MaterialPageRoute<dynamic>(
          builder: (_) => Tickets(),
          settings: settings,
        );
      case Router.uploadEvent:
        return MaterialPageRoute<dynamic>(
          builder: (_) => UploadEvent(),
          settings: settings,
        );
      case Router.details:
        if (hasInvalidArgs<Event>(args)) {
          return misTypedArgsRoute<Event>(args);
        }
        final typedArgs = args as Event;
        return MaterialPageRoute<dynamic>(
          builder: (_) => Details(typedArgs),
          settings: settings,
        );
      default:
        return unknownRoutePage(settings.name);
    }
  }
}

//**************************************************************************
// Arguments holder classes
//***************************************************************************

//AuthWidget arguments holder class
class AuthWidgetArguments {
  final Key key;
  final AsyncSnapshot<FirebaseUser> userSnapshot;
  final bool seenOnboarding;
  AuthWidgetArguments(
      {this.key, @required this.userSnapshot, this.seenOnboarding});
}

//ChatRoom arguments holder class
class ChatRoomArguments {
  final String myId;
  final String nomFriend;
  final String imageFriend;
  final String chatId;
  final String friendId;
  ChatRoomArguments(
      {this.myId,
      this.nomFriend,
      this.imageFriend,
      this.chatId,
      this.friendId});
}

//FullPhoto arguments holder class
class FullPhotoArguments {
  final Key key;
  final String url;
  FullPhotoArguments({this.key, @required this.url});
}
