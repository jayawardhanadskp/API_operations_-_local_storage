import 'dart:async';

import 'package:api_local_storage/services/api_service.dart';
import 'package:flutter/material.dart';

import '../model/user.dart';
import '../services/hive_service.dart';
import '../widgets/button.dart';
import 'update_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = "/home";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late String token; 
  Timer? sessionCheckTimer;

  @override
  void initState() {
    super.initState();
    getTokenFromStorage();
  }

  Future<void> getTokenFromStorage() async {
    
    token = await HiveService().readData() ?? '';
    // start periodic session 
    startSessionCheck();
  }

  void startSessionCheck() {
    // Start periodic session check using Timer.periodic
    sessionCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      checkSessionStatus();
    });

    // Start background fetch for periodic checks
    ApiService.initBackgroundFetch();
  }

  void checkSessionStatus() async {
  try {
    bool sessionAlive = await ApiService.pingServer(token, context);
    if (!sessionAlive) {
      // Do nothing, pingServer will handle redirection if needed
      print('Session not alive, handling redirection in pingServer method.');
      // Cancel the timer if session is not alive to avoid further checks
      sessionCheckTimer?.cancel();
    }
  } catch (e) {
    // Handle error
    print('Error checking session status: $e');
  }
}



  @override
  void dispose() {
    sessionCheckTimer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home Page'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                try {
                  User? currentUser = await ApiService.getMe();
                  if (currentUser != null) {
                    await ApiService.logOut(
                        currentUser.name, currentUser.email, '');

                    Navigator.pushNamedAndRemoveUntil(
                        // ignore: use_build_context_synchronously
                        context, '/login', (route) => false);
                  }
                } catch (e) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logout failed: $e'),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
            ),
          ],
        ),
        body: FutureBuilder<User?>(
          future: ApiService.getMe(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator.adaptive());
            } else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }

            User? user = snapshot.data;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  Text(user?.name ?? ''),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(user?.email ?? ''),
                  Text(user?.id.toString() ?? ''),
                  const SizedBox(
                    height: 50,
                  ),
                  CustomButton(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UpdateScreen(user: user!)));
                    },
                    bText: 'Update',
                  )
                ],
              ),
            );
          },
        ));
  }
}


