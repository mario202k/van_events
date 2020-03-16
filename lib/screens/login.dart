import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/routing/route.gr.dart';
import 'package:vanevents/services/firebase_auth_service.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final FocusScopeNode _nodeEmail = FocusScopeNode();
  final FocusScopeNode _nodePassword = FocusScopeNode();
  final TextEditingController _email = new TextEditingController();
  final TextEditingController _password = new TextEditingController();
  bool _obscureTextSignupConfirm = true;
  GlobalKey key = GlobalKey();
  bool isDispose = false;

  double height = 4.30;

  bool startAnimation = false;

  void _togglePassword() {
    setState(() {
      _obscureTextSignupConfirm = !_obscureTextSignupConfirm;
    });
  }

  _afterLayout(_) {

    if(!isDispose){
      setState(() {
        height = _getSizes() / 45;
      });
    }


  }

  double _getSizes() {

    final RenderBox renderBoxRed = key.currentContext.findRenderObject();
    final sizeRed = renderBoxRed.size;
    return sizeRed.height;
  }

  @override
  void dispose() {
    isDispose = true;
    _nodeEmail.dispose();
    _nodePassword.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Theme.of(context).colorScheme.secondary,
      statusBarIconBrightness: Theme.of(context).colorScheme.brightness,
      systemNavigationBarColor: Theme.of(context).colorScheme.secondary,
      systemNavigationBarIconBrightness:
          Theme.of(context).colorScheme.brightness,
    ));

    final FirebaseAuthService auth =
        Provider.of<FirebaseAuthService>(context, listen: false);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
//          gradient: LinearGradient(
//            colors: [
//              Theme.of(context).colorScheme.secondary,
//              Theme.of(context).colorScheme.primary
//
//            ],
//            begin: Alignment.topLeft,
//            end: Alignment.bottomRight,
//          ),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            ProgressButton progressButton =
                buildProgressButton(context, auth, viewportConstraints);
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight,
                ),
                child: FormBuilder(
                  key: _fbKey,
                  autovalidate: false,
                  child: Column(
                    children: <Widget>[
                      AspectRatio(
                          aspectRatio: 1.6,
                          child: FlareActor(
                            'assets/animations/dance.flr',
                            alignment: Alignment.center,
                            animation: 'dance',
                          )),
                      SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Stack(
                              children: <Widget>[
                                Card(
                                  key: key,
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        left: 20.0, right: 20.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      gradient: LinearGradient(colors: [
                                        Theme.of(context).colorScheme.primary,
                                        Theme.of(context).colorScheme.secondary
                                      ]),
//                          color: Colors.blueAccent
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        SizedBox(
                                          height: 20,
                                        ),
                                        FormBuilderTextField(
                                          controller: _email,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          style: Theme.of(context)
                                              .textTheme
                                              .button,
                                          cursorColor: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                          attribute: 'email',
                                          decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onBackground,
                                                    width: 2),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        25.0)),
                                            labelText: 'Email',
                                            labelStyle: Theme.of(context)
                                                .textTheme
                                                .button,
                                            border: InputBorder.none,
                                            icon: Icon(
                                              FontAwesomeIcons.at,
                                              size: 22.0,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground,
                                            ),
                                            errorStyle: Theme.of(context)
                                                .textTheme
                                                .caption,
                                          ),
                                          validators: [
                                            FormBuilderValidators.required(
                                                errorText: 'Champs requis'),
                                            FormBuilderValidators.email(
                                                errorText:
                                                    'Veuillez saisir un Email valide'),
                                          ],
                                          focusNode: _nodeEmail,
                                          onEditingComplete: () {
                                            if (_fbKey.currentState
                                                .fields['email'].currentState
                                                .validate()) {
                                              _nodeEmail.unfocus();
                                              FocusScope.of(context)
                                                  .requestFocus(_nodePassword);
                                            }
                                          },
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        FormBuilderTextField(
                                          controller: _password,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground,),
                                          cursorColor: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                          attribute: 'mot de passe',
                                          obscureText:
                                              _obscureTextSignupConfirm,
                                          maxLines: 1,
                                          decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onBackground,
                                                    width: 2),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        25.0)),
                                            labelText: 'Mot de passe',
                                            labelStyle: Theme.of(context)
                                                .textTheme
                                                .button,
                                            border: InputBorder.none,
                                            icon: Icon(
                                              FontAwesomeIcons.key,
                                              size: 22.0,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground,
                                            ),
                                            suffixIcon: IconButton(
                                              onPressed: _togglePassword,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground,
                                              iconSize: 20,
                                              icon: Icon(FontAwesomeIcons.eye),
                                            ),
                                            errorStyle: Theme.of(context)
                                                .textTheme
                                                .caption,
                                          ),
                                          validators: [
                                            /*Strong passwords with min 8 - max 15 character length, at least one uppercase letter, one lowercase letter, one number, one special character (all, not just defined), space is not allowed.*/

                                            (val) {
                                              RegExp regex = new RegExp(
                                                  r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d.*)[a-zA-Z0-9\S]{8,15}$');
                                              if (regex
                                                      .allMatches(val)
                                                      .length ==
                                                  0) {
                                                return 'Entre 8 et 15, 1 majuscule, 1 minuscule, 1 chiffre';
                                              }
                                            }
                                          ],
                                          focusNode: _nodePassword,
                                          onEditingComplete: () {
                                            if (!_fbKey
                                                .currentState
                                                .fields['mot de passe']
                                                .currentState
                                                .validate()) {
                                              return;
                                            }
                                            _nodePassword.unfocus();
                                            progressButton.onPressed();
                                          },
                                        ),
                                        SizedBox(
                                          height: 30,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                FractionalTranslation(
                                    translation: Offset(0.0, height),
                                    child: Align(
                                        alignment: FractionalOffset(0.5, 0.0),
                                        child: AnimatedSwitcher(
                                          duration: Duration(milliseconds: 500),
                                          transitionBuilder: (Widget child, Animation<double> animation) {
                                            return ScaleTransition(
                                              scale: animation,
                                              child: child,
                                            );
                                          },
                                          child: !startAnimation ? progressButton: CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                  Theme.of(context).colorScheme.primary)),
                                        ),)),
                              ],
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                    flex: 4,
                                    child: Divider(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                      thickness: 1,
                                    )),
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                      'ou',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.button,
                                    )),
                                Expanded(
                                    flex: 4,
                                    child: Divider(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                      thickness: 1,
                                    )),
                              ],
                            ),
                            SizedBox(
                              height: 30,
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                FloatingActionButton(
                                  onPressed: () {
                                    print('facebook');
                                  },
                                  backgroundColor: Colors.blue.shade800,
                                  child: Icon(
                                    FontAwesomeIcons.facebookF,
                                    color: Colors.white,
                                  ),
                                  heroTag: null,
                                ),
                                FloatingActionButton(
                                    onPressed: () {
                                      auth.googleSignIn().catchError((e) {
                                        print(e);
                                        auth.showSnackBar(
                                            'impossible de se connecter',
                                            context);
                                      });
                                    },
                                    backgroundColor: Colors.red.shade700,
                                    child: Icon(
                                      FontAwesomeIcons.google,
                                      color: Colors.white,
                                    ),
                                    heroTag: null),
                              ],
                            ),
                            SizedBox(
                              height: 30,
                            ),

                            FlatButton(
                              onPressed: () => Navigator.of(context)
                                  .pushNamed(Router.signUp),
                              child: Text(
                                'Pas de compte? S\'inscrire maintenant',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.button,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            FlatButton(
                              onPressed: () => Navigator.of(context)
                                  .pushNamed(Router.resetPassword),
                              child: Text(
                                'Mot de passe oublier?',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.button,
                              ),
                            ),
//                      ProviderButton(
//                        text: 'AVEC GOOGLE',
//                        icon: FontAwesomeIcons.google,
//                        color: Colors.black45,
//                        loginMethod: auth.googleSignIn,
//                      ),
//                      ProviderButton(
//                        text: 'AVEC FACEBOOK',
//                        icon: FontAwesomeIcons.facebook,
//                        color: Colors.black45,
//                        loginMethod: auth.faceBookSignIn,
//                      ),
//                      ProviderButton(
//                          text: 'Continuer en tant qu\'invité' , loginMethod: auth.anonLogin),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  ProgressButton buildProgressButton(BuildContext context,
      FirebaseAuthService auth, BoxConstraints viewportConstraints) {
    return ProgressButton(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: 20,
        width: viewportConstraints.maxWidth * 0.6,
        defaultWidget: Text(
          'Se connecter',
          style: Theme.of(context).textTheme.display2,
        ),
        type: ProgressButtonType.Raised,
        progressWidget: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary)),
        onPressed: () async {
          if (!_fbKey.currentState.validate()) {
            auth.showSnackBar('Formulaire invalide', context);
            return;
          }
          await _submit(auth, context);
        });
  }

  Future _submit(FirebaseAuthService auth, BuildContext context) async {
    if(!isDispose){
      setState(() {
        startAnimation = true;
      });
    }
    return await auth
        .signInWithEmailAndPassword(_email.text, _password.text)
        .catchError((e) {
      if(!isDispose){
        setState(() {
          startAnimation = false;
        });
      }

      print(e);
      auth.showSnackBar("email ou mot de passe invalide", context);
    }).whenComplete((){
//      if(!isDispose){
//        setState(() {
//          startAnimation = false;
//        });
//      }
    });
  }


}
