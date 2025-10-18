import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:adhan/adhan.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint(
    'Notification tapped in background: ${notificationResponse.payload}',
  );
}

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    final String timeZoneName = tz.local.name;
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('ic_notification');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
            debugPrint('Notification tapped: ${notificationResponse.payload}');
          },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  Future<void> requestPermissions() async {
    final plugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await plugin?.requestNotificationsPermission();
    await plugin?.requestExactAlarmsPermission();
  }

  Future<void> schedulePrayerNotifications(PrayerTimes prayerTimes) async {
    await cancelAllNotifications();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'prayer_channel_id',
          'Prayer Times Notifications',
          channelDescription:
              'Channel for prayer time notifications with custom sound',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('adhan'),
          playSound: true,
          fullScreenIntent: false,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    final prayersToSchedule = {
      0: {'name': 'الفجر', 'time': prayerTimes.fajr, 'body': 'حي على الصلاة'},
      1: {
        'name': 'الظهر',
        'time': prayerTimes.dhuhr,
        'body': 'حان الآن وقت صلاة الظهر',
      },
      2: {
        'name': 'العصر',
        'time': prayerTimes.asr,
        'body': 'حان الآن وقت صلاة العصر',
      },
      3: {
        'name': 'المغرب',
        'time': prayerTimes.maghrib,
        'body': 'حان الآن وقت صلاة المغرب',
      },
      4: {
        'name': 'العشاء',
        'time': prayerTimes.isha,
        'body': 'حان الآن وقت صلاة العشاء',
      },
    };

    for (final entry in prayersToSchedule.entries) {
      final id = entry.key;
      final details = entry.value;
      await _scheduleNotificationFor(
        details['time'] as DateTime,
        details['name'] as String,
        details['body'] as String,
        id,
        notificationDetails,
      );
    }
  }

  Future<void> _scheduleNotificationFor(
    DateTime time,
    String prayerName,
    String body,
    int id,
    NotificationDetails details,
  ) async {
    if (time.isAfter(DateTime.now())) {
      try {
        await _notificationsPlugin.zonedSchedule(
          id,
          'أذان $prayerName',
          body,
          tz.TZDateTime.from(time, tz.local),
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: prayerName,
        );
      } catch (e) {
        debugPrint('Failed to schedule notification for $prayerName: $e');
      }
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'prayer_channel_id',
          'Prayer Times Notifications',
          channelDescription:
              'Channel for prayer time notifications with custom sound',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('adhan'),
          playSound: true,
          fullScreenIntent: false,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      99,
      'أذان العشاء (اختبار)',
      'حان الآن وقت صلاة العشاء',
      notificationDetails,
      payload: 'العشاء',
    );
  }
}
