import 'dart:io';
import 'dart:isolate';

import 'dart:ui';

import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';
import 'package:background_locator/location_settings.dart';
import 'package:covid_tracker/model/location_event.dart';
import 'package:covid_tracker/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class LocationService {
  final ReceivePort port = ReceivePort();
  // static final _isolateName = 'LocatorIsolate';
  bool isRunning = false;
  bool initialized = false;
  // static String _dbFilePath;
  static final _exposureTimeLimit = 60*0.1;

  LocationService() {
    init();
  }

  init() async {
/* Use if need update UI from isolate
    if (IsolateNameServer.lookupPortByName(_isolateName) != null) {
      IsolateNameServer.removePortNameMapping(_isolateName);
    }

    IsolateNameServer.registerPortWithName(port.sendPort, _isolateName);

    port.listen(
      (dynamic data) async {
        // print('port.listen $data');
        // await updateUI(data);
      },
    );
*/
    await initPlatformState();
  }

  Future<void> initPlatformState() async {
    await BackgroundLocator.initialize();
    // isRunning = await BackgroundLocator.isRegisterLocationUpdate();
  }

  static void callback(LocationDto locationDto) async {
    saveLocation(locationDto);
    /* Send to port for update UI
      final SendPort send = IsolateNameServer.lookupPortByName(_isolateName);
      send?.send(locationDto);
    */
  }

  static void notificationCallback() {
    print('notificationCallback');
  }

  static Future<void> saveLocation(LocationDto data) async {
    final date = DateTime.now();
    if (!Hive.isBoxOpen('locationBox')) {
      Hive
      ..init('${data.dir}/db')
      ..registerAdapter(LocationEventAdapter());
    }

    Box box = await Hive.openBox('locationBox');
    Box settingBox = await Hive.openBox('settings');

    LocationEvent locationEvent = LocationEvent(
      latitude: data.latitude,
      longitude: data.longitude,
      altitude: data.altitude,
      startTime: date,
    );
    if (box.values.length > 0) {
      LocationEvent prevLocationEvent = box.values.last;
      //only save locations if a user has been there for _exposureTimeLimit (in seconds) or longer
      Duration timeSinceLastLocationEvent = date.difference(prevLocationEvent.startTime);
      if (timeSinceLastLocationEvent.inSeconds > _exposureTimeLimit){
        prevLocationEvent.endTime = date;
        prevLocationEvent.save();
      }
      else{
        prevLocationEvent.delete();
      }
    } else {
      // First run save time as last successful sync
      await settingBox.put('syncDate', DateTime.now());
    }
    await box.add(locationEvent);

    String userId = settingBox.get('id', defaultValue: null);
    if (userId == null) {
      // No user yet. Just log locations
      return;
    }
    DateTime syncDate = settingBox.get('syncDate', defaultValue: DateTime(1970));
    Duration difference = DateTime.now().difference(syncDate);
    // Setting to 30 seconds now so we get more updates
    if (difference.inSeconds >= 30) {
      var payload = StringBuffer();
      box.values.where((l) => l.startTime.isAfter(syncDate) && l.endTime != null)
      ..forEach((l) {
        payload.writeln(l.toPayloadString());
      });
      if (payload.isEmpty) {
        // There are no locations for upload.
        return;
      }
      ApiClient _apiClient = ApiClient();
      try {
        _apiClient.post('updateLocation', {'content': payload.toString()}, queryParameters: {'user_id': userId});
        await settingBox.put('syncDate', date);
      } catch (e) {
        print(e);
      }
    }
  }

  void startLocator() async {
    await BackgroundLocator.registerLocationUpdate(
      callback,
      androidNotificationCallback: notificationCallback,
      settings: LocationSettings(
        notificationTitle: "Start Location",
        notificationMsg: "Track location in background exapmle",
        wakeLockTime: 20,
        distanceFilter: 10,
        autoStop: false,
      ),
    );
  }
}