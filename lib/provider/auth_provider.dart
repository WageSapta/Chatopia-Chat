import 'dart:developer';

import 'package:chatopia/services/app_state.dart';
import 'package:chatopia/services/fcm_service.dart';
import 'package:chatopia/utils/navigator.dart';
import 'package:chatopia/utils/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../utils/get.dart';

class AuthProvider extends ChangeNotifier {
  final authService = AuthService();
  final userService = UserService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoginPage = true;
  bool _isLoading = false;

  TextEditingController get confirmPasswordController =>
      _confirmPasswordController;
  TextEditingController get emailController => _emailController;
  GlobalKey<FormState> get formKey => _formKey;
  // getter
  bool get isLoading => _isLoading;
  // setter
  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  bool get isLoginPage => _isLoginPage;
  set isLoginPage(bool val) {
    _isLoginPage = val;
    notifyListeners();
  }

  TextEditingController get nameController => _nameController;

  TextEditingController get passwordController => _passwordController;

  Future anotherMethods(User user) async {
    final prefs = await SharedPreferences.getInstance();
    // convert uid to hascode
    var id = user.uid.hashCode.toString();
    // set data when sign up
    if (!_isLoginPage) {
      UserModel data = UserModel(
        id: id,
        name: _nameController.text,
        email: _emailController.text,
      );
      // save to firestore firebase
      await userService.saveUser(data);
    }
    // save notification token
    await FcmService.saveToken(id);
    // get data after SignIn or SignUp
    Map<String, dynamic> myData = await userService.getUser(id);
    // set myData to model local data
    await Get.setUserDataToLocal(myData);
    // save shared login
    prefs.setBool('isLogin', true);
    // save shared with uid has convert to hscode
    prefs.setString('id', id);
    // set is online
    AppState().setIsOnline(isonline: true);
    // push to chats page
    Screen.pushReplacementNamed(Routes.chats);
  }

  void disposeValues() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
  }

  Future signIn() async {
    isLoading = true;
    try {
      User user = await authService.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      await anotherMethods(user);
    } on FirebaseAuthException catch (e) {
      Get.snackBar(text: Get.firebaseAuthException(e));
    } finally {
      isLoading = false;
    }
  }

  Future signOut() async {
    isLoading = true;
    try {
      await authService.signOut();
    } catch (e) {
      log(e.toString());
    }
    isLoading = false;
  }

  Future signUp() async {
    isLoading = true;
    try {
      User user = await authService.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      await anotherMethods(user);
    } on FirebaseAuthException catch (e) {
      Get.snackBar(text: Get.firebaseAuthException(e));
    } finally {
      isLoading = false;
      isLoginPage = true;
    }
  }

 
}
