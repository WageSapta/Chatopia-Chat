import 'package:chatopia/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          return Stack(
            children: [
              GestureDetector(
                onTap: () => Get.hideKeyboard(),
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Form(
                        key: auth.formKey,
                        child: Column(
                          children: [
                            const Icon(Icons.message, size: 90),
                            const SizedBox(height: 10),
                            H1("W E L C O M E"),
                            const SizedBox(height: 5),
                            H6("Please ${auth.isLoginPage ? 'Sign In' : 'Sign Up'} to use Chatopia"),
                            const SizedBox(height: 30.0),
                            Visibility(
                              visible: !auth.isLoginPage,
                              child: Column(
                                children: [
                                  MyTextField(
                                    textInputAction: TextInputAction.next,
                                    controller: auth.nameController,
                                    keyboardType: TextInputType.text,
                                    hintText: "Name",
                                    validator: (e) {
                                      if (e!.isEmpty) {
                                        return '*Name cannot be empty';
                                      }
                                      if (e.length < 3) {
                                        return "*Name must have at least 3 characters";
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                            MyTextField(
                              textInputFormatter:
                                  FilteringTextInputFormatter.deny(
                                      RegExp(r'\s')),
                              textInputAction: TextInputAction.next,
                              controller: auth.emailController,
                              keyboardType: TextInputType.emailAddress,
                              hintText: "Email",
                              validator: (e) {
                                if (e!.isEmpty) {
                                  return '*Email cannot be empty';
                                }
                                if (!e.contains("@gmail.com")) {
                                  return "*Invalid email";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            MyTextField(
                              textInputFormatter:
                                  FilteringTextInputFormatter.deny(
                                      RegExp(r'\s')),
                              textInputAction: auth.isLoginPage
                                  ? TextInputAction.done
                                  : TextInputAction.next,
                              controller: auth.passwordController,
                              keyboardType: TextInputType.text,
                              obsecureText: true,
                              hintText: "Password",
                              validator: (e) {
                                if (e!.isEmpty) {
                                  return '*Password cannot be empty';
                                }
                                if (e.length < 6 && !auth.isLoginPage) {
                                  return '*Passwords must have at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            Visibility(
                              visible: !auth.isLoginPage,
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  MyTextField(
                                    textInputFormatter:
                                        FilteringTextInputFormatter.deny(
                                            RegExp(r'\s')),
                                    textInputAction: TextInputAction.done,
                                    controller: auth.confirmPasswordController,
                                    keyboardType: TextInputType.text,
                                    obsecureText: true,
                                    hintText: "Confirm Password",
                                    validator: (e) {
                                      if (e!.isEmpty) {
                                        return "*Confirm password cannot be empty";
                                      }
                                      if (auth.passwordController.text != e) {
                                        return "*Make sure the password match";
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () => Screen.toNamed(Routes.reset),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(top: 5, bottom: 20),
                                  child: H7('Forgot Password?'),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 50,
                              width: MediaQuery.of(context).size.width,
                              child: FilledButton(
                                onPressed: () async {
                                  Get.hideKeyboard();
                                  if (auth.formKey.currentState!.validate()) {
                                    if (auth.isLoginPage) {
                                      auth.signIn();
                                    } else {
                                      auth.signUp();
                                    }
                                  }
                                },
                                child: Text(
                                    auth.isLoginPage ? "Sign In" : "Sign Up"),
                              ),
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                H6("${auth.isLoginPage ? 'Don\'t have an account?' : 'Have an account?'}  "),
                                GestureDetector(
                                  onTap: () {
                                    auth.nameController.clear();
                                    auth.emailController.clear();
                                    auth.passwordController.clear();
                                    auth.confirmPasswordController.clear();
                                    auth.formKey.currentState!.reset();
                                    Get.hideKeyboard();
                                    auth.isLoginPage = !auth.isLoginPage;
                                  },
                                  child: Text(
                                    auth.isLoginPage ? "Sign Up" : "Sign In",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(visible: auth.isLoading, child: const MyLoading())
            ],
          );
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    context.read<AuthProvider>().disposeValues();
    super.didChangeDependencies();
  }
}
