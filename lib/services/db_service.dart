import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
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
        msg: "Something went wrong. Try again",
        status: "error",
      );
      log(error.toString());
      success = false;
    });
    return success;
  }

  static Future<List<Map<String, dynamic>>> getPasswords(String uid) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("Passwords")
          .where(
            'uid',
            isEqualTo: uid,
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

  static Future<bool> saveUserData(
      String uid, String username, String email) async {
    bool success = false;
    await _db.collection('Users').doc(uid).set({
      "uid": uid,
      "username": username,
      "email": email,
      "pwd_len": 16,
    }).whenComplete(() {
      success = true;
    }).catchError((error, stackTrace) {
      ToastMsg.showToastMsg(
        msg: "Something went wrong. Try again",
        status: "error",
      );
      log(error.toString());
      success = false;
    });
    return success;
  }

  static Future<Map<String, dynamic>> getUserData(String uid) async {
    Map<String, dynamic> userData = {};
    await _db.collection('Users').doc(uid).get().then((doc) {
      if (doc.exists) {
        userData = doc.data() as Map<String, dynamic>;
        log("User data: $userData");
      }
    }).catchError((error, stackTrace) {
      log("Failed to get user data: $error");
      ToastMsg.showToastMsg(msg: "Failed to get user data!", status: "error");
    });
    return userData;
  }

  static Future<bool> updatePswLen(String uid, int pwdLen) async {
    bool success = false;
    await _db.collection('Users').doc(uid).update({
      "pwd_len": pwdLen,
    }).whenComplete(() {
      success = true;
    }).catchError((error, stackTrace) {
      ToastMsg.showToastMsg(
        msg: "Failed to update user data!",
        status: "error",
      );
      log("Failed to get user data: $error");
      success = false;
    });
    return success;
  }
}
