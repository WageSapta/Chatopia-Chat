import 'package:chatopia/provider/auth_provider.dart';
import 'package:chatopia/utils/get.dart';
import 'package:chatopia/widgets/my_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/app_state.dart';
import '../services/fcm_service.dart';
import '../utils/navigator.dart';
import '../utils/routes.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const DrawerHeader(child: Icon(Icons.person_rounded, size: 60)),
            ListTile(
              minLeadingWidth: 30,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: const Icon(Icons.account_circle_rounded, size: 25),
              title: const Text(
                "Account",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 17,
                ),
              ),
              onTap: () {
                Screen.toNamed(Routes.account);
              },
            ),
            ListTile(
              minLeadingWidth: 30,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: const Icon(Icons.group_rounded, size: 25),
              title: const Text(
                "Friends",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 17,
                ),
              ),
              onTap: () {
                Screen.toNamed(Routes.friends);
              },
            ),
            ListTile(
              minLeadingWidth: 30,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: const Icon(Icons.favorite, size: 25),
              title: const Text(
                "Activity",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 17,
                ),
              ),
              onTap: () {
                Screen.toNamed(Routes.activity);
              },
            ),
            ListTile(
              minLeadingWidth: 30,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: const Icon(Icons.logout_rounded, size: 25),
              title: const Text(
                "Logout",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 17,
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return MyDialog(
                      title: "Are you sure?",
                      content: "Do you want to logout?",
                      buttonText: 'Logout',
                      buttonColor: Colors.redAccent[700],
                      onPressed: () async {
                        if (!await InternetConnection().hasInternetAccess) {
                          Get.fToastShow("no internet",
                              gravity: ToastGravity.BOTTOM);
                        } else {
                          final prefs = await SharedPreferences.getInstance();
                          await AppState().setIsOnline(isonline: false);
                          await FcmService.deleteToken(prefs.getString("id")!);
                          prefs.clear();
                          await AuthProvider().signOut().then((e) =>
                              Screen.pushNamedAndRemoveUntil(Routes.auth));
                        }
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
