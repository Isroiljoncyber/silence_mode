import 'dart:async';

import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:startUp/datamodels/user_models.dart';
import 'package:startUp/db/sharedDB.dart';

class PreferenceLocator {
  PreferenceLocator() {
    location.requestService().then((value) async {
      SharedPreferences helper = await SharedPreferenceHelper().getInstance();
      if (value) {
        timer = Timer.periodic(
          const Duration(seconds: 1),
          (timer) async {
            double? latitude = helper.getDouble('lat');
            double? longitude = helper.getDouble('long');
            _locationController.add(UserLocation(latitude: latitude, longitude: longitude));
          },
        );
      }
    });
  }

  var location = Location();

  late Timer timer;

  final StreamController<UserLocation> _locationController = StreamController<UserLocation>.broadcast();

  Stream<UserLocation> get locationStream => _locationController.stream;
}
