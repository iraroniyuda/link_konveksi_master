import 'package:flutter/material.dart';
import 'package:link_konveksi_master/login.dart'; // Import the order.dart file
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_gradient_app_bar/flutter_gradient_app_bar.dart'; // Import the gradient app bar package

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}); // Fix the constructor by adding the Key parameter

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TEXTILE MARKET',
      theme: ThemeData(
        // Define a custom AppBar theme with a gradient background
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent, // Make the app bar background transparent
        ),
        primarySwatch: Colors.blue, // You can set this to your desired primary color
      ),
      home: Scaffold(
        appBar: GradientAppBar( // Use GradientAppBar from the package
          title: Text(
            'TEXTILE MARKET',
            style: TextStyle(
              fontSize: 12.0, // Adjust the font size as needed
              fontWeight: FontWeight.bold, // You can also set the font weight
            ),
          ),
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.green],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        body: LoginPage(),
      ),
    );
  }
}
