import 'dart:convert';

import 'package:covid_tracker/model/exposure_event.dart';
import 'package:covid_tracker/services/api_client.dart';
import 'package:covid_tracker/locator.dart';
import 'package:covid_tracker/services/local_storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

const USER_ID_KEY = 'id';

class ExposureService {

  final ApiClient _apiClient = locator<ApiClient>();
  final LocalStorageService _localStorageService =
      locator<LocalStorageService>();
  String get userId =>
      _localStorageService.settingsBox.get(USER_ID_KEY, defaultValue: null);
  Stream get exposuresBox => _localStorageService.exposuresBox.watch();
  ValueListenable get exposureValueListenable => _localStorageService.exposuresBox.listenable();

  // Maybe we should cache sorted exposures
  List<ExposureEvent> get exposures {
    List<ExposureEvent> events = _localStorageService.exposuresBox.values.toList().cast<ExposureEvent>();
    events.sort((a,b) => b.timeSpent.compareTo(a.timeSpent));
    return events;
  }
  // AARON NOTES:
  // This should be called on app open and there should be some indication on the app
  // that new possible exposure data is updating.
  // This is a slow query I had to increase the timeout to 30 seconds for all calls.
  // I'm fine if you can just increase it for one.
  // Select City Run or City Bicycle Ride in the simulator to ensure there are overlaps

  Future<void> getContactLocations() async {
    Map params = {'user_id': 51};

    try {
      var data = await _apiClient.post(
        'getContactLocations',
        {'content': 'empty'},
        queryParameters: Map<String, dynamic>.from(params)
      );

      List<ExposureEvent> events = await compute(_parseExposureData, data as List);
      _storeExposureEvents(events);
    } catch (e) {
      print(e);
    }
  }

  static List<ExposureEvent> _parseExposureData(List<dynamic> data) {
    return data.map<ExposureEvent>((json) => ExposureEvent.fromJson(json)).toList();
  }

  Future<void> _storeExposureEvents(List<ExposureEvent> exposureEvents) async {
    Map<String, ExposureEvent> data = Map.fromIterable(
      exposureEvents,
      key: (e) => e.recordId.toString(),
      value: (e) {
        if (_localStorageService.exposuresBox.containsKey(e.recordId.toString())) {
          ExposureEvent storedEvent = _localStorageService.exposuresBox.get(e.recordId.toString());
          ExposureEvent updatedEvent = storedEvent.copyWithUpdate(e);
          return updatedEvent;
        }
        return e;
      });
    return _localStorageService.exposuresBox.putAll(data);
  }
}
