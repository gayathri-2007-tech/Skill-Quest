import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'screens/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Skill Validation App",

      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: SQ.blue,
        scaffoldBackgroundColor: SQ.bg,
        canvasColor: SQ.bg,
        cardColor: SQ.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: SQ.bg2,
          foregroundColor: SQ.text,
        ),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,

      home: LoginPage(),
    );
  }
}