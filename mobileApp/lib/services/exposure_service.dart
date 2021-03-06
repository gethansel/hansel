import 'dart:async';
import 'package:covid_tracker/model/exposure_event.dart';
import 'package:covid_tracker/services/api_client.dart';
import 'package:covid_tracker/locator.dart';
import 'package:covid_tracker/services/local_storage_service.dart';
import 'package:covid_tracker/services/user_service.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stream_transform/stream_transform.dart';

class ExposureService {

  final ApiClient _apiClient = locator<ApiClient>();
  final UserService _userService = locator<UserService>();
  final LocalStorageService _localStorageService =
      locator<LocalStorageService>();

  StreamController<bool> _stateStreamController = StreamController();
  Stream get loadingStateStream => _stateStreamController.stream;

  Stream get exposuresStream => _localStorageService.exposuresBox.watch().debounce(const Duration(milliseconds: 300));
  ValueListenable get exposureValueListenable => _localStorageService.exposuresBox.listenable();

  ExposureEvent get nextActiveExposure => exposures.firstWhere((e) => !e.dismissed, orElse: () => null);
  // Maybe we should cache sorted exposures
  List<ExposureEvent> get exposures {
    List<ExposureEvent> events = _localStorageService.exposuresBox.values.toList().cast<ExposureEvent>();
    events.sort((a,b) => b.timeSpent.compareTo(a.timeSpent));
    return events;
  }

  dispose() {
    _stateStreamController.close();
  }
  // AARON NOTES:
  // This should be called on app open and there should be some indication on the app
  // that new possible exposure data is updating.
  // This is a slow query I had to increase the timeout to 30 seconds for all calls.
  // I'm fine if you can just increase it for one.
  // Select City Run or City Bicycle Ride in the simulator to ensure there are overlaps

  Future<void> getContactLocations() async {
    Map params = {'user_id': _userService.userId};

    try {
      _stateStreamController.sink.add(true);
      var data = await _apiClient.post(
        'getContactLocations',
        {'content': 'empty'},
        queryParameters: Map<String, dynamic>.from(params)
      );

      List<ExposureEvent> events = await compute(_parseExposureData, data as List);
      _storeExposureEvents(events);
      _stateStreamController.sink.add(false);
    } catch (e) {
      print(e);
      _stateStreamController.sink.add(false);
    }
  }

  static List<ExposureEvent> _parseExposureData(List<dynamic> data) {
    return data.map<ExposureEvent>((json) => ExposureEvent.fromJson(json)).toList();
  }

  Future<void> _storeExposureEvents(List<ExposureEvent> exposureEvents) async {
    Map<String, ExposureEvent> data = Map();
    for (ExposureEvent e in exposureEvents) {
      if (_localStorageService.locationsBox.get(e.recordId) == null) {
        continue;
      }
      if (_localStorageService.exposuresBox.containsKey(e.recordId.toString())) {
        ExposureEvent storedEvent = _localStorageService.exposuresBox.get(e.recordId.toString());
        ExposureEvent updatedEvent = storedEvent.copyWithUpdate(e);
        data.putIfAbsent(e.recordId.toString(), () => updatedEvent);
      }
      data.putIfAbsent(e.recordId.toString(), () => e);
    }
    return _localStorageService.exposuresBox.putAll(data);
  }
}
