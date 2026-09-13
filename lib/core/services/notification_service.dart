import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static FlutterLocalNotificationsPlugin? _notificationsPlugin;
  static bool _isInitialized = false;
  static String? _lastNotifiedEventKey;

  static FlutterLocalNotificationsPlugin get _plugin {
    _notificationsPlugin ??= FlutterLocalNotificationsPlugin();
    return _notificationsPlugin!;
  }

  /// Initialize local notification channels
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings();
      const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

      await _plugin.initialize(initSettings);

      // Create Android Notification Channel
      const androidChannel = AndroidNotificationChannel(
        'queue_token_channel',
        'Queue Token Alerts',
        description: 'Real-time alerts when your procurement token turn is approaching',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(androidChannel);
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('[NotificationService] Initialization info: $e');
    }
  }

  /// Request Android 13+ Notification Permission
  static Future<bool> requestNotificationPermission() async {
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final status = await Permission.notification.status;
        if (status.isDenied || status.isLimited) {
          final result = await Permission.notification.request();
          return result.isGranted;
        }
        return status.isGranted;
      }
      return true;
    } catch (e) {
      debugPrint('[NotificationService] Permission request info: $e');
      return true;
    }
  }

  /// Show Android System Notification (Foreground / Background)
  static Future<void> showSystemNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'queue_token_channel',
      'Queue Token Alerts',
      channelDescription: 'Real-time alerts when your procurement token turn is approaching',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
    );

    try {
      await _plugin.show(id, title, body, notificationDetails);
    } catch (e) {
      debugPrint('[NotificationService] Show notification info: $e');
    }
  }

  /// Evaluates queue state and triggers deduplicated notification (In-app modal + system notification + audio/vibration)
  static Future<void> evaluateAndNotifyQueueState({
    required BuildContext context,
    required String tokenNumber,
    required int farmersAhead,
    required bool isTamil,
    required bool isTurn,
  }) async {
    // Deduplication Key: token + farmersAhead count + isTurn state
    final eventKey = '${tokenNumber}_${farmersAhead}_$isTurn';
    if (_lastNotifiedEventKey == eventKey) {
      return; // Already notified for this exact state
    }

    // Trigger only if turn is approaching (farmersAhead <= 2) or it is your turn
    if (farmersAhead > 2 && !isTurn) {
      return;
    }

    _lastNotifiedEventKey = eventKey;

    final title = isTurn
        ? (isTamil ? 'உங்கள் முறை வந்துவிட்டது!' : 'YOUR TURN NOW!')
        : (isTamil ? 'உங்கள் முறை நெருங்குகிறது' : 'Your Turn is Approaching');

    final body = isTurn
        ? (isTamil
            ? 'டோக்கன் $tokenNumber: எடை மேடை 2-க்கு உடனடியாக செல்லவும்.'
            : 'Token $tokenNumber: Please proceed immediately to Bay #02.')
        : (isTamil
            ? 'டோக்கன் $tokenNumber: உங்களுக்கு முன்னால் $farmersAhead விவசாயிகள் மட்டுமே உள்ளனர்.'
            : 'Token $tokenNumber: Only $farmersAhead farmer(s) ahead of you. Please be ready.');

    // 1. Play haptic vibration & audio feedback
    try {
      HapticFeedback.vibrate();
      HapticFeedback.heavyImpact();
    } catch (_) {}

    // 2. Show Android System Notification
    await showSystemNotification(
      id: tokenNumber.hashCode,
      title: title,
      body: body,
    );

    // 3. Show In-App Dialog Notification if context is mounted
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                isTurn ? Icons.notifications_active : Icons.access_time_filled,
                color: isTurn ? Colors.green : Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                body,
                style: const TextStyle(fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isTurn ? Colors.green : Colors.orange).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isTamil ? 'தயவுசெய்து கொள்முதல் மையம் அருகே இருக்கவும்' : 'Please remain near the procurement gate.',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: isTurn ? Colors.green : Colors.orange.shade800,
                foregroundColor: Colors.white,
              ),
              child: Text(isTamil ? 'சரி / புரிந்து கொண்டேன்' : 'Acknowledge'),
            ),
          ],
        ),
      );
    }
  }
}
