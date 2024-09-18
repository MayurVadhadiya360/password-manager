import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:password_manager/providers/password_model.dart';
import 'package:password_manager/services/password_encryptor.dart';
import 'package:password_manager/utils/toast_msg.dart';

class DBService {
  static final _db = FirebaseFirestore.instance;

  static Future<bool> savePassword(PasswordModel password) async {
    Map<String, dynamic> tempPassword = password.toMap();

    tempPassword["password"] =
        PasswordEncryptor.encrypt(tempPassword["password"]);

    bool success = false;
    await _db
        .collection("Passwords")
        .doc(password.id)
        .set(tempPassword)
        .whenComplete(() {
      ToastMsg.showToastMsg(msg: "Password Saved!");
      success = true;
      // ignore: body_might_complete_normally_catch_error
    }).catchError((error, stackTrace) {
      ToastMsg.showToastMsg(
          msg: "Something went wrong. Try again", status: "error");
      log(error.toString());
      success = false;
    });
    return success;
  }

  static Future<List<Map<String, dynamic>>> getPasswords() async {
    User _user = FirebaseAuth.instance.currentUser!;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("Passwords")
          .where(
            'uid',
            isEqualTo: _user.uid,
          )
          .get();

      List<Map<String, dynamic>> passwords = [];
      // Iterate through the results
      for (var doc in querySnapshot.docs) {
        log(doc.id); // Document ID (FireStore ID)
        log(doc.data().toString()); // Document Data (as a Map)
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data["password"] = PasswordEncryptor.decrypt(data["password"]);
        passwords.add(data);
      }
      ToastMsg.showToastMsg(msg: "Retrieved password from cloud!");
      return passwords;
    } catch (e) {
      ToastMsg.showToastMsg(
        msg: "Failed to retrieved password!",
        status: "error",
      );
      log("error: ${e.toString()}");
      return [];
    }
  }

  static Future<bool> deletePassword(String docId) async {
    bool success = false;
    await FirebaseFirestore.instance
        .collection("Passwords") // Specify the collection
        .doc(docId) // Specify the document by its ID
        .delete()
        .then((_) {
      log("Document with ID: $docId deleted successfully.");
      ToastMsg.showToastMsg(msg: "Password deleted successfully!");
      success = true;
    }).catchError((error) {
      log("Failed to delete document: $error");
      ToastMsg.showToastMsg(msg: "Failed to delete password!", status: "error");
      success = false;
    });
    return success;
  }
}
