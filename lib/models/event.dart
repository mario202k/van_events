import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:vanevents/models/formule.dart';

class Event {
  final String id;
  final String titre;
  final String description;
  final String imageUrl;
  final Timestamp dateDebut;
  final Timestamp dateFin;

  final ImageProvider imageProvider;


  Event({this.id, this.titre, this.description, this.imageUrl, this.dateDebut,
      this.dateFin, this.imageProvider});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': titre,
      'description': description,
      'imageUrl': imageUrl,
      'dateDebut': dateDebut,
      'dateFin': dateFin,
    };
  }

  factory Event.fromMap(Map data, String documentId) {
    return Event(
        id: documentId,
        titre: data['titre'] ?? '',
        description: data['description'] ?? '',
        imageUrl: data['imageUrl']  ?? '',
        dateDebut: data['dateDebut']  ?? '',
        dateFin: data['dateFin']  ?? '',
        imageProvider : NetworkImage(data['imageUrl'],),
    );
  }
}