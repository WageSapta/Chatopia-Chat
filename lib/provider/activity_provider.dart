import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ActivityProvider extends ChangeNotifier {
  final ff = FirebaseFirestore.instance;
}
