import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:password_manager/services/auth_service.dart';
import 'package:password_manager/utils/toast_msg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool passwordObscure = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
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

              ElevatedButton(
                onPressed: () async {
                  log("sign_in_with_google");
                  await AuthService.signInWithGoogle().then(
                    (value) {
                      if (value == "Login Successful") {
                        ToastMsg.showToastMsg(msg: value, status: "success");

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
                  child: Image.asset(
                    "assets/sign_in_with_google.jpg",
                    fit: BoxFit
                        .contain, // Scales the image to fit within the bounds while maintaining its aspect ratio
                  ),
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
                    )),
              ),

              // fixed height(space) with sized box
              // const SizedBox(height: 10),

              // forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    log("Forgot Password!");
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
                          ToastMsg.showToastMsg(msg: value, status: "success");
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
    );
  }
}
