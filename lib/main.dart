import 'package:camera/camera.dart';
import 'package:fitness_app/getting_started_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitness_app/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/login_page.dart';
import 'package:flutter/services.dart';

List<CameraDescription> cameras = [];
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    debugPrint('Error: ${e.code}\nError Message: ${e.description}');
  }
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitnessApp',
      theme: ThemeData(
        // General theme settings
        brightness: Brightness.light,
        primaryColor: const Color(0xFF3A7BD5), // Mid-blue from the logo
        secondaryHeaderColor: const Color(0xFF86D38A), // Mid-green from the logo
        scaffoldBackgroundColor: Colors.white,
        
        // Color scheme for various UI elements
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2459C0),
          secondary: Color(0xFF6DB05D),
          background: Colors.white,
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onBackground: Colors.black87,
          onSurface: Colors.black87,
          error: Colors.red,
          onError: Colors.white,
        ),

        // Text theme for fonts
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
        ),

        // Button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1C315C),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

        // AppBar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2459C0),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return GettingStartedPage(user: snapshot.data);
          }
          return const LoginPage();
        },
      ),
    );
  }
}


