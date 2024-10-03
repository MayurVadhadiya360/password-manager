import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:password_manager/services/auth_service.dart';
import 'package:password_manager/services/google_signin_desktop.dart';
import 'package:password_manager/utils/toast_msg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController forgotpasswordEmailController = TextEditingController();

  bool passwordObscure = true;
  bool isLoading = false;
  bool localServerStarted = false;

  LocalServer localServer = LocalServer();

  @override
  void initState() {
    if (Platform.isWindows) {
      localServer.initializeLocalServer(context).then(
        (value) {
          setState(() {
            localServerStarted = value;
          });
        },
      );
    }

    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    forgotpasswordEmailController.dispose();
    if (Platform.isWindows) {
      localServer.closeServer();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App Logo
                CircleAvatar(
                  backgroundColor: Colors.white,
                  foregroundImage: AssetImage((isDark)
                      ? "assets/app-logo-outlined.png"
                      : "assets/app-logo-filled.png"),
                  radius: 80,
                ),

                const SizedBox(height: 20),

                // sign in with google
                if (!Platform.isWindows)
                  GestureDetector(
                    onTap: () async {
                      log("sign_in_with_google");
                      await AuthService.signInWithGoogle().then(
                        (value) {
                          if (value == "Login Successful") {
                            ToastMsg.showToastMsg(
                                msg: value, status: "success");

                            Navigator.pushReplacementNamed(context, "/home");
                          } else {
                            ToastMsg.showToastMsg(msg: value, status: "error");
                          }
                        },
                      );
                    },
                    child: Container(
                      width: 240, // Maximum width of the button
                      height: 60, // Maximum height of the button
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        image: DecorationImage(
                          image: AssetImage("assets/sign_in_with_google.jpg"),
                        ),
                      ),
                      // child: Image.asset(
                      //   "assets/sign_in_with_google.jpg",
                      //   // Scales the image to fit within the bounds while maintaining its aspect ratio
                      //   fit: BoxFit.contain,
                      // ),
                    ),
                  ),

                // sign in with google desktop
                if (Platform.isWindows)
                  GestureDetector(
                    onTap: () async {
                      log("sing in with google desktop");
                      if (localServerStarted) {
                        await googleSigninWithWeb();
                      }
                    },
                    child: Container(
                      width: 240, // Maximum width of the button
                      height: 60, // Maximum height of the button
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        image: DecorationImage(
                          image: AssetImage("assets/sign_in_with_google.jpg"),
                        ),
                      ),
                      child: (!localServerStarted)
                          ? Center(child: CircularProgressIndicator())
                          : null,
                    ),
                  ),

                // fixed height(space) with sized box
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Divider(thickness: 1.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "OR",
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                    Expanded(
                      child: Divider(thickness: 1.0),
                    ),
                  ],
                ),

                // fixed height(space) with sized box
                const SizedBox(height: 20),

                // email input
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Email"),
                    hintText: "Enter you email",
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                ),

                // fixed height(space) with sized box
                const SizedBox(height: 10),

                // password input
                TextFormField(
                  obscureText: passwordObscure,
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    label: const Text("Password"),
                    hintText: "Enter you password",
                    alignLabelWithHint: true,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          passwordObscure = !passwordObscure;
                        });
                      },
                      child: (passwordObscure)
                          ? const Icon(Icons.visibility)
                          : const Icon(Icons.visibility_off),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    return null;
                  },
                ),

                // fixed height(space) with sized box
                // const SizedBox(height: 10),

                // forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () async {
                      log("Forgot Password!");
                      await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Reset Password!"),
                              content: Container(
                                width: double.maxFinite,
                                child: Form(
                                  key: _formKey1,
                                  child: TextFormField(
                                    controller: forgotpasswordEmailController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      hintText: "Enter username/email",
                                      prefixIcon: Icon(Icons.person),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter email';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              actionsAlignment: MainAxisAlignment.spaceBetween,
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    if (_formKey1.currentState!.validate()) {
                                      String response =
                                          await AuthService.forgotPassword(
                                              forgotpasswordEmailController
                                                  .text);
                                      if (response ==
                                          "Password reset link sent to your email!") {
                                        ToastMsg.showToastMsg(msg: response);
                                        Navigator.of(context).pop();
                                      } else {
                                        ToastMsg.showToastMsg(
                                            msg: response, status: "error");
                                      }
                                    }
                                  },
                                  child: Text("Confirm"),
                                )
                              ],
                            );
                          });
                    },
                    child: const Text("Forgot Password?"),
                  ),
                ),

                // auth action button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        await AuthService.loginWithEmail(
                                emailController.text, passwordController.text)
                            .then((value) {
                          if (value == "Login Successful") {
                            ToastMsg.showToastMsg(
                                msg: value, status: "success");
                            setState(() {
                              isLoading = false;
                            });

                            Navigator.pushReplacementNamed(context, "/home");
                          } else {
                            ToastMsg.showToastMsg(msg: value, status: "error");
                          }
                        });
                        setState(() {
                          isLoading = false;
                        });
                      },
                      child: (!isLoading)
                          ? const Text(
                              "Login",
                              style: TextStyle(fontSize: 18),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 25,
                                  width: 25,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 3),
                                ),
                                SizedBox(width: 10),
                                Text("Logging in..."),
                              ],
                            )),
                ),

                // fixed height(space) with sized box
                const SizedBox(height: 10),

                // auth footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/signup");
                        },
                        child: const Text(
                          "Register",
                          style: TextStyle(fontWeight: FontWeight.w800),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
