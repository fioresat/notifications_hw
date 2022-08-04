import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:async';

import 'PaddedElevatedButton.dart';

void main() async {
  tz.initializeTimeZones();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const NotificationsPage(),
    );
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  //объект уведомления
  late FlutterLocalNotificationsPlugin localNotifications;
  bool _show = true;

  //инициализация
  @override
  void initState() {
    super.initState();

    _show
        ? WidgetsBinding.instance.addPostFrameCallback((_) async {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Вы будуте получать ежедневное уведомление в 8-00!'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.indigo,),);
            await _scheduleDailyEightAMNotification();
          })
        : null;

    //объект для Android настроек
    const androidInitialize = AndroidInitializationSettings('ic_launcher');
    //объект для IOS настроек
    const iOSInitialize = IOSInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    // общая инициализация
    const initializationSettings =
        InitializationSettings(android: androidInitialize, iOS: iOSInitialize);

    //мы создаем локальное уведомление
    localNotifications = FlutterLocalNotificationsPlugin();
    localNotifications.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          PaddedElevatedButton(
            buttonText: 'Получать повторяющиеся уведомления каждую минуту',
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Вы будуте получать уведомления раз в минуту!'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.indigo,),);
              await _repeatNotification();
            },
          ),
          PaddedElevatedButton(
            buttonText: 'Ежедневное уведомление в 10-00',
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Вы будуте получать ежедневное уведомление в 10-00!'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.indigo,),);
              await _scheduleDailyTenAMNotification();
            },
          ),
          PaddedElevatedButton(
            buttonText: 'Ежедневное уведомление в 8-00',
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Вы будуте получать ежедневное уведомление в 8-00!'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.indigo,),);
              _show = false;
              await _scheduleDailyEightAMNotification();
            },
          ),
          PaddedElevatedButton(
            buttonText: 'Показать уведомление 1 раз',
            onPressed: () async {
              await _showNotification();
            },
          ),
        ]),
      ),
    );
  }

  Future _showNotification() async {
    const androidDetails = AndroidNotificationDetails(
      "ID",
      "Название",
      importance: Importance.high,
      channelDescription: "Тело уведомления",
    );

    const iosDetails = IOSNotificationDetails();
    const generalNotificationDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);
    await localNotifications.show(0, "Единоразовое уведомление", "Уведомляет",
        generalNotificationDetails);
  }

  tz.TZDateTime _nextInstanceOfTenAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    print('time ${now.hour + 3}:${now.minute}');
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 7);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> _scheduleDailyTenAMNotification() async {
    await localNotifications.zonedSchedule(
        10,
        'Учись!',
        'Выделить полчаса на занятия программированием',
        _nextInstanceOfTenAM(),
        const NotificationDetails(
          android: AndroidNotificationDetails('daily notification channel id',
              'daily notification channel name',
              channelDescription: 'daily notification description'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  tz.TZDateTime _nextInstanceOfEightAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    print('time ${now.hour + 3}:${now.minute}');
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 5);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> _scheduleDailyEightAMNotification() async {
    await localNotifications.zonedSchedule(
        8,
        'Уведомление',
        'Сейчас 8 утра в Мск',
        _nextInstanceOfEightAM(),
        const NotificationDetails(
          android: AndroidNotificationDetails('daily notification channel id',
              'daily notification channel name',
              channelDescription: 'daily notification description'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  Future<void> _repeatNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'repeating channel id', 'repeating channel name',
            channelDescription: 'repeating description');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await localNotifications.periodicallyShow(
        1,
        'Повторяющееся уведомление',
        'Уведомление каждую минуту',
        RepeatInterval.everyMinute,
        platformChannelSpecifics,
        androidAllowWhileIdle: true);
  }
}
