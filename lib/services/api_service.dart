import 'dart:convert';

import 'package:api_local_storage/screens/home_screen.dart';
import 'package:api_local_storage/screens/login_screen.dart';
import 'package:api_local_storage/services/config.dart';
import 'package:api_local_storage/services/hive_service.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/user.dart';

class ApiService {
  // get screen
  static Future<Widget> getInitialScreen() async {
    User? currentUser = await ApiService.getMe();
    if (currentUser != null) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }

// PING CHECK
  // PING CHECK
  static Future<bool> pingServer(String token, BuildContext? context) async {
    
    // get token
    final hiveService = HiveService();
    String? token = await hiveService.readData();

    var headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json'
    };

    var url = Uri.parse('${Config.BACKEND_URL}protected/ping');
    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var message = jsonResponse['message'];
      print('Ping server response: $message');

      if (message == 'alive') {
        return true; 
      } else if (message == 'Unauthenticated.') {
        if (context != null) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(); 
          }
          print('Showing dialog for session expired');
          showDialog(
            context: context,
            barrierDismissible: false, 
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Session Expired'),
                content: const Text(
                    'Your session has expired. Please log in again.'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ],
              );
            },
          );
        } else {
          print('Context is null, cannot show dialog');
        }
        return false; 
      } else {
        return false; 
      }
    } else {
      print('Request failed with status: ${response.statusCode}');
      if (response.statusCode == 401) {
        if (context != null) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(); 
          }
          print('Showing dialog for unauthorized access');
          showDialog(
            context: context,
            barrierDismissible: false, 
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Unauthorized Access'),
                content:
                    const Text('You are not authorized. Please log in again.'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () async {
                      // Stop background fetch on logout
                      await BackgroundFetch.stop();
                      print('background fetch stopped');
                      Navigator.of(context).pop();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ],
              );
            },
          );
        } else {
          print('Context is null, cannot show dialog');
        }
      }
      return false;
    }
  }

  // Initialize background fetch for periodic tasks
  static void initBackgroundFetch() {
    BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 1,
        stopOnTerminate: false,
        enableHeadless: true,
      ),
      (String taskId) async {
        // Get token from Hive
        String? token = await HiveService().readData();
        if (token != null) {
          await pingServer(token,
              null); // Pass null as context since this is background fetch
        }
        BackgroundFetch.finish(taskId);
      },
      (String taskId) async {
        BackgroundFetch.finish(taskId);
      },
    ).then((int status) {
      print('[BackgroundFetch] configure success: $status');
    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
    });
  }

  // Background fetch headless task
  static void backgroundFetchHeadlessTask(String taskId) async {
    String? token = await HiveService().readData();
    if (token != null) {
      await pingServer(
          token, null); // Pass null as context since this is headless task
    }
    BackgroundFetch.finish(taskId);
  }

  // REGISTER
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final url = Uri.parse('${Config.BACKEND_URL}register');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      print('Registration successful');
      print(response.body);

      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    } else {
      // erros
      print('Failed to register');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      throw Exception(response.body);
    }
  }

  // LOG IN
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final url = Uri.parse('${Config.BACKEND_URL}login');
    final response = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }));

    if (response.statusCode == 200) {
      print('Sucessfully Login');
      print(response.body);

      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    } else {
      print('Failed to login');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      // throw error exception
      throw Exception(response.body);
    }
  }

  // GET USER DATA
  static Future<User?> getMe() async {
    final url = Uri.parse("${Config.BACKEND_URL}protected/get-me");

    // get token
    final hiveService = HiveService();
    String? token = await hiveService.readData();

    // if (token == null) {
    //   throw Exception('Token not found');
    // }

    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // LOGOUT
  static Future logOut(String name, String email, String password) async {
    final url = Uri.parse("${Config.BACKEND_URL}logout");

    // get token
    final hiveService = HiveService();
    String? token = await hiveService.readData();

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print('Successfully logged out');
      // await hiveService.clearData();
    } else {
      throw Exception('Failed to log out');
    }
  }

  // UPDATE
  static Future update(String pass, String newPass) async {
    final url = Uri.parse("${Config.BACKEND_URL}protected/update-me");

    final hiveService = HiveService();
    String? token = await hiveService.readData();

    final response = await http.post(url, headers: <String, String>{
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    }, body: <String, String>{
      'password': pass,
      'new_password': newPass
    });

    if (response.statusCode == 200) {
      print('Sucessfully updated');
      return jsonDecode(response.body);
    } else {
      throw Exception(response.body);
    }
  }
}
