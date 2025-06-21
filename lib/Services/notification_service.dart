// import 'package:firebase_messaging/firebase_messaging.dart';

// class NotificationService {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

//   Future<void> initialize() async {
//     NotificationSettings settings =
//         await _firebaseMessaging.requestPermission();

//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//         print('Notification Received: ${message.notification?.title}');
//       });
//     }
//   }
// }
