import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/reports_analytics_page.dart';
import 'pages/resident_main_page.dart';
import 'pages/requests_page.dart';

void main() {
  // Enable Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BIS System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      // initial route points to the resident main page
      initialRoute: '/',
      routes: {
        '/': (context) => const ResidentMainPage(),
        '/requests': (context) => const RequestsPage(),
        '/admin-login': (context) =>
            const LoginPage(), // route admin to LoginPage
      },
    );
  }
}
