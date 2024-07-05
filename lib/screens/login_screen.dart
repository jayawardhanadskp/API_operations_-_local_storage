import 'dart:convert';

import 'package:api_local_storage/screens/home_screen.dart';
import 'package:api_local_storage/screens/sign_up.dart';
import 'package:api_local_storage/services/api_service.dart';
import 'package:api_local_storage/widgets/button.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../services/hive_service.dart';
import '../widgets/text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController emailController = TextEditingController();
  late TextEditingController passController = TextEditingController();

  bool _isLoading = false;

  final HiveService _hiveService = HiveService();

  @override
void initState() {
  super.initState();
  emailController;
  passController;
  BackgroundFetch.stop().then((_) {
    print('Background fetch stopped');
  }).catchError((e) {
    print('Failed to stop background fetch: $e');
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(
              height: 50,
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
            _isLoading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : CustomButton(
                    onTap: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      try {
                        var response = await ApiService.login(
                            emailController.text, passController.text);
                        String token = response["token"];
                        _hiveService.writeData(token);

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomeScreen()));
                      } catch (e) {
                        String nsg = e.toString().replaceAll('Exception: ', '');
                        print(jsonDecode(nsg)['message']);
                        String dec = jsonDecode(nsg)['message'];

                        Fluttertoast.showToast(
                          msg: '$dec',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } finally {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                    bText: 'Sign In'),
            const SizedBox(
              height: 30,
            ),
            InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignUp()));
                },
                child: const Text('Don\'t have account? Sign up'))
          ],
        ),
      ),
    );
  }
}
