import 'package:chatapp_final/helper/helper_function.dart';
import 'package:chatapp_final/pages/auth/login_page.dart';
import 'package:chatapp_final/pages/home_page.dart';
import 'package:chatapp_final/shared/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:chatapp_final/screens/splashscreen.dart';
import 'service/presence_service.dart';
import 'pages/auth/personal_chat_page.dart';
import 'pages/auth/personal_chat_menu.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: Constants.apiKey,
        appId: Constants.appId,
        messagingSenderId: Constants.messagingSenderId,
        projectId: Constants.projectId,
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Constants().primaryColor,
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // ✅ Only one home now
    );
  }
}
