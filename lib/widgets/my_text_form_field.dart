import 'package:chatopia/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool? obsecureText;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;
  final void Function(String?)? onFieldSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextInputFormatter? textInputFormatter;
  final String? initialValue;
  final int? maxLines;
  final TextAlignVertical? textAlignVertical;
  final bool? readOnly;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  const MyTextField({
    Key? key,
    this.controller,
    this.hintText,
    this.obsecureText = false,
    this.onSaved,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.textInputFormatter,
    this.initialValue,
    this.maxLines = 1,
    this.textAlignVertical,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<TextInputFormatter> formatters = [];
    if (textInputFormatter != null) {
      formatters.add(textInputFormatter!);
    }
    return TextFormField(
      textAlignVertical: TextAlignVertical.top,
      maxLines: maxLines,
      textAlign: TextAlign.start,
      initialValue: initialValue,
      validator: validator,
      onSaved: onSaved,
      onFieldSubmitted: onFieldSubmitted,
      textInputAction: textInputAction,
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obsecureText!,
      inputFormatters: formatters,
      readOnly: readOnly!,
      scrollPhysics: const ClampingScrollPhysics(),
      decoration: InputDecoration(
        isDense: true,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        hintText: hintText,
        fillColor: context.isDarkMode ? Colors.deepPurple[200]!.withOpacity(.1) : Colors.deepPurple[100]!.withOpacity(.3),
        constraints: const BoxConstraints(minHeight: 10),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            color: Colors.transparent,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            color: Colors.transparent,
          ),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            color: Colors.red,
          ),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
