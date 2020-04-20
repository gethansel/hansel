import 'dart:io';
import 'package:covid_tracker/mocks/mock_locations.dart';
import 'package:covid_tracker/model/exposure_event.dart';
import 'package:covid_tracker/model/location_event.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class LocalStorageService {
  Box _settingsBox;
  Box get settingsBox => _settingsBox;
  Box _exposuresBox;
  Box get exposuresBox => _exposuresBox;
  Box _locationsBox;
  Box get locationsBox => _locationsBox;

  static LocalStorageService _instance;

  static Future<LocalStorageService> getInstance() async {
    if (_instance == null) {
      _instance = LocalStorageService();
    }
    await _instance.init();
    return _instance;
  }

  Future<void> init() async {
    try {
      Directory dir = await getApplicationDocumentsDirectory();
      Hive
      ..init('${dir.path}/db')
      ..registerAdapter(LocationEventAdapter())
      ..registerAdapter(ExposureEventAdapter());
    } on HiveError catch (e) {
      print('(WARNING) ${e.message}');
    }
    _settingsBox = await Hive.openBox('settings');
    _exposuresBox = await Hive.openBox('exposures');
    _locationsBox = await Hive.openBox('locationBox');
    // createTestLocations();
  }
}
