import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastMsg {
  static void showToastMsg({
    required String msg,
    String? status,
    Color? backgroundColor,
    Color? textColor,
  }) {
    switch (status) {
      case "success":
        {}
        break;
      case "error":
        {
          backgroundColor = Colors.red;
          textColor = Colors.white;
        }
        break;
      case "warning":
        {
          backgroundColor = Colors.orange;
          textColor = Colors.white;
        }
        break;
      default:
        break;
    }

    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: msg,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }
}
