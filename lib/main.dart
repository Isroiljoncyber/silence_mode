import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:startUp/pages/location_screen.dart';
import 'package:startUp/services/local_notification_service.dart';

import 'db/sharedDB.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferenceHelper().getInstance();
  Location().requestPermission().then((value) async {
    initializeService();
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Silence Mode',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}
