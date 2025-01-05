import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:password_manager/providers/password_provider.dart';
import 'package:password_manager/services/auth_service.dart';
import 'package:password_manager/utils/toast_msg.dart';
import 'package:provider/provider.dart';

class DrawerView extends StatefulWidget {
  const DrawerView({super.key});

  @override
  State<DrawerView> createState() => _DrawerViewState();
}

class _DrawerViewState extends State<DrawerView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController passwordLengthController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    passwordLengthController.text =
        Provider.of<PasswordProvider>(context, listen: false)
            .passwordLen
            .toString();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    PasswordProvider passwordProvider = Provider.of<PasswordProvider>(context);
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              "${passwordProvider.username}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "${passwordProvider.email}",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            leading: Icon(Icons.person),
          ),
          Divider(),

          // Password Length edit
          ListTile(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Password Length: ", style: TextStyle(fontSize: 20)),
                Container(
                  width: 30,
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: passwordLengthController,
                      decoration: InputDecoration(
                        isDense: true,
                        enabled: _isEditing,
                        disabledBorder: InputBorder.none,
                      ),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color:
                              Theme.of(context).textTheme.titleMedium!.color),
                      // Shows numeric keyboard
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        // Allows only digits
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          ToastMsg.showToastMsg(
                            msg: 'Please enter a password length',
                            status: "warning",
                          );
                          return '';
                        }
                        if (int.tryParse(value) == null) {
                          ToastMsg.showToastMsg(
                            msg: 'Input is not integer',
                            status: "warning",
                          );
                          return '';
                        } else if (int.parse(value) < 8) {
                          ToastMsg.showToastMsg(
                            msg: 'Password length cannot be less than 8',
                            status: "warning",
                          );
                          return '';
                        } else if (int.parse(value) > 99) {
                          ToastMsg.showToastMsg(
                            msg: 'Password length cannot be greater than 99',
                            status: "warning",
                          );
                          return '';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                IconButton(
                  tooltip: (_isEditing) ? "Save" : "Edit",
                  onPressed: () async {
                    if (_isEditing) {
                      if (_formKey.currentState!.validate()) {
                        log("PWD LEN Valid!");
                        bool success = await passwordProvider.updatePasswordLen(
                            int.parse(passwordLengthController.text));
                        if (success) {
                          _isEditing = false;
                          ToastMsg.showToastMsg(
                            msg: 'Password length updated successfully',
                            status: "success",
                          );
                        } else {
                          ToastMsg.showToastMsg(
                            msg: 'Failed to update password length',
                            status: "error",
                          );
                        }
                      }
                    } else {
                      _isEditing = true;
                    }
                    setState(() {});
                  },
                  icon: Icon(
                      (_isEditing) ? Icons.check_circle : Icons.edit_square),
                ),
              ],
            ),
            subtitle: Text("Length of the auto generated password"),
            onTap: () {},
          ),

          Spacer(),
          Divider(),

          // Logout
          Padding(
            padding: const EdgeInsets.only(bottom: 15, top: 5),
            child: GestureDetector(
              onTap: () async {
                await AuthService.logout();
                Navigator.pushReplacementNamed(context, "/login");
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
