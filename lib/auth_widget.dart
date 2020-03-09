import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vanevents/screens/base_screen.dart';
import 'package:vanevents/screens/login.dart';
import 'package:vanevents/screens/walkthrough.dart';


/// Builds the signed-in or non signed-in UI, depending on the user snapshot.
/// This widget should be below the [MaterialApp].
/// An [AuthWidgetBuilder] ancestor is required for this widget to work.
/// Note: this class used to be called [LandingPage].
class AuthWidget extends StatefulWidget {
  const AuthWidget({Key key, @required this.userSnapshot, this.seenOnboarding})
      : super(key: key);
  final AsyncSnapshot<FirebaseUser> userSnapshot;
  final bool seenOnboarding;

  @override
  _AuthWidgetState createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.userSnapshot.connectionState == ConnectionState.active) {
      return widget.userSnapshot.hasData
          ? BaseScreens(widget.userSnapshot.data.uid)
          : !widget.seenOnboarding ? Walkthrough() : Login();
    }
    print(widget.userSnapshot.hasData);
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
