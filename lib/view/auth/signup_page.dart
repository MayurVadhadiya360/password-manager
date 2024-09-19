import 'package:flutter/material.dart';
import 'package:password_manager/services/auth_service.dart';
import 'package:password_manager/utils/toast_msg.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool passwordObscure = true;
  bool isLoading = false;

  String signupBtnText = "Sign Up";

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

                // auth action title
                const Text(
                  "Sign Up",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
                ),

                // fixed height(space) with sized box
                const SizedBox(height: 20),

                // fixed height(space) with sized box
                const SizedBox(height: 10),

                // email input
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Email"),
                    hintText: "Enter your email",
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
                    hintText: "Enter your password",
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
                const SizedBox(height: 10),

                // auth action button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                          signupBtnText = "Creating account...";
                        });
                        await AuthService.createAccountWithEmail(
                          emailController.text,
                          passwordController.text,
                        ).then((value) {
                          if (value == "Account Created") {
                            ToastMsg.showToastMsg(
                              msg: value,
                              status: "success",
                            );

                            setState(() {
                              isLoading = false;
                              signupBtnText = "Sign Up";
                            });

                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              "/home",
                              (route) => false,
                            );
                          } else {
                            ToastMsg.showToastMsg(msg: value, status: "error");
                          }
                        });
                        setState(() {
                          isLoading = false;
                          signupBtnText = "Sign Up";
                        });
                      },
                      child: (!isLoading)
                          ? const Text("Sign Up")
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 25,
                                  width: 25,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 3),
                                ),
                                const SizedBox(width: 10),
                                Text(signupBtnText),
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
                    const Text("Already have an account?"),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Login")),
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
