import 'dart:async';
import 'dart:developer';
import 'package:chatopia/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  bool isTimerActive = false;
  int timerCount = 60;

  void startTimer() {
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (timerCount == 0) {
        setState(() {
          isTimerActive = false;
        });
        timer.cancel();
      } else {
        setState(() {
          timerCount--;
        });
      }
    });
  }

  void forgotPassword() async {
    if (formKey.currentState!.validate()) {
      Get.hideKeyboard();
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: emailController.text,
        );
        setState(() {
          isTimerActive = true;
          timerCount = 60;
        });
        startTimer();
        Get.snackBar(
          text:
              "Success! A password reset link has been sent to your email address",
          duration: const Duration(seconds: 3),
          size: 12,
        );
      } on FirebaseAuthException catch (e) {
        log("Error sending reset password email: $e");
        Get.snackBar(
          text: e.code == "user-not-found"
              ? "Uh-oh! Email not found"
              : "Uh-oh! Something went wrong while sending the reset password link",
          size: 12,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_rounded,
                    size: Get.width / 3,
                  ),
                  const Text(
                    "Enter your email and we'll send you a link to reset your password",
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 30),
                  MyTextField(
                    textInputFormatter:
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    textInputAction: TextInputAction.done,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    hintText: "Email",
                    validator: (e) {
                      if (e!.isEmpty) {
                        return '*Please enter an email address';
                      }
                      if (!e.contains("@gmail.com")) {
                        return "*Please enter a valid email address";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: FilledButton(
                      onPressed: isTimerActive ? null : forgotPassword,
                      child: Text(
                        isTimerActive
                            ? "Resend in $timerCount seconds"
                            : "Send",
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
