import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:platform_alert_dialog/platform_alert_dialog.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/services/firebase_auth_service.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with WidgetsBindingObserver {
  File _image;

  final double _heightContainer = 120;

  bool startAnimation = false;

  Future _getImageGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  Future _getImageCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
  }

  final FocusScopeNode _nodeEmail = FocusScopeNode();
  final FocusScopeNode _nodePassword = FocusScopeNode();
  final FocusScopeNode _nodeName = FocusScopeNode();
  final FocusScopeNode _nodeConfirmation = FocusScopeNode();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmation = TextEditingController();

  bool _obscureTextSignupConfirm = true;

  bool _obscureTextLogin = true;

  double _height = 10.64;
  GlobalKey key = GlobalKey();

  _afterLayout(_) {
    if (startAnimation == false) {
      startAnimation = !startAnimation;
    }

    setState(() {
//      print(_getSizes());
      _height = _getSizes() / 42.1;
//      print(_height);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _afterLayout;
    //WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
//    _name.dispose();
//    _email.dispose();
//    _password.dispose();
//    _confirmation.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      //print(state.toString());
      if (state == AppLifecycleState.resumed) {
        //print('onresumed!!!!!');
        _afterLayout;
      }
    });
  }

  void _togglePassword() {
    setState(() {
      _obscureTextSignupConfirm = !_obscureTextSignupConfirm;
    });
  }

  ValueChanged _onChanged(val) {
    //print(val);
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  double _getSizes() {
    //WidgetsBinding.instance.addPostFrameCallback();

    final RenderBox renderBoxRed = key.currentContext.findRenderObject();
    final sizeRed = renderBoxRed.size;

    return sizeRed.height;
    //print("SIZE of Red: $sizeRed");
  }

  void showSnackBar(String val, BuildContext context) {
    Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: Duration(seconds: 3),
        content: Text(
          val,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        )));
  }

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {

    final FirebaseAuthService auth =
    Provider.of<FirebaseAuthService>(context, listen: false);

//    _auth = ModalRoute.of(context).settings.arguments;

    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);

    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.background,
        child: LayoutBuilder(builder:
            (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
                minWidth: viewportConstraints.maxWidth,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ClipPath(
                    clipper: ClippingClass(),
                    child: AnimatedContainer(
                      duration: Duration(seconds: 1),
                      curve: Curves.easeInOut,
                      height: startAnimation ? _heightContainer : 0,
                      width: viewportConstraints.maxWidth,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary
                        ]),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                            icon: Icon(
                              Platform.isAndroid
                                  ? Icons.arrow_back
                                  : Icons.arrow_back_ios,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(25),
                    child: AnimatedContainer(
                      duration: Duration(seconds: 1),
                      curve: Curves.easeInOut,
                      width: startAnimation
                          ? viewportConstraints.maxWidth - 50
                          : 0,
                      child: Stack(
                        children: <Widget>[
                          Card(
                            key: key,

                            elevation: 10,
//                      color: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                            child: Container(
                              padding: EdgeInsets.only(left: 20.0, right: 20.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                gradient: LinearGradient(colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.secondary
                                ]),
//                          color: Colors.blueAccent
                              ),
                              child: FormBuilder(
                                onChanged: _onChanged,
                                key: _fbKey,
                                autovalidate: false,
//                  readonly: true,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        height: 70,
                                      ),
                                      FormBuilderTextField(
                                        focusNode: _nodeName,
                                        onEditingComplete: () {
                                          if (_fbKey.currentState
                                              .fields['name'].currentState
                                              .validate()) {
                                            _nodeName.unfocus();
                                            FocusScope.of(context)
                                                .requestFocus(_nodeEmail);
                                          }
                                        },
                                        controller: _name,
                                        style:
                                            Theme.of(context).textTheme.button,
                                        cursorColor: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        attribute: 'name',
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                  width: 2),
                                              borderRadius:
                                                  BorderRadius.circular(25.0)),
                                          labelText: 'Nom',
                                          labelStyle: Theme.of(context)
                                              .textTheme
                                              .button,
                                          border: InputBorder.none,
                                          icon: Icon(
                                            FontAwesomeIcons.user,
                                            size: 22.0,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                          ),
                                          errorStyle: Theme.of(context)
                                              .textTheme
                                              .button,
                                        ),
                                        onChanged: _onChanged,
                                        validators: [
                                          FormBuilderValidators.required(
                                              errorText: 'Champs requis'),
                                          (val) {
                                            RegExp regex = new RegExp(
                                                r'^[a-zA-Z0-9][a-zA-Z0-9_]{2,15}$');
                                            if (regex.allMatches(val).length ==
                                                0) {
                                              return 'Entre 2 et 15, ';
                                            }
                                          }
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      FormBuilderTextField(
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
                                        controller: _email,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        style:
                                            Theme.of(context).textTheme.button,
                                        cursorColor: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        attribute: 'email',
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                  width: 2),
                                              borderRadius:
                                                  BorderRadius.circular(25.0)),
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
                                                .onPrimary,
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
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      FormBuilderTextField(
                                        focusNode: _nodePassword,
                                        onEditingComplete: () {
                                          if (_fbKey.currentState
                                              .fields['mot de passe'].currentState
                                              .validate()) {
                                            _nodePassword.unfocus();
                                            FocusScope.of(context)
                                                .requestFocus(_nodeConfirmation);
                                          }
                                        },
                                        controller: _password,
                                        style:
                                            Theme.of(context).textTheme.button,
                                        cursorColor: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        attribute: 'mot de passe',
                                        maxLines: 1,
                                        obscureText: _obscureTextSignupConfirm,
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                  width: 2),
                                              borderRadius:
                                                  BorderRadius.circular(25.0)),
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
                                                .onPrimary,
                                          ),
                                          suffixIcon: IconButton(
                                            onPressed: _togglePassword,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            iconSize: 20,
                                            icon: Icon(FontAwesomeIcons.eye),
                                          ),
                                          errorStyle: Theme.of(context)
                                              .textTheme
                                              .button,
                                        ),
                                        onChanged: _onChanged,
                                        validators: [
                                          /*Strong passwords with min 8 - max 15 character length, at least one uppercase letter, one lowercase letter, one number, one special character (all, not just defined), space is not allowed.*/

                                          (val) {
                                            RegExp regex = new RegExp(
                                                r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d.*)[a-zA-Z0-9\S]{8,15}$');
                                            if (regex.allMatches(val).length ==
                                                0) {
                                              return 'Entre 8 et 15, 1 majuscule, 1 minuscule, 1 chiffre';
                                            }
                                          }
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      FormBuilderTextField(
                                        focusNode: _nodeConfirmation,
                                        onEditingComplete: () {
                                          if (_fbKey.currentState
                                              .fields['email'].currentState
                                              .validate()) {
                                            _nodeEmail.unfocus();
                                            FocusScope.of(context)
                                                .requestFocus(_nodePassword);
                                          }
                                        },
                                        controller: _confirmation,
                                        style:
                                            Theme.of(context).textTheme.button,
                                        cursorColor: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        attribute: 'confirmation',
                                        maxLines: 1,
                                        obscureText: _obscureTextSignupConfirm,
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                  width: 2),
                                              borderRadius:
                                                  BorderRadius.circular(25.0)),
                                          labelText: 'Confirmation',
                                          labelStyle: Theme.of(context)
                                              .textTheme
                                              .button,
                                          border: InputBorder.none,
                                          icon: Icon(
                                            FontAwesomeIcons.key,
                                            size: 22.0,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                          ),
                                          errorStyle: Theme.of(context)
                                              .textTheme
                                              .button,
                                          suffixIcon: IconButton(
                                            onPressed: _togglePassword,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            iconSize: 20,
                                            icon: Icon(FontAwesomeIcons.eye),
                                          ),
                                        ),
                                        onChanged: _onChanged,
                                        validators: [
                                          (val) {
                                            if (_password.text != val)
                                              return 'Pas identique';
                                          },
                                        ],
                                      ),
                                      SizedBox(
                                        height: 70,
                                      ),
                                    ]),
                              ),
                            ),
                          ),
                          FractionalTranslation(
                            translation: Offset(0.0, -0.5),
                            child: Align(
                              alignment: FractionalOffset(0.5, 0.0),
                              child: CircleAvatar(
                                  backgroundImage: _image != null
                                      ? FileImage(_image)
                                      : AssetImage(
                                          'assets/img/normal_user_icon.png'),
                                  radius: 50,
                                  child: RawMaterialButton(
                                    shape: const CircleBorder(),
                                    splashColor: Colors.black45,
                                    onPressed: () {
                                      showDialog<void>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return PlatformAlertDialog(
                                            title: Text(
                                              'Source?',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .display1,
                                            ),
                                            actions: <Widget>[
                                              PlatformDialogAction(
                                                child: Text(
                                                  'Caméra',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .display1
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  _getImageCamera();
                                                },
                                              ),
                                              PlatformDialogAction(
                                                child: Text(
                                                  'Galerie',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .display1
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                ),
                                                //actionType: ActionType.,
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  _getImageGallery();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    padding: const EdgeInsets.all(50.0),
                                  )),
                            ),
                          ),
                          FractionalTranslation(
                            translation: Offset(
                              0.0,
                              _height,
                            ),
                            child: Align(
                                alignment: FractionalOffset(0.5, 0.0),
                                child: ProgressButton(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: 20,
                                    width: viewportConstraints.maxWidth*0.6,

                                    defaultWidget: Text(
                                      'S\'inscrire',
                                      style:
                                          Theme.of(context).textTheme.display2,
                                    ),
                                type: ProgressButtonType.Raised,
                                    progressWidget: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary)),

                                    onPressed: () async{
                                      _fbKey.currentState.save();
                                      if (_fbKey.currentState.validate()) {
                                        print(_fbKey.currentState.value);
                                        if (_image != null) {
                                          await auth
                                              .register(
                                                  _email.text,
                                                  _password.text,
                                                  _name.text,
                                                  _image,
                                                  context)
                                              .then((str) {
                                                print('!!!$str!!!');
                                          });
                                          //Navigator.pop(context);
                                        } else {
                                          showSnackBar(
                                              'Il manque une photo', context);
                                        }
                                      } else {
                                        print(_fbKey.currentState.value);
                                        showSnackBar(
                                            "formulaire non valide", context);
                                      }
                                    })),
                          ),

                        ],
                      ),
                    ),
                  ),
                  ClipPath(
                    clipper: ClippingClassBottom(),
                    child: AnimatedContainer(
                      duration: Duration(seconds: 1),
                      curve: Curves.easeInOut,
                      height: startAnimation ? _heightContainer : 0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
//              child: Column(
//
//                children: <Widget>[
//                  CircleAvatar(
//                      backgroundImage: _image != null
//                          ? FileImage(_image)
//                          : AssetImage('assets/img/normal_user_icon.png'),
////                      Icon(FontAwesomeIcons.userAlt)
//                      radius: 50,
//                      child: RawMaterialButton(
//                        shape: const CircleBorder(),
//                        splashColor: Colors.black45,
//                        onPressed: () {
//                          showDialog<void>(
//                            context: context,
//                            builder: (BuildContext context) {
//                              return PlatformAlertDialog(
//                                title: Text('Source?',style: Theme.of(context).textTheme.display1,),
//                                actions: <Widget>[
//                                  PlatformDialogAction(
//                                    child: Text('Caméra',style: Theme.of(context).textTheme.display1.copyWith(fontWeight: FontWeight.bold),),
//                                    onPressed: () {
//                                      Navigator.of(context).pop();
//                                      _getImageCamera();
//                                    },
//                                  ),
//                                  PlatformDialogAction(
//                                    child: Text('Galerie',style: Theme.of(context).textTheme.display1.copyWith(fontWeight: FontWeight.bold),),
//                                    //actionType: ActionType.,
//                                    onPressed: () {
//                                      Navigator.of(context).pop();
//                                      _getImageGallery();
//                                    },
//
//                                  ),
//                                ],
//                              );
//                            },
//                          );
//                        },
//                        padding: const EdgeInsets.all(50.0),
//                      )),
//                ],
//              ),
            ),
          );
        }),
      ),
    );
  }
}

class ClippingClassBottom extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height * 0.7);

    //path.lineTo(0.0, size.height);

    path.lineTo(size.width, 0);

    path.lineTo(size.width, size.height);

    path.lineTo(0.0, size.height);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}

class ClippingClass extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height);

    path.lineTo(size.width, size.height * 0.3);

    path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}
