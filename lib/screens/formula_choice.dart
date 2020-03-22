import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:vanevents/models/formule.dart';

import 'package:stripe_payment/stripe_payment.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:vanevents/models/participant.dart';

class FormulaChoice extends StatefulWidget {
  final List<Formule> formulas;

  FormulaChoice(this.formulas);

  @override
  _FormulaChoiceState createState() => _FormulaChoiceState();
}

class _FormulaChoiceState extends State<FormulaChoice> {
  String text = 'Click the button to start the payment';
  double totalCost = 10.0;
  double tip = 1.0;
  double tax = 0.0;
  double taxPercent = 0.2;
  int amount = 0;
  bool showSpinner = false;
  String url =
      'https://us-central1-demostripe-b9557.cloudfunctions.net/StripePI';

  //final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  List<Formule> _formules = List<Formule>();

  List<Participant> participants = List<Participant>();

  //List<CardFormula> listWidget;

  int indexParticipants = 0;

  double _total = 0;

  @override
  void initState() {
    _formules = widget.formulas;

    super.initState();
  }

  void onTap(bool plus, Formule formule) {
    int prix = formule.prix;

    if (plus) {
      setState(() {
        _total = _total + prix;
      });
    } else {
      setState(() {
        _total = _total - prix;
      });
      //pour supprimer le participant;
      for (int i = participants.length - 1; i >= 0; i--) {
        if (participants[i].formule.id == formule.id) {
          participants.removeAt(i);
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      key: _scaffoldKey,
      appBar: AppBar(
          title: Text(
        "Formules",
      )),
      body: Stack(
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height - 80),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80, left: 10, right: 10),
              child: ListView.builder(
                  itemCount: _formules.length,
                  itemBuilder: (context, index) {
                    return CardFormula(
                        formule: _formules[index],
                        onTap: onTap,
                        onChangedParticipant: onChangeParticipant);
                  }),
            ),
          ),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Material(
                  color: Theme.of(context).colorScheme.secondary,
                  elevation: 14.0,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0),
                  ),
                  shadowColor: Colors.black,
                  child: _buildTotalContent(),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  //onChanged(_fbKey,widget.index,widget.participant.formule, prenom, false);

  void onChangeParticipant(GlobalKey<FormBuilderState> _fbKey, int index,
      Formule formule, String val, bool isNom) {
    Participant participant;
    for (int i = 0; i < participants.length; i++) {
      if (participants[i].formule.id == formule.id &&
          participants[i].index == index) {
        participant = participants[i];
        break;
      }
    }

    if (participant == null) {
      if (isNom) {
        participants.add(Participant(_fbKey, index, formule, val, ''));
      } else {
        participants.add(Participant(_fbKey, index, formule, '', val));
      }
    } else {
      int index = participants.indexOf(participant);
      participants.removeAt(index);
      if (isNom) {
        participant.nom = val;
      } else {
        participant.prenom = val;
      }
      participants.insert(index, participant);
    }
  }

  void checkIfNativePayReady() async {
    print('started to check if native pay ready');
    bool deviceSupportNativePay = await StripePayment.deviceSupportsNativePay();
    bool isNativeReady = await StripePayment.canMakeNativePayPayments(
        ['american_express', 'visa', 'maestro', 'master_card']);
    deviceSupportNativePay && isNativeReady
        ? createPaymentMethodNative()
        : createPaymentMethod();
  }

  Future<void> createPaymentMethodNative() async {
    print('started NATIVE payment...');

    StripePayment.setStripeAccount(null);

    List<ApplePayItem> items = [];

    items.add(ApplePayItem(
      label: 'Demo Order',
      amount: totalCost.toString(),
    ));

//    if (tip != 0.0)
//      items.add(ApplePayItem(
//        label: 'Tip',
//        amount: tip.toString(),
//      ));

//    if (taxPercent != 0.0) {
//      tax = ((totalCost * taxPercent) * 100).ceil() / 100;
//      items.add(ApplePayItem(
//        label: 'Tax',
//        amount: tax.toString(),
//      ));
//    }

    items.add(ApplePayItem(
      label: 'Vendor A',
      amount: (totalCost + tip + tax).toString(),
    ));

    amount = ((totalCost + tip + tax) * 100).toInt();

    print('amount in pence/cent which will be charged = $amount');

    //step 1: add card
    PaymentMethod paymentMethod = PaymentMethod();

    Token token = await StripePayment.paymentRequestWithNativePay(
      androidPayOptions: AndroidPayPaymentRequest(
        total_price: (totalCost + tax + tip).toStringAsFixed(2),
        currency_code: 'EUR',
      ),
      applePayOptions: ApplePayPaymentOptions(
        countryCode: 'FR',
        currencyCode: 'EUR',
        items: items,
      ),
    );

    paymentMethod = await StripePayment.createPaymentMethod(
      PaymentMethodRequest(
        card: CreditCard(
          token: token.tokenId,
        ),
      ),
    );

    paymentMethod != null
        ? processPaymentAsDirectCharge(paymentMethod)
        : showDialog(
            context: context,
            builder: (BuildContext context) => ShowDialogToDismiss(
                title: 'Error',
                content:
                    'It is not possible to pay with this card. Please try again with a different card',
                buttonText: 'CLOSE'));
  }

  Future<void> createPaymentMethod() async {
    StripePayment.setStripeAccount(null);

    tax = ((totalCost * taxPercent) * 100).ceil() / 100;

    amount = ((totalCost + tip + tax) * 100).toInt();
    print('amount in pence/cent which will be charged = $amount');

    //step 1: add card
    PaymentMethod paymentMethod = PaymentMethod();
    paymentMethod = await StripePayment.paymentRequestWithCardForm(
      CardFormPaymentRequest(),
    ).then((PaymentMethod paymentMethod) {
      return paymentMethod;
    }).catchError((e) {
      print('Errore Card: ${e.toString()}');
    });

    paymentMethod != null
        ? processPaymentAsDirectCharge(paymentMethod)
        : showDialog(
            context: context,
            builder: (BuildContext context) => ShowDialogToDismiss(
                title: 'Error',
                content:
                    'It is not possible to pay with this card. Please try again with a different card',
                buttonText: 'CLOSE'));
  }

  Future<void> processPaymentAsDirectCharge(PaymentMethod paymentMethod) {}

  _buildTotalContent() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
              flex: 1,
              child: Text(
                '   $_total €',
                textAlign: TextAlign.center,
              )),
          Flexible(
            flex: 1,
            child: FloatingActionButton.extended(
              backgroundColor: Theme.of(context).colorScheme.primary,
              icon: Text(
                'Continuer',
                style: Theme.of(context).textTheme.button,
              ),
              label: Icon(
                FontAwesomeIcons.creditCard,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
              onPressed: () {
                print(participants.length);
                for (int i = 0; i < participants.length; i++) {
                  print(
                      '${participants[i].nom} ${participants[i].prenom} ${participants[i].index}');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CardParticipant extends StatefulWidget {
  final Function onChanged;
  final Participant participant;
  final int index;

  CardParticipant(this.participant, this.index, this.onChanged);

  @override
  _CardParticipantState createState() => _CardParticipantState();
}

class _CardParticipantState extends State<CardParticipant> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final FocusScopeNode _nom = FocusScopeNode();
  final FocusScopeNode _prenom = FocusScopeNode();

  @override
  void initState() {
    widget.onChanged(
        _fbKey, widget.index, widget.participant.formule, '', true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
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
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Participant',
                  style: Theme.of(context).textTheme.button,
                ),
                FormBuilder(
                  key: _fbKey,
                  autovalidate: false,
                  child: Column(
                    children: <Widget>[
                      FormBuilderTextField(
                        keyboardType: TextInputType.text,
                        style: TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        attribute: 'nom',
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.circular(25.0)),
                          labelText: 'Nom',
                          labelStyle: TextStyle(color: Colors.white),
                          border: InputBorder.none,
                          errorStyle: TextStyle(color: Colors.white),
                        ),
                        focusNode: _nom,
                        onEditingComplete: () {
                          if (_fbKey.currentState.fields['nom'].currentState
                              .validate()) {
                            _nom.unfocus();
                            FocusScope.of(context).requestFocus(_prenom);
                          }
                        },
                        onChanged: (val) {
                          String nom = val;
                          _fbKey.currentState.save();
                          widget.onChanged(_fbKey, widget.index,
                              widget.participant.formule, nom, true);
                        },
                        validators: [
                          FormBuilderValidators.required(
                              errorText: 'Champs requis'),
                          (val) {
                            RegExp regex =
                                new RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9_]{2,15}$');
                            if (regex.allMatches(val).length == 0) {
                              return 'Entre 2 et 15, ';
                            }
                          }
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      FormBuilderTextField(
                        keyboardType: TextInputType.text,
                        style: TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        attribute: 'prenom',
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.circular(25.0)),
                          labelText: 'Prénom',
                          labelStyle: TextStyle(color: Colors.white),
                          border: InputBorder.none,
                          errorStyle: TextStyle(color: Colors.white),
                        ),
                        focusNode: _prenom,
                        onEditingComplete: () {
                          if (_fbKey.currentState.fields['prenom'].currentState
                              .validate()) {
                            _prenom.unfocus();
                            SystemChannels.textInput
                                .invokeMethod('TextInput.hide');
                          }
                        },
                        onChanged: (val) {
                          String prenom = val;
                          _fbKey.currentState.save();
                          widget.onChanged(_fbKey, widget.index,
                              widget.participant.formule, prenom, false);
                        },
                        validators: [
                          FormBuilderValidators.required(
                              errorText: 'Champs requis'),
                          (val) {
                            RegExp regex =
                                new RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9_]{2,15}$');
                            if (regex.allMatches(val).length == 0) {
                              return 'Entre 2 et 15, ';
                            }
                          }
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CardFormula extends StatefulWidget {
  final Formule formule;
  final Function onTap;
  final Function onChangedParticipant;

  CardFormula({this.formule, this.onTap, this.onChangedParticipant});

  @override
  _CardFormulaState createState() => _CardFormulaState();
}

class _CardFormulaState extends State<CardFormula>
    with AutomaticKeepAliveClientMixin {
  List<Participant> participants = List<Participant>();
  List<CardParticipant> participantsWidget;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  int nb = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: SizedBox(
            height: 128.0,
            child: Card(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text('${widget.formule.title} : ${widget.formule.prix} €'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        RawMaterialButton(
                          onPressed: () {
                            if (nb > 0) {
                              widget.onTap(false, widget.formule);
                              onTap(false, participants.length - 1,
                                  widget.formule);
                            }
                          },
                          child: Icon(
                            FontAwesomeIcons.minus,
                            color: Theme.of(context).colorScheme.primary,
                            size: 30.0,
                          ),
                          shape: CircleBorder(),
                          elevation: 5.0,
                          fillColor: Theme.of(context).colorScheme.secondary,
                          padding: const EdgeInsets.all(10.0),
                        ),
                        Text(nb.toString()),
                        RawMaterialButton(
                          onPressed: () {
                            if (nb >= 0) {
                              widget.onTap(true, widget.formule);
                              onTap(true, participants.length, widget.formule);
                            }
                          },
                          child: Icon(
                            FontAwesomeIcons.plus,
                            color: Theme.of(context).colorScheme.primary,
                            size: 30.0,
                          ),
                          shape: CircleBorder(),
                          elevation: 5.0,
                          fillColor: Theme.of(context).colorScheme.secondary,
                          padding: const EdgeInsets.all(10.0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AnimatedList(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          key: _listKey,
          initialItemCount: participants.length,
          itemBuilder:
              (BuildContext context, int index, Animation<double> animation) {
            return SizeTransition(
              axis: Axis.vertical,
              sizeFactor: animation,
              child: _buildItem(participants[index], index, animation,
                  widget.onChangedParticipant),
            );
          },
        ),
      ],
    );
  }

  Widget _buildItem(Participant participant, int index,
      Animation<double> animation, Function onChangedParticipant) {
    print('buildItem!!!');
    return CardParticipant(participant, index, onChangedParticipant);
  }

  Widget _buildRemovedItem(participant, index) {
    return CardParticipant(participant, index, onChangeParticipant);
  }

  void onChangeParticipant(GlobalKey<FormBuilderState> _fbKey, int index,
      Formule formule, String val, bool isNom) {}

  void onTap(bool plus, int index, Formule formule) {
    if (plus) {
      participants.insert(index, Participant(null, index, formule, '', ''));
      _listKey.currentState
          .insertItem(index, duration: Duration(milliseconds: 500));
      setState(() {
        nb++;
      });
    } else {
      Participant participant = participants.removeAt(index);
      _listKey.currentState.removeItem(
        index,
        (BuildContext context, Animation<double> animation) {
          return FadeTransition(
            opacity:
                CurvedAnimation(parent: animation, curve: Interval(0.5, 1.0)),
            child: SizeTransition(
              sizeFactor:
                  CurvedAnimation(parent: animation, curve: Interval(0.0, 1.0)),
              axisAlignment: 0.0,
              child: _buildRemovedItem(participant, index),
            ),
          );
        },
        duration: Duration(milliseconds: 600),
      );
      setState(() {
        nb--;
      });
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class ShowDialogToDismiss extends StatelessWidget {
  final String content;
  final String title;
  final String buttonText;

  ShowDialogToDismiss({this.title, this.buttonText, this.content});

  @override
  Widget build(BuildContext context) {
    if (!Platform.isIOS) {
      return AlertDialog(
        title: new Text(
          title,
        ),
        content: new Text(
          this.content,
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Text(
              buttonText,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    } else {
      return CupertinoAlertDialog(
          title: Text(
            title,
          ),
          content: new Text(
            this.content,
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: new Text(
                buttonText[0].toUpperCase() +
                    buttonText.substring(1).toLowerCase(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ]);
    }
  }
}