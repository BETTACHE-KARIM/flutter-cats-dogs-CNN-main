import 'package:cats_dogs_classifier/HomeScreen.dart';
import 'package:cats_dogs_classifier/cnn/home.dart';
import 'package:cats_dogs_classifier/firebase/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyBjMGU7x7PB-Y0pg5z2DYqJ6Mwhudv54Ko",
      appId: "1:381543822108:android:1a430c62f3e716a63580d9",
      messagingSenderId: "XXX",
      projectId: "com.example.controleapp",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthScreen(),
      // home: HomeScreen(),
    );
  }
}
