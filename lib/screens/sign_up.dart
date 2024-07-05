import 'dart:convert';

import 'package:api_local_storage/screens/login_screen.dart';
import 'package:api_local_storage/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../services/api_service.dart';
import '../widgets/button.dart';
import '../widgets/text_field.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late TextEditingController nameController = TextEditingController();
  late TextEditingController emailController = TextEditingController();
  late TextEditingController passController = TextEditingController();

  final HiveService _hiveService = HiveService();

  @override
  void initState() {
    nameController;
    emailController;
    passController;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            CustomTextField(
              controller: nameController,
              hintText: 'Enter Name',
              prefixIcon: const Icon(
                Icons.person,
                color: Colors.blue,
              ),
              onChanged: (value) {
                emailController.text = value;
              },
            ),
            const SizedBox(
              height: 10,
            ),
            CustomTextField(
              controller: emailController,
              hintText: 'Enter Email',
              prefixIcon: const Icon(
                Icons.email,
                color: Colors.blue,
              ),
              onChanged: (value) {
                emailController.text = value;
              },
            ),
            const SizedBox(
              height: 10,
            ),
            CustomTextField(
                controller: passController,
                isObsecure: true,
                hintText: 'password',
                prefixIcon: const Icon(
                  Icons.password,
                  color: Colors.blue,
                ),
                onChanged: (value) {
                  passController.text = value;
                }),
            const SizedBox(
              height: 30,
            ),
            CustomButton(
              onTap: () async {
                try {
                  var response = await ApiService.register(
                    nameController.text,
                    emailController.text,
                    passController.text,
                  );
                  String token = response["token"];
                  _hiveService.writeData(token);

                  // ignore: use_build_context_synchronously
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                } catch (error) {
                  var msg = error.toString().replaceAll('Exception: ', '');
                  print(jsonDecode(msg)['name']);
                  var decodedError = jsonDecode(msg);

                  // show
                  Future.forEach<MapEntry<String, dynamic>>(decodedError.entries, (entry) async {
                    if (entry.value != null) {
                      for (var message in entry.value) {
                        Fluttertoast.showToast(
                          msg: message,
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                        await Future.delayed(const Duration(seconds: 2));
                      }
                    }
                  });
                  
                }
              },
              bText: 'Sign Up',
            ),
          ],
        ),
      ),
    );
  }
}
