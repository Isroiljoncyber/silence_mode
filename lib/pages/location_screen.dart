import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:startUp/datamodels/user_models.dart';
import 'package:startUp/services/preferenceLocator.dart';
import 'package:sound_mode/permission_handler.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import 'dart:math';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String modeText = '';
  TextEditingController radiusTextController = TextEditingController(text: "300");

  // Default target location
  final double endLatitude = 41.340866 / (180 / pi);
  final double endLongitude = 69.2845863 / (180 / pi);

  bool isMute = false;
  double distance = 0;

  @override
  void initState() {
    detectMode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto silence mode app'),
      ),
      body: StreamProvider<UserLocation>(
        create: (v) => PreferenceLocator().locationStream,
        initialData: UserLocation(),
        child: StreamBuilder<UserLocation>(
          initialData: UserLocation(),
          stream: PreferenceLocator().locationStream,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.latitude != null) {
              onLocationChanged(snapshot.data!);
              detectMode();
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Latitude: ${snapshot.data!.latitude}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Longitude : ${snapshot.data!.longitude}",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Distance: ${distance.toStringAsFixed(2)} metres",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Target radius : ${radiusTextController.text}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.green),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Text(
                        'Your sound mode : $modeText',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: radiusTextController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Radiusni kiriting...",
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      MaterialButton(
                        onPressed: () {
                          setState(() {});
                        },
                        color: Colors.lightBlueAccent,
                        minWidth: 150,
                        height: 52,
                        child: const Text("Tasdiqlash", style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                ),
              );
            } else {
              return const Center(
                  child: CircularProgressIndicator(
                color: Colors.blueAccent,
              ));
            }
          },
        ),
      ),
    );
  }

  detectMode() async {
    var ringerStatus = await SoundMode.ringerModeStatus;
    if (ringerStatus.index == 2 || ringerStatus.index == 3) {
      isMute = true;
    } else {
      isMute = false;
    }
    setState(() {
      modeText = "${ringerStatus.index} => ${ringerStatus.name}";
    });
  }

  turnOnNotDisturb() async {
    try {
      bool? isGranted = await PermissionHandler.permissionsGranted;
      if (!isGranted!) {
        await PermissionHandler.openDoNotDisturbSetting();
      }
      await SoundMode.setSoundMode(RingerModeStatus.silent);
      detectMode();
    } on PlatformException {
      if (kDebugMode) {
        print('Please enable permissions required');
      }
    }
  }

  turnOnSoundMode() async {
    try {
      bool? isGranted = await PermissionHandler.permissionsGranted;
      if (!isGranted!) {
        await PermissionHandler.openDoNotDisturbSetting();
      }
      await SoundMode.setSoundMode(RingerModeStatus.normal);
      detectMode();
    } on PlatformException {
      if (kDebugMode) {
        print('Please enable permissions required');
      }
    }
  }

  double calculateDistance(double startLatitude, double startLongitude) {
    double earthRadius = 6371000; // meters
    return acos(sin(endLatitude) * sin(startLatitude / (180 / pi)) +
            cos(endLatitude) * cos(startLatitude / (180 / pi)) * cos(startLongitude / (180 / pi) - endLongitude)) *
        earthRadius;
  }

  void onLocationChanged(UserLocation location) async {
    distance = calculateDistance(location.latitude!, location.longitude!);
    var targetRadius = int.parse(radiusTextController.text);
    if (distance <= targetRadius && !isMute) {
      await turnOnNotDisturb();
      isMute = true;
    } else if (distance > targetRadius && isMute) {
      await turnOnSoundMode();
      isMute = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    radiusTextController.dispose();
  }
}
