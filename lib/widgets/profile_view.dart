import 'dart:ui';
import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  final Widget child;
  const ProfileView({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          barrierColor: Colors.transparent,
          barrierDismissible: true,
          context: context,
          builder: (context) {
            return BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 6,
                sigmaY: 6,
              ),
              child: AlertDialog(
                insetPadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                backgroundColor: Colors.red,
                elevation: 0,
                shape: const CircleBorder(),
                content: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: child,
                ),
              ),
            );
          },
        );
      },
      child: child,
    );
  }
}
