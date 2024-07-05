
import 'package:api_local_storage/screens/home_screen.dart';
import 'package:api_local_storage/screens/login_screen.dart';
import 'package:api_local_storage/theme/theme.dart';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/sign_up.dart';
import 'services/api_service.dart';


void main() async {
  // initialize hive
  await Hive.initFlutter();

  // hive open a box
  await Hive.openBox('mybox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: lightMode,
      darkTheme: darkMode,
      home: FutureBuilder<Widget>(
        future: ApiService.getInitialScreen(),
        builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return snapshot.data ?? const LoginScreen();
          }
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signip': (context) => const SignUp(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
