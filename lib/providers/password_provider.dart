import 'package:flutter/material.dart';
import 'package:password_manager/providers/password_model.dart';

class PasswordProvider extends ChangeNotifier {
  List<PasswordModel> passwords = [];

  PasswordProvider() {
    passwords = fetchPassword();
  }

  List<PasswordModel> fetchPassword() {

    return [

      PasswordModel.fromMap({
        "id": "id1",
        "site": "site1",
        "username": "username1",
        "password": "password1",
        "note": "note1"
      }),
      PasswordModel.fromMap({
        "id": "id2",
        "site": "site2",
        "username": "username2",
        "password": "password2",
        "note": "note2"
      }),
      PasswordModel.fromMap({
        "id": "id3",
        "site": "site",
        "username": "username",
        "password": "password",
        "note": "note"
      }),
      PasswordModel.fromMap({
        "id": "id4",
        "site": "site",
        "username": "username",
        "password": "password",
        "note": "note"
      }),
      PasswordModel.fromMap({
        "id": "id5",
        "site": "site",
        "username": "username",
        "password": "password",
        "note": "note"
      }),
      

    ];
  }
}
