import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:vanevents/models/formule.dart';

class Participant{
  GlobalKey<FormBuilderState> fbKey;
  int index;
  Formule formule;
  String nom;
  String prenom;


  Participant(this.fbKey,this.index,this.formule, this.nom, this.prenom);
  

}