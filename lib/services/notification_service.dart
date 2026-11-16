import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Top-level background message handler required by Firebase Cloud Messaging.
///
/// Must be annotated with `@pragma('vm:entry-point')` so Flutter's AOT compiler
/// does not tree-shake this function when executed in background isolates.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase may already be initialized in this isolate.
  }
  debugPrint('🔔 [FCM BACKGROUND MESSAGE RECEIVED]');
  debugPrint('   Message ID: ${message.messageId}');
  debugPrint('   Title: ${message.notification?.title}');
  debugPrint('   Body: ${message.notification?.body}');
  debugPrint('   Data: ${message.data}');
}

/// Service responsible for managing Firebase Cloud Messaging (FCM),
/// including notification permissions, registration tokens,
/// and foreground/background/tap event handling.
class NotificationService {
  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  String? _fcmToken;

  /// Returns the cached FCM device token.
  String? get fcmToken => _fcmToken;

  /// Optional listener callback invoked when a notification is tapped.
  void Function(RemoteMessage message)? onNotificationTap;

  /// Optional listener callback invoked when a foreground message arrives.
  void Function(RemoteMessage message)? onForegroundMessage;

  /// Initializes FCM listeners, requests permissions, and registers the device.
  Future<void> init() async {
    try {
      // 1. Register top-level background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 2. Request user notification permissions (required for Android 13+ & iOS)
      await requestPermission();

      // 3. Set foreground presentation options (shows alerts/heads-up if supported)
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 4. Listen for token refresh and registration events
      try {
        _messaging.onTokenRefresh.listen((String token) {
          _fcmToken = token;
          debugPrint('🔔 [FCM TOKEN REFRESHED]: $token');
        });
      } catch (_) {}

      try {
        _messaging.onRegistered.listen((String token) {
          _fcmToken = token;
          debugPrint('🔔 [FCM TOKEN REGISTERED/UPDATED]: $token');
        });
      } catch (_) {}

      try {
        _messaging.onUnregistered.listen((String token) {
          _fcmToken = null;
          debugPrint('🔔 [FCM TOKEN UNREGISTERED]: $token');
        });
      } catch (_) {}

      // 6. Register device and print token
      await getFcmToken();

      // 7. Handle foreground notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('🔔 [FCM FOREGROUND MESSAGE]: ${message.messageId}');
        debugPrint('   Title: ${message.notification?.title}');
        debugPrint('   Body: ${message.notification?.body}');
        debugPrint('   Data: ${message.data}');

        onForegroundMessage?.call(message);
      });

      // 8. Handle notification tap when the app is in background (but running)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('🔔 [FCM APP OPENED FROM NOTIFICATION]: ${message.messageId}');
        _handleTap(message);
      });

      // 9. Handle notification tap when the app was launched from a terminated state
      final RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('🔔 [FCM INITIAL MESSAGE FROM TERMINATED]: ${initialMessage.messageId}');
        _handleTap(initialMessage);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [NotificationService] Initialization failed: $e');
      debugPrint(stackTrace.toString());
    }
  }

  /// Requests notification permissions from the operating system.
  Future<NotificationSettings> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('🔔 [FCM PERMISSION STATUS]: ${settings.authorizationStatus}');
    return settings;
  }

  /// Registers the device instance with FCM and returns the registration token.
  Future<String?> getFcmToken() async {
    try {
      if (_fcmToken != null && _fcmToken!.isNotEmpty) {
        return _fcmToken;
      }

      // 1. Primary method: official getToken()
      try {
        _fcmToken = await _messaging.getToken();
      } catch (e) {
        debugPrint('⚠️ [FCM] _messaging.getToken() notice: $e');
      }

      // 2. Secondary fallback
      if (_fcmToken == null || _fcmToken!.isEmpty) {
        try {
          final Future<String> tokenFuture = _messaging.onRegistered.first;
          await _messaging.register();
          _fcmToken = await tokenFuture.timeout(
            const Duration(seconds: 4),
            onTimeout: () => '',
          );
        } catch (_) {}
      }

      if (_fcmToken != null && _fcmToken!.isEmpty) {
        _fcmToken = null;
      }

      debugPrint('==================================================');
      debugPrint('🔔 [FCM DEVICE TOKEN]: $_fcmToken');
      debugPrint('==================================================');
      return _fcmToken;
    } catch (e) {
      debugPrint('❌ [FCM] Failed to retrieve device token: $e');
      return null;
    }
  }

  /// Unregisters the current app instance from Firebase Cloud Messaging.
  Future<void> unregisterDevice() async {
    try {
      try {
        await _messaging.deleteToken();
      } catch (_) {}
      try {
        await _messaging.unregister();
      } catch (_) {}
      _fcmToken = null;
      debugPrint('🔔 [FCM] Device unregistered and token removed.');
    } catch (e) {
      debugPrint('❌ [FCM] Failed to unregister device: $e');
    }
  }

  /// Removes access to the FCM registration token (alias for unregisterDevice).
  Future<void> deleteToken() => unregisterDevice();

  /// Internal handler for notification tap events.
  void _handleTap(RemoteMessage message) {
    onNotificationTap?.call(message);
  }
}
