import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class LocalStorageService {
  Box _settingsBox;
  Box get settingsBox => _settingsBox;

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
      Hive.init('${dir.path}/db');
      // Hive.registerAdapter(LocationEventAdapter());
    } on HiveError catch (e) {
      print('(WARNING) ${e.message}');
    }
    _settingsBox = await Hive.openBox('settings');
  }
}
