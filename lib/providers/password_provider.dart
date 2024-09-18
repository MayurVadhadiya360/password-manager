import 'dart:developer' as dev;
import 'dart:math';

import 'package:favicon/favicon.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:password_manager/providers/password_model.dart';
import 'package:password_manager/services/db_service.dart';
import 'package:uuid/uuid.dart';

class PasswordProvider extends ChangeNotifier {
  // User _user = FirebaseAuth.instance.currentUser!;
  Uuid _uuid = Uuid();
  List<PasswordModel> passwords = [];
  bool isLoading = false;

  PasswordProvider() {
    fetchPassword();

    // add_password(
    //   site: "github.com",
    //   username: "mayurvadhadiya5@gmail.com",
    //   password: "DragonBallSuper@123",
    //   note: "Some note",
    // );
    // add_password(
    //   site: "instagram.com",
    //   username: "6354464807",
    //   password: "Mayur@63544",
    // );
    // add_password(
    //   site: "https://leetcode.com/accounts/signup/",
    //   username: "Mayur1304",
    //   password: "Mayur@leetcode123",
    // );
  }

  Future<void> fetchPassword() async {
    isLoading = true;
    notifyListeners();
    List<Map<String, dynamic>> passwordMaps = await DBService.getPasswords();

    List<PasswordModel> tempPasswords = [];

    for (var map in passwordMaps) {
      tempPasswords.add(PasswordModel.fromMap(map));
    }

    passwords = tempPasswords;
    isLoading = false;
    notifyListeners();
  }

  Future<void> add_password({
    required String site,
    required String username,
    required String password,
    String? note,
  }) async {
    String id = _uuid.v4();
    String baseUrl = _extractBaseUrl(site);
    String? faviconUrl = await fetchFavicon(site);
    User _user = FirebaseAuth.instance.currentUser!;

    if (baseUrl == 'Invalid URL') {
      // App name or other maybe
      baseUrl = site;
    }

    PasswordModel newPassword = PasswordModel.fromMap({
      "id": id,
      "uid": _user.uid,
      "site": baseUrl,
      "username": username,
      "password": password,
      "faviconUrl": faviconUrl,
      "note": note
    });

    bool success = await DBService.savePassword(newPassword);
    if (success) {
      passwords.add(newPassword);
    }
    notifyListeners();
  }

  Future<void> update_password({
    required String id,
    required String site,
    required String username,
    required String password,
    String? note,
  }) async {
    String baseUrl = _extractBaseUrl(site);
    String? faviconUrl = await fetchFavicon(site);
    User _user = FirebaseAuth.instance.currentUser!;

    if (baseUrl == 'Invalid URL') {
      // App name or other maybe
      baseUrl = site;
    }

    int updateAtIndex = passwords.indexWhere((element) => element.id == id);
    PasswordModel updatedPassword = PasswordModel.fromMap({
      "id": id,
      "uid": _user.uid,
      "site": baseUrl,
      "username": username,
      "password": password,
      "faviconUrl": faviconUrl,
      "note": note
    });
    bool success = await DBService.savePassword(updatedPassword);
    if (success) {
      passwords[updateAtIndex] = updatedPassword;
    }
    notifyListeners();
  }

  Future<void> delete_password(String id) async {
    bool success = await DBService.deletePassword(id);
    if (success) {
      passwords.removeWhere((element) => element.id == id);
    }
    notifyListeners();
  }

  String _extractBaseUrl(String url) {
    try {
      Uri uri = Uri.parse(url);
      // Add "https://" if the URL does not contain a scheme
      if (!uri.hasScheme) {
        uri = Uri.parse('https://${url.trim()}');
      }
      dev.log(uri.host);
      return (uri.host.isNotEmpty) ? uri.host : "Invalid URL";
    } catch (e) {
      dev.log("Invalid URL: ${e.toString()}");
      return 'Invalid URL'; // Handle invalid URLs or any parsing errors
    }
  }

  String _extractSiteUrl(String url) {
    try {
      Uri uri = Uri.parse(url);

      // Add "https://" if the URL does not contain a scheme
      if (!uri.hasScheme) {
        uri = Uri.parse('https://${url.trim()}');
      }
      dev.log("message");

      if (uri.hasScheme && uri.host.isNotEmpty) {
        return '${uri.scheme}://${uri.host}';
      } else {
        return 'Invalid URL'; // Handle cases where scheme or host is missing
      }
    } catch (e) {
      dev.log("Invalid URL: ${e.toString()}");
      return 'Invalid URL'; // Handle invalid URLs or any parsing errors
    }
  }

  Future<String?> fetchFavicon(String url) async {
    String siteUrl = _extractSiteUrl(url);

    if (siteUrl == 'Invalid URL') {
      return null;
    }

    bool _isSupportedImage(String url) {
      // Check if the URL ends with a supported image extension
      return url.endsWith('.png') ||
          url.endsWith('.ico') ||
          url.endsWith('.jpg') ||
          url.endsWith('.jpeg');
    }

    try {
      var favicons = await FaviconFinder.getAll(siteUrl);
      Favicon favicon = favicons.firstWhere(
        (element) => _isSupportedImage(element.url),
        orElse: () => Favicon(""),
      );
      // if (favicon.url == "") return null;
      return favicon.url;
      // return (favicon.url.isNotEmpty) ? favicon.url : null;
    } catch (e) {
      dev.log(e.toString());
      return null;
    }
  }

  String generateSecurePassword(int length) {
    if (length < 4) {
      length = 4;
    }
    final Random random = Random.secure();

    String _getRandomChar(String chars) {
      return chars[random.nextInt(chars.length)];
    }

    String _shuffleString(String input) {
      List<String> chars = input.split('');
      chars.shuffle(Random.secure());
      return chars.join('');
    }

    const String lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const String uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String numbers = '0123456789';
    const String specialChars = '!@#%&*_';

    // Ensure the password contains at least one character from each category
    String password = '';
    password += _getRandomChar(lowercase);
    password += _getRandomChar(uppercase);
    password += _getRandomChar(numbers);
    password += _getRandomChar(specialChars);

    // Fill the remaining length with random characters from all categories
    String allChars = lowercase + uppercase + numbers + specialChars;
    for (int i = password.length; i < length; i++) {
      password += _getRandomChar(allChars);
    }

    // Shuffle the password to ensure randomness
    return _shuffleString(password);
  }
}
