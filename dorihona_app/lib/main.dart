import 'package:dorihona_app/login_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dorihona',
      theme: ThemeData(
        primaryColor: Color(0xFF2E86C1),
        scaffoldBackgroundColor: Color(0xFFF8F9FA),
        fontFamily: 'Roboto',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 2,
          iconTheme: IconThemeData(color: Color(0xFF1B4F72)),
          titleTextStyle: TextStyle(
            color: Color(0xFF1B4F72),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: LoginScreen(), // Boshlang‘ich sahifa sifatida LoginScreen
      debugShowCheckedModeBanner: false,
    );
  }
}
