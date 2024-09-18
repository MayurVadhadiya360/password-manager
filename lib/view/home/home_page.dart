import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:password_manager/providers/password_model.dart';
import 'package:password_manager/providers/password_provider.dart';
import 'package:password_manager/services/auth_service.dart';
import 'package:password_manager/view/home/password_form.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> showAddPasswordDialog(BuildContext context) async {
    PasswordProvider passwordProvider =
        Provider.of<PasswordProvider>(context, listen: false);
    return await showDialog(
      context: context,
      builder: (context) {
        return PasswordForm(
          showPasswordGeneratorIcon: true,
          onSave: (site, username, password, note) async {
            // loading circle dialog
            showDialog(
              context: context,
              builder: (context) {
                return const Center(child: CircularProgressIndicator());
              },
            );

            try {
              await passwordProvider.add_password(
                site: site,
                username: username,
                password: password,
                note: note,
              );

              // pop the loading circle dialog
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
              return true;
            } catch (e) {
              log("error: ${e.toString()}");
              // pop the loading circle dialog
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
              return false;
            }
          },
        );
      },
    );
  }

  Future<void> showUpdatablePasswordDialog(
    BuildContext context, {
    required String id,
    String? initSite,
    String? initUsername,
    String? initialPassword,
    String? initialNote,
  }) async {
    PasswordProvider passwordProvider =
        Provider.of<PasswordProvider>(context, listen: false);
    return await showDialog(
      context: context,
      builder: (context) {
        return PasswordForm(
          isEdit: false,
          showPasswordGeneratorIcon: true,
          initialSite: initSite,
          initialUsername: initUsername,
          initialPassword: initialPassword,
          initialNote: initialNote,
          onSave: (site, username, password, note) async {
            // loading circle dialog
            showDialog(
              context: context,
              builder: (context) {
                return const Center(child: CircularProgressIndicator());
              },
            );
            try {
              await passwordProvider.update_password(
                id: id,
                site: site,
                username: username,
                password: password,
                note: note,
              );

              // pop the loading circle dialog
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
              return true;
            } catch (e) {
              // pop the loading circle dialog
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
              return false;
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    PasswordProvider passwordProvider = Provider.of<PasswordProvider>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Password Manager"),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: GestureDetector(
                  onTap: () async {
                    await AuthService.logout();
                    Navigator.pushReplacementNamed(context, "/login");
                  },
                  child: const Icon(Icons.logout)),
            )
          ],
        ),
        body: (passwordProvider.isLoading == true)
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                child: (passwordProvider.passwords.isEmpty)
                    ? Center(
                        child: Text(
                          "No passwords yet!",
                        ),
                      )
                    : ListView.builder(
                        itemBuilder: (context, index) {
                          PasswordModel passwordData =
                              passwordProvider.passwords[index];

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              tileColor: Theme.of(context).splashColor,
                              shape: StadiumBorder(),
                              onTap: () async {
                                await showUpdatablePasswordDialog(
                                  context,
                                  id: passwordData.id,
                                  initSite: passwordData.site,
                                  initUsername: passwordData.username,
                                  initialPassword: passwordData.password,
                                  initialNote: passwordData.note,
                                );
                              },
                              title: Text(
                                passwordData.site!,
                                style: TextStyle(fontSize: 24),
                              ),
                              subtitle: Text(passwordData.username!),
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .primaryColorLight
                                    .withOpacity(0.6),
                                child: (passwordData.faviconUrl != null)
                                    ? Image.network(passwordData.faviconUrl!)
                                    : Icon(Icons.public),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () {
                                  log("delete: ${passwordData.id}");
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                                "Are you sure want to delete password?")),
                                        // content: Text(
                                        //     "Are you sure want to delete password?"),
                                        actionsAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        actions: [
                                          OutlinedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("Cancel"),
                                          ),
                                          FilledButton(
                                            onPressed: () {
                                              passwordProvider.delete_password(
                                                  passwordData.id);
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("Confirm"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        itemCount: passwordProvider.passwords.length,
                      ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await showAddPasswordDialog(context);
          },
          shape: const CircleBorder(),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
    );
  }
}
