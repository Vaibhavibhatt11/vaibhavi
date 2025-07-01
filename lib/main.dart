import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Pages
import 'package:chatapp_final/pages/home_page.dart';
import 'package:chatapp_final/screens/splashscreen.dart';
import 'package:chatapp_final/pages/auth/login_page.dart';
import 'package:chatapp_final/pages/auth/register_page.dart';
import 'package:chatapp_final/pages/auth/user_list_page.dart';
import 'package:chatapp_final/pages/group_chat_page.dart';
import 'package:chatapp_final/pages/personal_chat_menu.dart';
import 'package:chatapp_final/pages/auth/edit_profile_page.dart';
import 'package:chatapp_final/pages/personal_chat_page.dart';
import 'package:chatapp_final/pages/auth/personal_chat_info.dart';

import 'package:chatapp_final/shared/constants.dart';

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
  _monitorConnectionStatus();
}
void _monitorConnectionStatus() {
Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
try {
final user = FirebaseAuth.instance.currentUser;
if (user != null) {
await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
'status': result != ConnectivityResult.none ? 'online' : 'offline',
'lastSeen': DateTime.now(),
});
}
} catch (e) {
debugPrint('Error updating user status: $e');
}
} as void Function(Iterable<ConnectivityResult> event)?);
}
class MyApp extends StatelessWidget {
const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Constants().primaryColor,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/user list': (context) => const UserListPage(),
        '/personal chat menu': (context) => PersonalChatMenuPage(),
      },
      onGenerateRoute: (settings) {
        final args = settings.arguments as Map<String, dynamic>?;

        switch (settings.name) {
          case '/edit profile':
            if (args != null && args.containsKey('userName') && args.containsKey('email')) {
              return MaterialPageRoute(
                builder: (context) => EditProfilePage(
                  userName: args['userName'],
                  email: args['email'],
                ),
              );
            }
            break;

          case '/personal chat':
            if (args != null &&
                args.containsKey('currentUserId') &&
                args.containsKey('friendUid') &&
                args.containsKey('friendName')) {
              return MaterialPageRoute(
                builder: (context) => PersonalChatPage(
                  currentUserId: args['currentUserId'],
                  friendUid: args['friendUid'],
                  friendName: args['friendName'],
                ),
              );
            }
            break;

          case '/chat info':
            if (args != null && args.containsKey('userId')) {
              return MaterialPageRoute(
                builder: (context) => PersonalChatInfoPage(userId: args['userId']),
              );
            }
            break;

          case '/group chat':
            if (args != null &&
                args.containsKey('groupId') &&
                args.containsKey('groupName')) {
              return MaterialPageRoute(
                builder: (context) => GroupChatPage(
                  groupId: args['groupId'],
                  groupName: args['groupName'], userName: '',
                ),
              );
            }
            break;
        }

        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text("404 - Page Not Found")),
          ),
        );
      },
    );
  }
}
