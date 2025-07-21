import 'package:app_test/auth/login_page.dart';
import 'package:app_test/auth/register_page.dart';
import 'package:app_test/home_screan.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KhanBook - Dorihona',
      theme: ThemeData(
        primaryColor: Color(0xFF2E86C1),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF2E86C1),
          primary: Color(0xFF2E86C1),
          secondary: Color(0xFF28B463),
          surface: Color(0xFFF8F9FA),
          error: Color(0xFFE74C3C),
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF2E86C1),
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black26,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF2E86C1),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        // cardTheme: CardTheme(
        //   elevation: 3,
        //   shadowColor: Colors.black12,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(16),
        //   ),
        //   color: Colors.white,
        // ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF8F9FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF2E86C1), width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF2E86C1),
          unselectedItemColor: Color(0xFF85929E),
          elevation: 8,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B4F72),
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B4F72),
          ),
          bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF1B4F72)),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF85929E)),
        ),
        useMaterial3: true,
      ),
      home: SplashScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phone_number');
    final password = prefs.getString('password');

    if (phoneNumber != null && password != null) {
      try {
        final response = await http.post(
          Uri.parse('https://khanbook.uz/login'),
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {'phone_number': phoneNumber, 'password': password},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          Navigator.pushReplacementNamed(
            context,
            '/home',
            arguments: {
              'user_id': data['user_id'],
              'full_name': data['full_name'],
              'role': data['role'],
              'phone_number': phoneNumber,
              'password': password,
            },
          );
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2E86C1),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  // color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.black26,
                  //     blurRadius: 20,
                  //     offset: Offset(0, 10),
                  //   ),
                  // ],
                  image: DecorationImage(
                    image: AssetImage('assets/images/image.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Darmon',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Sizning ishonchli dorihanangiz',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              SizedBox(height: 50),
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
