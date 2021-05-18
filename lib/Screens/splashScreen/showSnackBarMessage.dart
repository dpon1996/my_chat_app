import 'package:flutter/material.dart';

showSnackBarMessage(
  BuildContext context,
  String msg, {
  Duration duration = const Duration(seconds: 1),
  Color color = Colors.black,
}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: color,
      content: Text(msg),
      duration: duration,
    ),
  );
}
