import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  String userId = "";

  setUserId(userId) {
    this.userId = userId;
  }
}
