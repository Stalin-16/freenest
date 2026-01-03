import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:freenest/config/app_config.dart';
import 'package:freenest/model/common_reponse.dart';
import 'package:freenest/networking/api_base_helper.dart';
import 'package:http/http.dart';

class NotificationService {
  static final ApiBaseHelper _api = ApiBaseHelper();
  static String baseUrl = AppConfig.customerAPI;
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get device token
    String? token = await _firebaseMessaging.getToken();
    print('Device Token: $token');

    // Save token to your backend
    await saveTokenToDatabase(token);

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        handleNotificationTap(details.payload);
      },
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(message);
    });

    // Handle when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationTap(message.data['route']);
    });

    // Handle when app is terminated
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      handleNotificationTap(initialMessage.data['route']);
    }
  }

  static Future<void> showNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    // Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
    );

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      notification?.title ?? 'New Notification',
      notification?.body ?? 'You have a new message',
      platformDetails,
      payload: message.data['route'],
    );
  }

  static void handleNotificationTap(String? route) {
    if (route != null) {
      // Navigate to specific screen
      // You'll need to implement your navigation logic here
      print('Navigate to: $route');
    }
  }

  static Future<CommonResponseModel> saveTokenToDatabase(String? token) async {
    try {
      final response = await _api
          .post("$baseUrl/credits/save-notification-token", {"token": token});
      return CommonResponseModel.fromMap(response);
    } catch (e) {
      throw Exception("Failed to save token: $e");
    }
  }

  // Subscribe to topics
  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  // Unsubscribe from topics
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}
