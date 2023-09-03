import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:jobminder/screens/login_screen.dart';
import 'package:jobminder/utilites/db.dart';


GetIt locator = GetIt.instance;
void setupSingletons() async {
  locator.registerLazySingleton<FirebaseService>(() => FirebaseService());
}

void main() {
  setupSingletons();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

      Firebase.initializeApp();

    return MaterialApp(
      title: 'Home Screen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
      '/': (context) => const LoginPage(),
    },
    );
  }
}

