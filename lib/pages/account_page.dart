// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables

import 'package:chatopia/provider/account_provider.dart';
import 'package:chatopia/utils/get.dart';
import 'package:chatopia/widgets/my_loading.dart';
import 'package:chatopia/widgets/my_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  AccountProvider? _accProvider;
  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (context, value, child) {
        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                title: const Text("Account"),
                actions: [
                  TextButton(
                      onPressed: () async {
                        if (!(await InternetConnection().hasInternetAccess)) {
                          Get.fToastShow("no internet",
                              gravity: ToastGravity.BOTTOM);
                        } else {
                          if (value.formKey.currentState!.validate()) {
                            await value.save();
                            if (value.profile != null) {
                              value.profile = null;
                            }
                            Get.hideKeyboard();
                            Get.snackBar(text: "Updated");
                          }
                        }
                      },
                      child: const Text("Save")),
                  const SizedBox(width: 10),
                ],
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Form(
                    key: value.formKey,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: value.setBgProfile(),
                          child: value.setBgChild(),
                          backgroundColor: Colors.deepPurple.withOpacity(.1),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () async {
                                await value.getImgFromGallery();
                              },
                              child: const Text("Edit profile"),
                            ),
                            Visibility(
                              visible: value.imgTemporary.isNotEmpty,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.redAccent[700]),
                                onPressed: () async {
                                  await value.deleteImgTemporary();
                                },
                                child: const Text("Delete profile"),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline_rounded, size: 13),
                              SizedBox(width: 5),
                              Text(
                                "ID read only",
                                style: TextStyle(fontSize: 10),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        MyTextField(
                          initialValue: Get.user!.id,
                          hintText: "ID",
                          readOnly: true,
                          suffixIcon: IconButton(
                            onPressed: () {
                              Clipboard.setData(
                                      ClipboardData(text: Get.user!.id))
                                  .then((_) {
                                Get.snackBar(text: "Copied");
                              });
                            },
                            icon: const Icon(Icons.copy),
                          ),
                        ),
                        const SizedBox(height: 10),
                        MyTextField(
                          controller: value.nameController,
                          hintText: "Name",
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          validator: (e) {
                            if (e!.isEmpty) {
                              return "mosok awm gaduwe jeneng nyettt";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: value.loading,
              child: const MyLoading(transparent: true),
            )
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _accProvider!.disposeValues();
    super.dispose();
  }

  @override
  void initState() {
    Get.fToast.init(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _accProvider = Provider.of<AccountProvider>(context, listen: false);
      _accProvider!.nameController.value =
          TextEditingValue(text: Get.user!.name);
      if (Get.user!.profile!.isNotEmpty) {
        _accProvider!.isDeleteProfile = false;
        _accProvider!.imgTemporary = Get.user!.profile!;
      }
    });
    super.initState();
  }
}
