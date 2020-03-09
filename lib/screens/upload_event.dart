import 'dart:async';
import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:platform_alert_dialog/platform_alert_dialog.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/models/formule.dart';
import 'package:vanevents/services/firestore_database.dart';
import 'package:vanevents/shared/indicator.dart';
import 'package:vanevents/shared/topAppBar.dart';

class UploadEvent extends StatefulWidget {
  @override
  _UploadEventState createState() => _UploadEventState();
}

class _UploadEventState extends State<UploadEvent> {
  File _image;
  final TextEditingController _description = TextEditingController();
  final TextEditingController _title = TextEditingController();

  //final TextEditingController _date = TextEditingController();
  DateTime _dateDebut, _dateFin;

  int nbForm = 1;
  List<int> nbTotalList = List<int>();
  int nbTotal = 1;

  int lastIndex = 0;
  final GlobalKey<FormBuilderState> _fbKey =
      GlobalKey<FormBuilderState>(debugLabel: '_homeScreenkey');
  final GlobalKey<FormFieldState> _specifyTextFieldKey =
      GlobalKey<FormFieldState>();
  ScrollController _controller = ScrollController();

  var formulesWidgets = List<Widget>();

  StreamController<PieTouchResponse> pieTouchedResultStreamController;
  int touchedIndex, lastTouched;

  List<PieChartSectionData> _listPieChart = List<PieChartSectionData>();
  List<Indicator> _listIndicator = List<Indicator>();

  String _nom, _prix, _nb;

  Future _getImageCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    String path = image.path;
    print(path.substring(path.lastIndexOf('/') + 1));
    setState(() {
      _image = image;
    });
  }

  Future _getImageGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    String path = image.path;
    print(path.substring(path.lastIndexOf('/') + 1));
    setState(() {
      _image = image;
    });
  }

  @override
  void initState() {
    addFormule();

    super.initState();

    pieTouchedResultStreamController = StreamController();
    pieTouchedResultStreamController.stream.distinct().listen((details) {
      if (details == null) {
        return;
      }

      setState(() {
        if (details.touchInput is FlLongPressEnd) {
          touchedIndex = -1;
        } else {
          touchedIndex = details.touchedSectionIndex;
        }

        //highlight indicator
        if (touchedIndex != null && touchedIndex >= 0) {
          lastTouched = touchedIndex;
          _listIndicator.insert(
            touchedIndex,
            Indicator(
              color: Colors.primaries[touchedIndex % Colors.primaries.length],
              text: _listIndicator.elementAt(touchedIndex).text,
              isSquare: false,
              size: 18,
              textColor: Colors.black,
            ),
          );
          _listIndicator.removeAt(touchedIndex + 1);
        } else if (lastTouched != null) {
          _listIndicator.insert(
            lastTouched,
            Indicator(
              color: Colors.primaries[lastTouched % Colors.primaries.length],
              text: _listIndicator.elementAt(lastTouched).text,
              isSquare: false,
              size: 16,
              textColor: Colors.grey,
            ),
          );

          _listIndicator.removeAt(lastTouched + 1);
        }
      });
    });
  }

  void addFormule() {
    setState(() {
      _listPieChart.add(PieChartSectionData(
        color: Colors.primaries[nbForm - 1 % Colors.primaries.length],
        value: 1,
        title: '1',
        radius: 50,
        titleStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xff90672d)),
        titlePositionPercentageOffset: 0.55,
      ));

      nbTotalList.add(1);
      nbTotal = 0;

      nbTotalList.forEach((nb) {
        nbTotal += nb;
      });

      _listIndicator.add(
        Indicator(
          color: Colors.primaries[nbForm - 1 % Colors.primaries.length],
          text: 'F$nbForm',
          isSquare: false,
          size: 16,
          textColor: Colors.grey,
        ),
      );

      formulesWidgets.add(CardForm(nbForm, (value) {
        //nombe de personne
        String str = value;
        int index = int.parse(str.substring(0, str.indexOf('/'))) - 1;
        String val = str.substring(str.indexOf('/') + 1);

        if (val.isNotEmpty) {
          double nb = double.parse(val);
          PieChartSectionData pieChartSectionData =
              _listPieChart.elementAt(index).copyWith(value: nb, title: val);
          setState(() {
            nbTotalList.insert(index, nb.toInt());

            if (nbTotalList.length != index + 1) {
              nbTotalList.removeAt(index + 1);
            }

            //recompter
            nbTotal = 0;

            nbTotalList.forEach((nb) {
              nbTotal += nb;
            });

            _listPieChart.removeAt(index);
            _listPieChart.insert(index, pieChartSectionData);
          });
        }
      }));

      formulesWidgets.add(Divider());
      nbForm++;
    });
  }

  void deleteFormule() {
    setState(() {
      _listPieChart.removeLast();
      _listIndicator.removeLast();

      formulesWidgets.removeLast();

      formulesWidgets.removeLast();
      nbForm--;

      nbTotalList.removeLast();
      //recompter

      nbTotal = 0;

      nbTotalList.forEach((nb) {
        nbTotal += nb;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    pieTouchedResultStreamController.close();
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(_listPieChart.length, (i) {
      final isTouched = i == touchedIndex;
      final double opacity = isTouched ? 1 : 0.6;
      final double fontSize = isTouched ? 25 : 16;
      final double radius = isTouched ? 60 : 50;

      PieChartSectionData pieChartSectionData = _listPieChart.elementAt(i);

      return pieChartSectionData.copyWith(
        color: pieChartSectionData.color.withOpacity(opacity),
        radius: radius,
        titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreDatabase db =
        Provider.of<FirestoreDatabase>(context, listen: false);

    return Scaffold(
        body: Container(
      color: Theme.of(context).colorScheme.background,
      child: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                minHeight: constraints.maxHeight),
            child: Column(
              children: <Widget>[
                TopAppBar(
                    'Upload new event', false, () {}, constraints.maxWidth),
                IntrinsicHeight(
                  child: FormBuilder(
                    // context,
                    key: _fbKey,
                    autovalidate: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            showDialog<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return PlatformAlertDialog(
                                  title: Text(
                                    'Source?',
                                    style: Theme.of(context).textTheme.display1,
                                  ),
                                  actions: <Widget>[
                                    PlatformDialogAction(
                                      child: Text(
                                        'Caméra',
                                        style: Theme.of(context)
                                            .textTheme
                                            .display1
                                            .copyWith(
                                                fontWeight: FontWeight.bold),
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
                                                fontWeight: FontWeight.bold),
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
                          child: Container(
                            child: _image != null
                                ? Image.file(
                                    _image,
                                  )
                                : Icon(
                                    FontAwesomeIcons.cloudUploadAlt,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    size: 220,
                                  ),
                          ),
                        ),
                        Divider(),
                        FormBuilderTextField(
                          controller: _title,
                          attribute: 'title',
                          decoration: buildInputDecoration(context,'Titre'),
                          validators: [
                            FormBuilderValidators.required(
                                errorText: 'Champs requis')
                          ],
                        ),
                        Divider(),
                        FormBuilderDateTimePicker(
                          attribute: "DateDebut",
                          onChanged: (dt) {
                            SystemChannels.textInput
                                .invokeMethod('TextInput.hide');
                            setState(() => _dateDebut = dt);
                          },
                          inputType: InputType.both,
                          format: DateFormat("dd/MM/yyyy 'à' HH:mm"),
                          decoration: buildInputDecoration(context,'Date de debut'),
                          validators: [
                            FormBuilderValidators.required(
                                errorText: "champs requis")
                          ],
                        ),
                        Divider(),
                        FormBuilderDateTimePicker(
                          attribute: "DateFin",
                          onChanged: (dt) {
                            SystemChannels.textInput
                                .invokeMethod('TextInput.hide');
                            setState(() => _dateFin = dt);
                          },
                          inputType: InputType.both,
                          format: DateFormat("dd/MM/yyyy 'à' HH:mm"),
                          decoration: buildInputDecoration(context,'Date de fin'),
                          validators: [
                            FormBuilderValidators.required(
                                errorText: "champs requis")
                          ],
                        ),
                        Divider(),
                        FormBuilderCustomField(
                          attribute: 'adresse',
                          valueTransformer: (val) {
                            if (val == "Autre")
                              return _specifyTextFieldKey.currentState.value;
                            return val;
                          },
                          formField: FormField(
                            builder: (FormFieldState<String> field) {
                              var languages = [
                                '18 avenue de la folie 56050 Danser',
                                '14 rue de la discothèque 47000 Ambiance',
                                "Autre"
                              ];
                              return InputDecorator(
                                decoration:
                                buildInputDecoration(context,'Adresse'),
                                child: Column(
                                  children: languages
                                      .map(
                                        (lang) => Row(
                                          children: <Widget>[
                                            Radio<dynamic>(
                                              value: lang,
                                              groupValue: field.value,
                                              onChanged: (dynamic value) {
                                                field.didChange(lang);
                                              },
                                            ),
                                            Flexible(
                                              child: lang != "Autre"
                                                  ? Text(
                                                      lang,
                                                      textAlign: TextAlign.left,
                                                    )
                                                  : Row(
                                                      children: <Widget>[
                                                        Text(
                                                          lang,
                                                        ),
                                                        SizedBox(width: 20),
                                                        Expanded(
                                                          child: TextFormField(
                                                            key:
                                                                _specifyTextFieldKey,
                                                            decoration: buildInputDecoration(context,''),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                            ),
                                          ],
                                        ),
                                      )
                                      .toList(growable: false),
                                ),
                              );
                            },
                          ),
                          validators: [
                            FormBuilderValidators.required(
                                errorText: "champs requis")
                          ],
                        ),
                        FormBuilderTextField(
                          controller: _description,
                          attribute: 'description',
                          maxLines: 10,
                          decoration: buildInputDecoration(context,'Description'),
                          validators: [
                            FormBuilderValidators.required(
                                errorText: 'Champs requis')
                          ],
                        ),
                        Column(
                          children: formulesWidgets,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            RawMaterialButton(
                              onPressed: () {
                                if (formulesWidgets.length > 2) {
                                  deleteFormule();
                                }
                              },
                              child: Icon(
                                FontAwesomeIcons.minus,
                                color: Colors.purpleAccent,
                                size: 30.0,
                              ),
                              shape: CircleBorder(),
                              elevation: 5.0,
                              fillColor: Color(0xffFAF4F2),
                              padding: const EdgeInsets.all(10.0),
                            ),
                            RawMaterialButton(
                              onPressed: () {
                                addFormule();
                              },
                              child: Icon(
                                FontAwesomeIcons.plus,
                                color: Colors.purpleAccent,
                                size: 30.0,
                              ),
                              shape: CircleBorder(),
                              elevation: 5.0,
                              fillColor: Color(0xffFAF4F2),
                              padding: const EdgeInsets.all(10.0),
                            ),
                          ],
                        ),
                        Divider(),
                        AspectRatio(
                          aspectRatio: 1,
                          child: Card(
                            color: Colors.white,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const SizedBox(
                                  height: 28,
                                ),
                                Wrap(
                                  alignment: WrapAlignment.spaceAround,
                                  spacing: 40,
                                  direction: Axis.horizontal,
                                  runSpacing: 5,
                                  children: _listIndicator,
                                ),
                                const SizedBox(
                                  height: 18,
                                ),
                                Expanded(
                                  child: Stack(
                                    children: <Widget>[
                                      AspectRatio(
                                        aspectRatio: 1,
                                        child: PieChart(
                                          PieChartData(
                                              pieTouchData: PieTouchData(
                                                  touchCallback:
                                                      (pieTouchResponse) {
                                                setState(() {
                                                  if (pieTouchResponse
                                                              .touchInput
                                                          is FlLongPressEnd ||
                                                      pieTouchResponse
                                                              .touchInput
                                                          is FlPanEnd) {
                                                    touchedIndex = -1;
                                                  } else {
                                                    touchedIndex =
                                                        pieTouchResponse
                                                            .touchedSectionIndex;
                                                  }
                                                });
                                              }),
                                              startDegreeOffset: 180,
                                              borderData: FlBorderData(
                                                show: false,
                                              ),
                                              sectionsSpace: 0,
                                              centerSpaceRadius: 60,
                                              sections: showingSections()),
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Center(
                                            child: Text(
                                          '$nbTotal',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: MaterialButton(
                                color: Theme.of(context).accentColor,
                                child: Text(
                                  "Soumettre",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  _fbKey.currentState.save();
                                  if (_fbKey.currentState.validate()) {
                                    //print(_fbKey.currentState.fields['adresse'].currentState.value);
                                    //print (_date.text);
                                    //print(_description.text);
                                    //print(_specifyTextFieldKey.currentState.value);

                                    if (_image != null) {
                                      String adresse = _fbKey
                                                  .currentState
                                                  .fields['adresse']
                                                  .currentState
                                                  .value ==
                                              "Autre"
                                          ? _specifyTextFieldKey
                                              .currentState.value
                                          : _fbKey
                                              .currentState
                                              .fields['adresse']
                                              .currentState
                                              .value;

                                      List<Formule> formules = List<Formule>();

                                      formulesWidgets.forEach((f) {
                                        if (f is CardForm) {
                                          if (f.fbKey.currentState.validate()) {
                                            formules.add(Formule(
                                                title: f
                                                    .fbKey
                                                    .currentState
                                                    .fields['nom']
                                                    .currentState
                                                    .value,
                                                prix: int.parse(f
                                                    .fbKey
                                                    .currentState
                                                    .fields['prix']
                                                    .currentState
                                                    .value),
                                                nombreDePersonne: int.parse(f
                                                    .fbKey
                                                    .currentState
                                                    .fields['nb']
                                                    .currentState
                                                    .value),
                                                id: f.numero.toString()));
                                          } else {
                                            showSnackBar(
                                                'Corriger la formule n°${f.numero}',
                                                context);
                                          }
                                        }
                                      });

                                      if (formules.length ==
                                          formulesWidgets.length / 2) {
                                        db.uploadEvent(
                                            _dateDebut,
                                            _dateFin,
                                            adresse,
                                            _title.text,
                                            _description.text,
                                            _image,
                                            formules,
                                            context);
                                      }

                                      //Navigator.pop(context);
                                    } else {
                                      showSnackBar(
                                          'Il manque le Flyer', context);
                                    }
                                  } else {
                                    print(_fbKey.currentState.value);
                                    print("validation failed");
                                    showSnackBar(
                                        'formulaire non valide', context);
                                  }
                                },
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              child: MaterialButton(
                                color: Theme.of(context).accentColor,
                                child: Text(
                                  "Recommencer",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  _fbKey.currentState.reset();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    ));
  }

  InputDecoration buildInputDecoration(BuildContext context, String labelText) {
    return InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  width: 2),
                              borderRadius: BorderRadius.circular(25.0)),
                          labelText: labelText,
                          labelStyle: Theme.of(context).textTheme.button,
                          border: InputBorder.none,
                          errorStyle: Theme.of(context).textTheme.button,
                        );
  }

  void showSnackBar(String val, BuildContext context) {
    Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 3),
        content: Text(
          val,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        )));
  }
}

class CardForm extends StatefulWidget {
  final int numero;

  final Function onChangedNbPersonne;
  final GlobalKey<FormBuilderState> fbKey = GlobalKey();

  CardForm(this.numero, this.onChangedNbPersonne);

  @override
  _CardFormState createState() => _CardFormState();
}

class _CardFormState extends State<CardForm> {
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      color: Colors.green,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
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
          key: widget.fbKey,
          autovalidate: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                'Formule n° ${widget.numero}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(
                height: 10,
              ),
              FormBuilderTextField(
                attribute: 'nom',
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(25.0)),
                  labelText: 'Nom',
                  labelStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none,
                  icon: Icon(
                    FontAwesomeIcons.clipboardList,
                    size: 22.0,
                    color: Colors.white,
                  ),
                  errorStyle: TextStyle(color: Colors.white),
                ),
                style: TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                onChanged: (value) {
                  widget.fbKey.currentState.save();
                },
                keyboardType: TextInputType.text,
                validators: [
                  FormBuilderValidators.required(errorText: 'Champs requis')
                ],
              ),
              SizedBox(
                height: 10,
              ),
              FormBuilderTextField(
                attribute: 'prix',
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(25.0)),
                  labelText: 'Prix',
                  labelStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none,
                  icon: Icon(
                    FontAwesomeIcons.moneyBillWave,
                    size: 22.0,
                    color: Colors.white,
                  ),
                  errorStyle: TextStyle(color: Colors.white),
                ),
                style: TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                onChanged: (value) {
                  widget.fbKey.currentState.save();
                },
                keyboardType: TextInputType.number,
                validators: [
                  FormBuilderValidators.required(errorText: 'Champs requis')
                ],
              ),
              SizedBox(
                height: 10,
              ),
              FormBuilderTextField(
                attribute: 'nb',
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(25.0)),
                  labelText: 'Nombre de personne par formule',
                  labelStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none,
                  icon: Icon(
                    FontAwesomeIcons.users,
                    size: 22.0,
                    color: Colors.white,
                  ),
                  errorStyle: TextStyle(color: Colors.white),
                ),
                style: TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                onChanged: (value) {
                  if (widget.onChangedNbPersonne != null) {
                    widget.fbKey.currentState.save();
                    widget.onChangedNbPersonne('${widget.numero}/$value');
                  }
                },
                keyboardType: TextInputType.number,
                validators: [
                  FormBuilderValidators.required(errorText: 'Champs requis')
                ],
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
