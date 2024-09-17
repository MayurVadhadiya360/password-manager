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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // appBar: AppBar(
      //   toolbarHeight: MediaQuery.of(context).size.height / 4,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.vertical(
      //       bottom:
      //           Radius.elliptical(MediaQuery.of(context).size.width, 56.0),
      //     ),
      //   ),
      // ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // app name logo/title
              const Text(
                "Password Manager",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 36),
              ),

              // auth action title
              const Text(
                "Login",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
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
                          .then((value) async {
                        if (value == "Login Successful") {
                          ToastMsg.showToastMsg(msg: value, status: "success");
                          setState(() {
                            isLoading = false;
                          });

                          // ignore: use_build_context_synchronously
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
                        ? const Text("Login", style: TextStyle(fontSize: 18),)
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
                      child: const Text("Register", style: TextStyle(fontWeight: FontWeight.w800),)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
