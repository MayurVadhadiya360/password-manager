import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordEncryptor {
  // Helper function to generate a 32-byte key from the user's UID using SHA-256
  static Key _generateKeyFromUID(String uid) {
    final bytes = utf8.encode(uid); // Convert UID to bytes
    final digest = sha256.convert(bytes); // Hash the bytes using SHA-256
    return Key(
        Uint8List.fromList(digest.bytes)); // Use the hashed bytes as the key
  }

  // Function to convert a string to a fixed 16-byte IV
  static IV _generateIVFromUID(String uid) {
    // Hash the input string using SHA-256
    final bytes = utf8.encode(uid); // Convert input to bytes
    final digest = sha256.convert(bytes); // Hash the bytes using SHA-256

    // Take the first 16 bytes of the hash as the IV
    final ivBytes = Uint8List.fromList(digest.bytes.sublist(0, 16));
    
    return IV(ivBytes); // Create and return an IV from the first 16 bytes
  }

  static String encrypt(String value) {
    User _user = FirebaseAuth.instance.currentUser!;

    // Generate a 32-byte key and 
    // initialization vector (IV) using the user's UID
    final key = _generateKeyFromUID(_user.uid);
    final iv = _generateIVFromUID(_user.uid);

    // Create an encrypter with AES algorithm
    final encrypter = Encrypter(AES(key));

    // Encrypt the text
    final encrypted = encrypter.encrypt(value, iv: iv);
    // print('Encrypted: ${encrypted.base64}');
    return encrypted.base64;
  }

  static String decrypt(String value) {
    User _user = FirebaseAuth.instance.currentUser!;

    // Generate a 32-byte key and 
    // initialization vector (IV) using the user's UID
    final key = _generateKeyFromUID(_user.uid);
    final iv = _generateIVFromUID(_user.uid);

    // Create an encrypter with AES algorithm
    final encrypter = Encrypter(AES(key));

    final encrypted = Encrypted.fromBase64(value); // Decode from base64

    // Decrypt the text
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    // print('Decrypted: $decrypted');
    return decrypted;
  }
}
