import 'package:charming_wishpers/data/firebase/data_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyA9SH5uf8gJypjpKidQuuzOA7cZatSMwCs",
          appId: "1:529377445918:android:396da16fed3c1d1d8a060f",
          messagingSenderId: "529377445918",
          projectId: "charming-wishpers"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}










class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification App'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Step 1: Load data from Firebase
            fetchData();

            // Step 2: Save data to local storage
            // saveDataToLocal(data);

            // Navigate to a screen where users can set notification time
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => NotificationTimeScreen()),
            // );
          },
          child: Text('Load Data from Firebase'),
        ),
      ),
    );
  }

  void fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FirebaseFirestore.instance.collection('collection').get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        prefs.setString('title', doc['title']);
        prefs.setString('body', doc['body']);
      });
    });
  }

  void saveDataToLocal(Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('title', data['title']);
    prefs.setString('body', data['body']);
  }
}

class NotificationTimeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Time'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Step 3: Save notification time to local storage
            saveNotificationTimeToLocal(DateTime.now().add(Duration(seconds: 10))); // Replace with your logic

            // Step 4: Schedule daily notifications
            scheduleDailyNotification();

            // Navigate to the home screen or any other screen
            Navigator.pop(context);
          },
          child: Text('Set Notification Time'),
        ),
      ),
    );
  }

  void saveNotificationTimeToLocal(DateTime notificationTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('notification_time', notificationTime.millisecondsSinceEpoch);
  }

  void scheduleDailyNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id', 'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    // var iOSPlatformChannelSpecifics = DarwinInitializationSettings();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      // iOS: iOSPlatformChannelSpecifics,
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int notificationTimeMillis = prefs.getInt('notification_time') ?? 0;
    DateTime notificationTime = DateTime.fromMillisecondsSinceEpoch(notificationTimeMillis);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // notification ID
      'Your Notification Title',
      'Your Notification Body',
      
      tz.TZDateTime.from(notificationTime, tz.local),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void initializeLocalNotifications() async {
  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon'); // Replace with your app icon
  var initializationSettingsIOS = DarwinInitializationSettings();
  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}