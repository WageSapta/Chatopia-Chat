import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/account_service.dart';
import '../utils/get.dart';

class AccountProvider extends ChangeNotifier {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _loading = false;
  bool _loadingProfile = false;
  bool _isDeleteProfile = false;
  File? _profile;
  String _imgTemporary = "";

  GlobalKey<FormState> get formKey => _formKey;
  String get imgTemporary => _imgTemporary;
  set imgTemporary(String val) {
    _imgTemporary = val;
    notifyListeners();
  }

  bool get isDeleteProfile => _isDeleteProfile;
  set isDeleteProfile(bool val) {
    _isDeleteProfile = val;
    notifyListeners();
  }

  bool get loading => _loading;
  set loading(bool val) {
    _loading = val;
    notifyListeners();
  }

  bool get loadingProfile => _loadingProfile;

  set loadingProfile(bool val) {
    _loadingProfile = val;
    notifyListeners();
  }

  TextEditingController get nameController => _nameController;

  File? get profile => _profile;

  // set nameController(val) {
  //   _nameController = val;
  //   notifyListeners();
  // }

  set profile(val) {
    _profile = val;
    notifyListeners();
  }

  Future deleteImgTemporary() async {
    isDeleteProfile = true;
    try {
      imgTemporary = "";
      profile = null;
    } catch (e) {
      log(e.toString());
    }
  }

  Future deleteProfile() async {
    try {
      await AccountService().deleteProfile();
    } catch (e) {
      log('Error deleting image: $e');
    }
  }

  void disposeValues() {
    if (_profile != null) {
      profile = null;
    }
    if (Get.user!.name != _nameController.text) {
      _nameController.clear();
    }
  }

  Future getImgFromGallery() async {
    loadingProfile = true;
    try {
      File nameFile = await AccountService().imgFromGallery();
      profile = nameFile;
    } catch (e) {
      log("No image selected");
    }
    loadingProfile = false;
  }

  Future getProfile() async {
    try {
      return await AccountService().getProfile();
    } catch (e) {
      log('Error get image: $e');
    }
  }

  Future save() async {
    loading = true;
    try {
      String? imageUrl;
      if (_isDeleteProfile && Get.user!.profile!.isNotEmpty) {
        await deleteProfile();
        isDeleteProfile = false;
      }
      if (_profile != null) {
        // update profile to firebase
        await updateProfile(_profile!);
        // get profile from gallery
        imageUrl = await getProfile();
        // set img temporary
        imgTemporary = imageUrl!;
      }
      var myFirestore =
          FirebaseFirestore.instance.collection("users").doc(Get.user!.id);
      // update user
      await myFirestore.update({
        "name": _nameController.text.trim(),
        "profile": imageUrl ?? imgTemporary,
      });
      // set user data from firebase
      var myMap = await myFirestore.get();
      // set data local
      await Get.setUserDataToLocal(myMap.data()!);
    } catch (e) {
      log(e.toString());
    } finally {
      loading = false;
    }
  }

  setBgChild() {
    if (_loadingProfile) {
      return const CircularProgressIndicator(color: Colors.deepPurple);
    }
    if (_profile == null && _imgTemporary.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return Icon(Icons.person, size: constraints.maxWidth / 2.5);
        },
      );
    }
    return null;
  }

  setBgProfile() {
    if (_profile != null) {
      return FileImage(_profile!);
    }
    if (_imgTemporary.isNotEmpty) {
      return NetworkImage(_imgTemporary);
    }
    // if (Get.user!.profile!.isNotEmpty) {ss
    //   return NetworkImage(Get.user!.profile!);
    // }
    return null;
  }

  Future updateProfile(File newImage) async {
    try {
      await AccountService().updateProfile(newImage);
    } catch (e) {
      log('Error updating image: $e');
    }
  }
}
