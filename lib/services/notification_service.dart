import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifs = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> init(String? uid) async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _localNotifs.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    // Save FCM token so admin can target this device / all users
    final token = await _messaging.getToken();
    if (uid != null && token != null) {
      await _db.collection('users').doc(uid).update({'fcmToken': token});
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });
  }

  void _showLocalNotification(RemoteMessage message) {
    const androidDetails = AndroidNotificationDetails(
      'match_alerts',
      'Match Alerts',
      channelDescription: 'Ogeysiisyada ciyaaraha & premium',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());
    _localNotifs.show(
      message.hashCode,
      message.notification?.title ?? 'SportLiveTV',
      message.notification?.body ?? '',
      details,
    );
  }

  /// Subscribe device to a topic, e.g. "match_<id>" for kickoff reminders.
  Future<void> subscribeToMatch(String matchId) {
    return _messaging.subscribeToTopic('match_$matchId');
  }

  Future<void> unsubscribeFromMatch(String matchId) {
    return _messaging.unsubscribeFromTopic('match_$matchId');
  }
}
