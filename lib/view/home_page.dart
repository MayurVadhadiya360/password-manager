import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:password_manager/providers/password_model.dart';
import 'package:password_manager/providers/password_provider.dart';
import 'package:password_manager/services/auth_service.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        body: Container(
          child: ListView.builder(
            itemBuilder: (context, index) {
              PasswordModel passwordData = passwordProvider.passwords[index];

              return ListTile(
                leading: Text("$index"),
                title: Text(passwordData.site!),
                subtitle: Text(passwordData.username!),
                trailing: GestureDetector(
                  onTap: () {},
                  child: Icon(Icons.delete),
                ),
              );
            },
            itemCount: passwordProvider.passwords.length,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          shape: const CircleBorder(),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
    );
  }
}
