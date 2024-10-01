import 'dart:io';
import 'dart:math';
import 'dart:developer' as dev;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:password_manager/utils/toast_msg.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'package:url_launcher/url_launcher.dart';

class GoogleSignInArgs {
  const GoogleSignInArgs({
    required this.clientId,
    required this.redirectUri,
    required this.scope,
    required this.responseType,
    // required this.accessType,
    required this.prompt,
    // required this.state,
    required this.nonce,
  });

  /// The OAuth client id of your Google app.
  ///
  /// See https://developers.google.com/identity/gsi/web/guides/get-google-api-clientid.
  final String clientId;

  // The authentication scopes.
  ///
  /// See https://developers.google.com/identity/protocols/oauth2/scopes.
  final String scope;

  /// The authentication response types (e.g. token, id_token, code).
  final String responseType;

  /// A list of prompts to present the user.
  final String prompt;

  /// Cryptographic nonce used to prevent replay attacks.
  ///
  /// It may be required when using an id_token as a response type.
  /// The response from Google should include the same nonce inside the id_token.
  final String nonce;

  /// The URL where the user will be redirected after
  /// completing the authentication in the browser.
  final String redirectUri;
}

String generateNonce({int length = 32}) {
  const characters =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();

  return List.generate(
    length,
    (_) => characters[random.nextInt(characters.length)],
  ).join();
}

Future<void> googleSigninWithWeb() async {
  final signInArgs = GoogleSignInArgs(
    // The OAuth client id of your Google app.
    clientId:
        '653604321113-vni5dt1jmh35nm1d8v28qmbokuogp0ab.apps.googleusercontent.com',
    // The URI to your redirect web page.
    redirectUri:
        'https://mayurvadhadiya360.github.io/password-manager-redirect-url/google_signin_success.html',
    // Basic scopes to retrieve the user's email and profile details.
    scope: [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ].join(' '),
    responseType: 'token id_token',
    // Prompts the user for consent and to select an account.
    prompt: 'select_account consent',
    // Random secure nonce to be checked after the sign-in flow completes.
    nonce: generateNonce(),
  );

  final authUri = Uri(
    scheme: 'https',
    host: 'accounts.google.com',
    path: '/o/oauth2/v2/auth',
    queryParameters: {
      'scope': signInArgs.scope,
      'response_type': signInArgs.responseType,
      'redirect_uri': signInArgs.redirectUri,
      'client_id': signInArgs.clientId,
      'nonce': signInArgs.nonce,
      'prompt': signInArgs.prompt,
    },
  );

  await launchUrl(authUri);
}

// void initializeAppLinksListenStream() {
//   AppLinks().uriLinkStream.listen((uri) async {
//     if (uri.scheme != 'com.password_manager.password_manager') return;
//     if (uri.path != 'app.password_manager.com') return;

//     final authenticationIdToken = uri.queryParameters['id_token'];
//     final authenticationAccessToken = uri.queryParameters['access_token'];

//     // Authentication completed, you may use the access token to
//     // access user-specific data from Google.
//     //
//     // At this step, you may want to verify that the nonce
//     // from the id token matches the one you generated previously.
//     //
//     // Example:
//     // Signing-in with Firebase Auth credentials using the retrieved
//     // id and access tokens.
//     final credential = GoogleAuthProvider.credential(
//       idToken: authenticationIdToken,
//       accessToken: authenticationAccessToken,
//     );
//     await FirebaseAuth.instance.signInWithCredential(credential);
//     dev.log("Sign in processd");
//     // await _auth.signInWithCredential(credential);
//   });
// }

// Future<void> initializeLocalServer(BuildContext context) async {
//   final app = shelf_router.Router();

//   app.get('/google-auth', (Request request) async {
//     final authenticationIdToken = request.url.queryParameters['id_token'];
//     final authenticationAccessToken =
//         request.url.queryParameters['access_token'];

//     if (authenticationIdToken != null && authenticationAccessToken != null) {
//       // Handle sign-in and update state in the Flutter app
//       // Use the retrieved tokens to authenticate with Firebase
//       final credential = GoogleAuthProvider.credential(
//         idToken: authenticationIdToken,
//         accessToken: authenticationAccessToken,
//       );

//       try {
//         // Sign in to Firebase
//         await FirebaseAuth.instance.signInWithCredential(credential);
//         dev.log("Sign in processed successfully");

//         ToastMsg.showToastMsg(msg: 'Login Successful');

//         // Navigate to the home page after successful sign-in
//         Navigator.pushNamed(context, '/home');

//         return Response.ok(
//             'Authentication successful. You may close this window.');
//       } catch (e) {
//         dev.log("error: ${e.toString()}");
//         ToastMsg.showToastMsg(
//           msg: "Failed to signin with google!",
//           status: "error",
//         );
//         return Response.notFound("Authentication failed!");
//       }
//     }

//     return Response.notFound('Invalid parameters.');
//   });

//   final server = await shelf_io.serve(app, 'localhost', 56584, shared: true);
//   print(
//       'Local server listening on http://${server.address.host}:${server.port}');
// }

class LocalServer {
  HttpServer? _httpServer;

  Future<bool> initializeLocalServer(BuildContext context) async {
    if (_httpServer != null) return true; // Server already running
    shelf_router.Router app = shelf_router.Router();

    // Custom CORS Middleware
    Middleware corsHeaders() {
      return (innerHandler) {
        return (Request request) async {
          Response response = await innerHandler(request);

          // Add CORS headers
          response = response.change(headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Origin, Content-Type, X-Auth-Token'
          });

          return response;
        };
      };
    }

    app.get('/google-auth', (Request request) async {
      dev.log("local server accessed");
      String? authenticationIdToken = request.url.queryParameters['id_token'];
      String? authenticationAccessToken =
          request.url.queryParameters['access_token'];

      print(authenticationIdToken);
      print(authenticationAccessToken);
      Map<String, Object> _headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET',
      };

      if (authenticationIdToken != null && authenticationAccessToken != null) {
        // Handle sign-in and update state in the Flutter app
        // Use the retrieved tokens to authenticate with Firebase
        try {
          AuthCredential credential = GoogleAuthProvider.credential(
            idToken: authenticationIdToken,
            accessToken: authenticationAccessToken,
          );

          // Sign in to Firebase
          await FirebaseAuth.instance.signInWithCredential(credential);
          dev.log("Sign in processed successfully");

          ToastMsg.showToastMsg(msg: 'Login Successful');

          // Navigate to the home page after successful sign-in
          Navigator.pushReplacementNamed(context, '/home');

          return Response.ok(
            'Authentication successful. You may close this window.',
            headers: _headers,
          );
        } catch (e) {
          dev.log("error f: ${e.toString()}");
          ToastMsg.showToastMsg(
            msg: "Failed to signin with google!",
            status: "error",
          );
          return Response.notFound("Authentication failed!", headers: _headers);
        }
      }

      return Response.notFound('Invalid parameters.', headers: _headers);
    });

    try {
      // Use the custom CORS middleware
      var handler = const Pipeline()
          .addMiddleware(corsHeaders()) // Apply the custom CORS middleware
          .addHandler(app);

      _httpServer =
          await shelf_io.serve(handler, '127.0.0.1', 56584, shared: false);

      // _httpServer =
      //     await shelf_io.serve(app, '127.0.0.1', 56584, shared: false);
      print(
          'Local server listening on http://${_httpServer!.address.host}:${_httpServer!.port}');
      return true;
    } catch (e) {
      dev.log("error: ${e.toString()}");
      return false;
    }
  }

  void closeServer() {
    _httpServer?.close();
    _httpServer = null; // Allow for re-initialization
  }
}
