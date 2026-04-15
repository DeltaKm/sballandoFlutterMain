import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionService {
  /// Richiede i permessi per le notifiche su iOS e Android 13+
  static Future<bool> requestNotificationPermission() async {
    if (Platform.isIOS) {
      // iOS → usa FirebaseMessaging
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      return settings.authorizationStatus == AuthorizationStatus.authorized ||
             settings.authorizationStatus == AuthorizationStatus.provisional;
    } else if (Platform.isAndroid) {
      // Android → da API 33 serve POST_NOTIFICATIONS
      if (await Permission.notification.isGranted) {
        return true;
      }

      PermissionStatus status = await Permission.notification.request();
      return status.isGranted;
    } else {
      // Altre piattaforme (web, desktop)
      return true;
    }
  }
}
