import 'package:chatopia/utils/navigator.dart';
import 'package:flutter/material.dart';

import '../services/add_service.dart';
import '../utils/get.dart';

class AddProvider extends ChangeNotifier {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  bool _loading = false;
  String _textError = "";

  GlobalKey<FormState> get formKey => _formKey;
  bool get loading => _loading;
  set loading(bool val) {
    _loading = val;
    notifyListeners();
  }
  TextEditingController get searchController => _searchController;

  String get textError => _textError;

  set textError(String val) {
    _textError = val;
    notifyListeners();
  }

  Future addFriend() async {
    loading = true;
    try {
      await FriendService().addFriend(searchController.text);
      Screen.back();
      Get.snackBar(
        text: "Successfully added, check in activity",
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      errors(e.toString().substring(11));
    }
    loading = false;
  }

  void disposeValues() {
    _textError = "";
    _searchController.clear();
  }

  void errors(String e) {
    if (e == "Is me!" ||
        e == "Friend not found" ||
        e == "Wait for confirmation, check in activity" ||
        e == "Friend already exist") {
      textError = e;
      return;
    }
    textError = "Error";
  }
}
