import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:password_manager/providers/password_provider.dart';
import 'package:password_manager/utils/toast_msg.dart';

class PasswordForm extends StatefulWidget {
  const PasswordForm({
    Key? key,
    required this.onSave,
    required this.passwordProvider,
    this.initialSite,
    this.initialUsername,
    this.initialPassword,
    this.initialNote,
    this.showPasswordGeneratorIcon = false,
    this.isEdit = true,
  }) : super(key: key);

  // Callback for OK button
  final Future<bool> Function(
      String site, String username, String password, String note) onSave;

  final PasswordProvider passwordProvider;

  final bool isEdit;
  final bool showPasswordGeneratorIcon;

  // Initial values for update functionality
  final String? initialSite;
  final String? initialUsername;
  final String? initialPassword;
  final String? initialNote;

  @override
  _PasswordFormState createState() => _PasswordFormState();
}

class _PasswordFormState extends State<PasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Initialize controllers within the widget
  TextEditingController siteController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  bool isPasswordNotEmpty = false;
  bool isUsernameNotEmpty = false;
  bool isEditable = false;

  @override
  void initState() {
    // Use initial values if provided, otherwise leave empty for adding new data
    siteController = TextEditingController(text: widget.initialSite ?? '');
    usernameController =
        TextEditingController(text: widget.initialUsername ?? '');
    passwordController =
        TextEditingController(text: widget.initialPassword ?? '');
    noteController = TextEditingController(text: widget.initialNote ?? '');

    usernameController.addListener(() {
      setState(() {
        isUsernameNotEmpty = usernameController.text.isNotEmpty;
      });
    });

    passwordController.addListener(() {
      setState(() {
        isPasswordNotEmpty = passwordController.text.isNotEmpty;
      });
    });

    setState(() {
      isEditable = widget.isEdit;
      isUsernameNotEmpty = usernameController.text.isNotEmpty;
      isPasswordNotEmpty = passwordController.text.isNotEmpty;
    });

    super.initState();
  }

  @override
  void dispose() {
    // Dispose controllers when not needed to free resources
    siteController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    noteController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // PasswordProvider passwordProvider = Provider.of<PasswordProvider>(context);
    return AlertDialog(
      title: Text(
        (widget.isEdit)
            ? "Add New Password"
            : (isEditable)
                ? "Update Password"
                : "Password",
      ),
      content: Container(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // site/app
              TextFormField(
                controller: siteController,
                readOnly: !isEditable,
                showCursor: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  hintText: "Enter site/app",
                  prefixIcon: Icon(Icons.public),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter site/app name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              // username/email/mobile no.
              TextFormField(
                controller: usernameController,
                readOnly: !isEditable,
                showCursor: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  hintText: "Enter username/email",
                  prefixIcon: Icon(Icons.person),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isUsernameNotEmpty)
                        IconButton(
                          onPressed: () {
                            log("Copy Username");
                            Clipboard.setData(ClipboardData(
                                    text: usernameController.text))
                                .then(
                              (value) {
                                log("Copied: ${usernameController.text}");
                                ToastMsg.showToastMsg(
                                    msg: "Copied: ${usernameController.text}");
                              },
                            );
                          },
                          icon: Icon(Icons.copy),
                        ),
                    ],
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter username (i.e., email, mobile no., etc)';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              // password
              TextFormField(
                controller: passwordController,
                readOnly: !isEditable,
                showCursor: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  hintText: "Enter password",
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPasswordNotEmpty)
                        IconButton(
                          onPressed: () {
                            log("Copy Password");
                            Clipboard.setData(ClipboardData(
                                    text: passwordController.text))
                                .then(
                              (value) {
                                log("Copied: ${passwordController.text}");
                                ToastMsg.showToastMsg(
                                    msg: "Copied: ${passwordController.text}");
                              },
                            );
                          },
                          icon: Icon(Icons.copy),
                        ),
                      if (isEditable && widget.showPasswordGeneratorIcon)
                        IconButton(
                          tooltip: "Generate Password",
                          onPressed: () {
                            log("Generate Password");
                            passwordController.text = widget.passwordProvider
                                .generateSecurePassword(16);
                          },
                          icon: Icon(Icons.insights),
                        ),
                    ],
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              // note
              TextFormField(
                controller: noteController,
                readOnly: !isEditable,
                showCursor: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  hintText: "Enter note (optional)",
                ),
              ),
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () {
            if (widget.isEdit) {
              Navigator.of(context).pop();
            } else if (isEditable) {
              setState(() {
                isEditable = false;
              });
            } else {
              Navigator.of(context).pop();
            }
          },
          child: Text("Cancel"),
        ),
        (isEditable)
            ? TextButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    bool success = await widget.onSave(
                      siteController.text,
                      usernameController.text,
                      passwordController.text,
                      noteController.text,
                    );

                    if (success) {
                      if (widget.isEdit)
                        Navigator.of(context).pop();
                      else {
                        setState(() {
                          isEditable = false;
                        });
                      }
                    } else {
                      // Handle failure case (e.g., show a message)
                      ToastMsg.showToastMsg(
                          msg: "Failed to save password. Please try again.");
                    }
                  }
                },
                child: Text("Save"),
              )
            : TextButton(
                onPressed: () {
                  setState(() {
                    isEditable = true;
                  });
                },
                child: Text("Edit")),
      ],
    );
  }
}
