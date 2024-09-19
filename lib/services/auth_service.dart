import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // creating a new account
  static Future<String> createAccountWithEmail(
      String email, String password) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return "Account Created";
    } on FirebaseAuthException catch (e) {
      log(e.message.toString());
      return "Failed to signup";
    } catch (e) {
      log(e.toString());
      return "Failed to signup";
    }
  }

  // login with email password method
  static Future<String> loginWithEmail(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return "Login Successful";
    } on FirebaseAuthException catch (e) {
      log(e.message.toString());
      return "Failed to login";
    } catch (e) {
      log(e.toString());
      return "Failed to login";
    }
  }

  // sign in with google
  static Future<String> signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      return "Login Successful";
    } on FirebaseAuthException catch (e) {
      log(e.message.toString());
      return "Failed to sign in with google";
    } catch (e) {
      log(e.toString());
      return "Failed to sign in with google";
    }
  }

  // forfot password
  static Future<String> forgotPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return "Password reset link sent to your email!";
    } catch (e) {
      log(e.toString());
      return "Failed to sent password reset link";
    }
  }

  // logout the user
  static Future<String> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      return "logged out";
    } catch (e) {
      log(e.toString());
      return "Failed to logout";
    }
  }

  // check whether the user is sign in or not
  static Future<bool> isLoggedIn() async {
    var user = FirebaseAuth.instance.currentUser;
    return user != null;
  }
}
