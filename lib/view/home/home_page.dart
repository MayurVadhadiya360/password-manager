import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:password_manager/providers/password_model.dart';
import 'package:password_manager/providers/password_provider.dart';
import 'package:password_manager/services/auth_service.dart';
import 'package:password_manager/view/home/password_form.dart';
import 'package:provider/provider.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => PasswordProvider(),
        ),
      ],
      // builder: (context, child) {
      //   return HomePage();
      // },
      child: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> showAddPasswordDialog(
      BuildContext context, PasswordProvider passwordProvider) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return PasswordForm(
          passwordProvider: passwordProvider,
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
    BuildContext context,
    PasswordProvider passwordProvider, {
    required String id,
    String? initSite,
    String? initUsername,
    String? initialPassword,
    String? initialNote,
  }) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return PasswordForm(
          passwordProvider: passwordProvider,
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

  void _showContextMenu(BuildContext context, Offset position, int index,
      PasswordModel passwordData) async {
    PasswordProvider passwordProvider =
        Provider.of<PasswordProvider>(context, listen: false);
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx, // x position
        position.dy, // y position
        position.dx + 1, // small offset on the right
        position.dy + 1, // small offset below
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      items: [
        PopupMenuItem(
          onTap: () async {
            log("View Password $index");
            await showUpdatablePasswordDialog(
              context,
              passwordProvider,
              id: passwordData.id,
              initSite: passwordData.site,
              initUsername: passwordData.username,
              initialPassword: passwordData.password,
              initialNote: passwordData.note,
            );
          },
          value: 'View',
          child: Text('View'),
        ),
        PopupMenuItem(
          onTap: () {
            log("Delete Password $index");
            log("delete: ${passwordData.id}");
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text("Are you sure want to delete password?")),
                  // content: Text(
                  //     "Are you sure want to delete password?"),
                  actionsAlignment: MainAxisAlignment.spaceBetween,
                  actions: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Cancel"),
                    ),
                    FilledButton(
                      onPressed: () async {
                        await passwordProvider.delete_password(passwordData.id);
                        Navigator.of(context).pop();
                      },
                      child: Text("Confirm"),
                    ),
                  ],
                );
              },
            );
          },
          value: 'Delete',
          child: Text(
            'Delete',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    PasswordProvider passwordProvider = Provider.of<PasswordProvider>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Password Manager",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${FirebaseAuth.instance.currentUser!.email}',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
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
              margin: EdgeInsets.only(top: 5, bottom: 55),
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

                          return Container(
                            // padding: const EdgeInsets.all(2.0),
                            margin: EdgeInsets.all(5),
                            child: GestureDetector(
                              onLongPressStart: (details) {
                                _showContextMenu(
                                  context,
                                  details.globalPosition,
                                  index,
                                  passwordData,
                                );
                              },
                              child: ListTile(
                                tileColor: Theme.of(context).splashColor,
                                shape: StadiumBorder(),
                                onTap: () async {
                                  await showUpdatablePasswordDialog(
                                    context,
                                    passwordProvider,
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
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  passwordData.username!,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .primaryColorLight
                                      .withOpacity(0.6),
                                  child: (passwordData.faviconUrl != null)
                                      ? Image.network(
                                          passwordData.faviconUrl!,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Icon(Icons.public),
                                        )
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
                                              onPressed: () async {
                                                await passwordProvider
                                                    .delete_password(
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
                            ),
                          );
                        },
                        itemCount: passwordProvider.passwords.length,
                      ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await showAddPasswordDialog(context, passwordProvider);
          },
          shape: const CircleBorder(),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
    );
  }
}
