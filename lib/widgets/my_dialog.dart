import 'package:chatopia/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyDialog extends StatefulWidget {
  final String title;
  final String content;
  final String buttonText;
  final Color? buttonColor;
  final Function()? onPressed;
  const MyDialog({
    super.key,
    required this.title,
    required this.content,
    required this.buttonText,
    this.onPressed,
    this.buttonColor,
  });

  @override
  State<MyDialog> createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  @override
  void initState() {
    super.initState();
    Get.fToast.init(context);
  }

  @override
  Widget build(BuildContext context) {
    var auth = context.watch<AuthProvider>();
    return Stack(
      children: [
        AlertDialog(
          title: H3(widget.title),
          content: Text(widget.content),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Screen.back(),
            ),
            TextButton(
              style: widget.buttonColor == null
                  ? null
                  : ButtonStyle(
                      foregroundColor: MaterialStateColor.resolveWith(
                          (states) => widget.buttonColor!),
                      overlayColor: MaterialStateColor.resolveWith(
                          (states) => widget.buttonColor!.withOpacity(.1)),
                    ),
              onPressed: widget.onPressed,
              child: Text(widget.buttonText),
            ),
          ],
        ),
        Visibility(
          visible: auth.isLoading,
          child: const MyLoading(),
        ),
      ],
    );
  }
}
