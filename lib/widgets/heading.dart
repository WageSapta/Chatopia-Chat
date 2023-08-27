// ignore_for_file: non_constant_identifier_names, duplicate_ignore

import 'package:flutter/widgets.dart';

Widget H1(
  String text, {
  int? maxLines,
  TextAlign? textAlign,
  FontWeight fontWeight = FontWeight.bold,
}) =>
    Heading(
      text: text,
      fontSize: 24,
      fontWeight: fontWeight,
      maxLines: maxLines,
      textAlign: textAlign,
    );
Widget H2(
  String text, {
  int? maxLines,
  TextAlign? textAlign,
  FontWeight fontWeight = FontWeight.bold,
}) =>
    Heading(
      text: text,
      fontSize: 22,
      fontWeight: fontWeight,
      maxLines: maxLines,
      textAlign: textAlign,
    );
Widget H3(
  String text, {
  int? maxLines,
  TextAlign? textAlign,
  FontWeight fontWeight = FontWeight.w600,
}) =>
    Heading(
      text: text,
      fontSize: 20,
      fontWeight: fontWeight,
      maxLines: maxLines,
      textAlign: textAlign,
    );
Widget H4(
  String text, {
  int? maxLines,
  TextAlign? textAlign,
  FontWeight fontWeight = FontWeight.normal,
}) =>
    Heading(
      text: text,
      fontSize: 18,
      fontWeight: fontWeight,
      maxLines: maxLines,
      textAlign: textAlign,
    );
Widget H5(
  String text, {
  int? maxLines,
  TextAlign? textAlign,
  FontWeight fontWeight = FontWeight.normal,
}) =>
    Heading(
      text: text,
      fontSize: 16,
      fontWeight: fontWeight,
      maxLines: maxLines,
      textAlign: textAlign,
    );
Widget H6(
  String text, {
  int? maxLines,
  TextAlign? textAlign,
  FontWeight fontWeight = FontWeight.normal,
}) =>
    Heading(
      text: text,
      fontSize: 14,
      fontWeight: fontWeight,
      maxLines: maxLines,
      textAlign: textAlign,
    );
Widget H7(
  String text, {
  int? maxLines,
  TextAlign? textAlign,
  FontWeight fontWeight = FontWeight.normal,
}) =>
    Heading(
      text: text,
      fontSize: 12,
      fontWeight: fontWeight,
      maxLines: maxLines,
      textAlign: textAlign,
    );

class Heading extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final int? maxLines;
  final TextAlign? textAlign;

  const Heading({
    super.key,
    required this.text,
    this.fontSize,
    this.fontWeight = FontWeight.bold,
    this.fontFamily,
    this.maxLines = 1,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      style: TextStyle(
        overflow: TextOverflow.ellipsis,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontFamily: fontFamily ?? "Poppins",
      ),
    );
  }
}
