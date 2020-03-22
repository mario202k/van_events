import 'package:auto_route/auto_route_annotations.dart';
import 'package:vanevents/auth_widget.dart';
import 'package:vanevents/screens/base_screen.dart';
import 'package:vanevents/screens/chat.dart';
import 'package:vanevents/screens/chat_room.dart';
import 'package:vanevents/screens/details.dart';
import 'package:vanevents/screens/formula_choice.dart';
import 'package:vanevents/screens/full_photo.dart';
import 'package:vanevents/screens/home_events.dart';
import 'package:vanevents/screens/login.dart';
import 'package:vanevents/screens/profile.dart';
import 'package:vanevents/screens/reset_password.dart';
import 'package:vanevents/screens/sign_up.dart';
import 'package:vanevents/screens/tickets.dart';
import 'package:vanevents/screens/upload_event.dart';

@MaterialAutoRouter()
class $Router {

  @initial
  AuthWidget authWidget;

  Login login;

  ResetPassword resetPassword;

  SignUp signUp;

  BaseScreens baseScreens;

  HomeEvents homeEvents;

  Chat chat;

  ChatRoom chatRoom;

  FullPhoto fullPhoto;

  Profile profile;

  Tickets tickets;

  UploadEvent uploadEvent;

  Details details;

  FormulaChoice formulaChoice;


}
