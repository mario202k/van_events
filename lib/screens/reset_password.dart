import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/services/firebase_auth_service.dart';
import 'package:vanevents/shared/topAppBar.dart';

class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword>
    with WidgetsBindingObserver {

  final double _heightContainer = 120;

  bool startAnimation = false;

  final TextEditingController _email = TextEditingController();

  double _height = 6.275;
  GlobalKey key = GlobalKey();

  _afterLayout(_) {
    if (startAnimation == false) {
      startAnimation = !startAnimation;
    }

    setState(() {
      //print(_getSizes());
      _height = _getSizes() / 43.5;
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

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {

//    _auth = ModalRoute.of(context).settings.arguments;
    final FirebaseAuthService auth =
    Provider.of<FirebaseAuthService>(context, listen: false);
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
                                      Text(
                                        'Veuillez saisir votre adresse email',
                                        style: Theme.of(context)
                                            .textTheme
                                            .body2,
                                      ),
                                      FormBuilderTextField(
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
                                        height: 70,
                                      ),
                                    ]),
                              ),
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
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    borderRadius: 20,
                                    width: viewportConstraints.maxWidth * 0.6,
                                    defaultWidget: Text(
                                      'Envoyer l\'email',
                                      style:
                                          Theme.of(context).textTheme.display2,
                                    ),
                                    type: ProgressButtonType.Raised,
                                    progressWidget: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primary)),
                                    onPressed: () async {
                                      _fbKey.currentState.save();
                                      if (_fbKey.currentState.validate()) {
                                        print(_fbKey.currentState.value);
                                        await auth
                                            .resetEmail(_email.text, context)
                                            .then((str) {
                                          print('!!!$str!!!');
                                        });
                                      } else {
                                        print(_fbKey.currentState.value);
                                        auth.showSnackBar(
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
