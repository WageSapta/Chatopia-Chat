import 'package:flutter/material.dart';

class MyLoading extends StatelessWidget {
  final bool? transparent;
  const MyLoading({super.key, this.transparent = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: transparent! ? Colors.transparent : Colors.black.withOpacity(.4),
      height: double.infinity,
      width: double.infinity,
      child: const CircularProgressIndicator(),
    );
  }
}
