import 'dart:convert';

import 'package:api_local_storage/screens/home_screen.dart';
import 'package:api_local_storage/services/api_service.dart';
import 'package:api_local_storage/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../model/user.dart';
import '../services/hive_service.dart';
import '../widgets/text_field.dart';

class UpdateScreen extends StatefulWidget {
  final User user;
  UpdateScreen({super.key, required this.user});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  late TextEditingController passController = TextEditingController();
  late TextEditingController newPassController = TextEditingController();

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 50,
              ),
              Text(widget.user.name),
              const SizedBox(
                height: 20,
              ),
              CustomTextField(
                controller: passController,
                isObsecure: true,
                hintText: 'Enter existing password',
                prefixIcon: const Icon(
                  Icons.password,
                  color: Colors.blue,
                ),
                onChanged: (String value) {
                  passController.text = value;
                },
              ),
              const SizedBox(
                height: 15,
              ),
              CustomTextField(
                controller: newPassController,
                isObsecure: true,
                hintText: 'Enter new password',
                prefixIcon: const Icon(
                  Icons.password_outlined,
                  color: Colors.blue,
                ),
                onChanged: (String value) {
                  passController.text = value;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              CustomButton(
                onTap: () async {
                  try {
                    var response = await ApiService.update(
                        passController.text, newPassController.text);

                    String token = response['token'];
                    print(response['token']);
                    await HiveService().writeData(token);

                    Fluttertoast.showToast(
                      msg: 'Successfully Updated',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      fontSize: 16.0,
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
                    );
                  } catch (e) {
                    var msg = e.toString().replaceAll('Exception: ', '');
                    print('Error message: $msg');

                    try {
                      var errmsg = jsonDecode(
                          msg); // Attempt to parse error message as JSON
                      print('Decoded error: $errmsg');

                      if (errmsg.containsKey('errors')) {
                        // Display each error message in the 'errors' map
                        errmsg['errors'].forEach((key, value) {
                          Fluttertoast.showToast(
                            msg: '$key: ${value[0]}',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        });
                      } else {
                        // Display the main error message
                        Fluttertoast.showToast(
                          msg: errmsg['message'],
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      }
                    } catch (decodeError) {
                      // error
                         }
                  }
                },
                bText: 'Update',
              )
            ],
          ),
        ),
      ),
    );
  }
}
