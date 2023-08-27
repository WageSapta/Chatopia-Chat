import 'dart:io';

import 'package:chatopia/utils/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AccountService {
  final _storage = FirebaseStorage.instance;

  Future deleteProfile() async {
    Reference firebaseStorageRef =
        _storage.ref().child("images/profiles/${Get.user!.id}");
    await firebaseStorageRef.delete();
  }

  Future getProfile() async {
    Reference firebaseStorageRef =
        _storage.ref().child("images/profiles/${Get.user!.id}");
    return firebaseStorageRef.getDownloadURL();
  }

  Future imgFromGallery() async {
    XFile? pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 60);
    if (pickedFile != null) {
      var file = File(pickedFile.path);
      return file;
    }
  }

  Future updateProfile(newImage) async {
    final destination = 'images/profiles/${Get.user!.id}';
    await _storage.ref(destination).putFile(newImage);
  }
}
