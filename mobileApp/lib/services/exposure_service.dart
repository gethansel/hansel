import 'dart:convert';

import 'package:covid_tracker/model/exposure_event.dart';
import 'package:covid_tracker/services/api_client.dart';
import 'package:covid_tracker/locator.dart';
import 'package:covid_tracker/services/local_storage_service.dart';

const USER_ID_KEY = 'id';

class ExposureService {



  final ApiClient _apiClient = locator<ApiClient>();
  final LocalStorageService _localStorageService =
      locator<LocalStorageService>();
  String get userId =>
      _localStorageService.settingsBox.get(USER_ID_KEY, defaultValue: null);

  // AARON NOTES:
  // This should be called on app open and there should be some indication on the app
  // that new possible exposure data is updating. 
  // This is a slow query I had to increase the timeout to 30 seconds for all calls.
  // I'm fine if you can just increase it for one.
  // Select City Run or City Bicycle Ride in the simulator to ensure there are overlaps
  Future<void> getContactLocations() async {
    Map params = {'user_id': userId};

    try {
      var data = await _apiClient.post('getContactLocations', {'content': 'empty'},
          queryParameters: Map<String, dynamic>.from(params));
      // print(data);
      // AARON NOTES:
      // I'm clearing for now just because it was easier to dev.
      // I'd want to update whatever's in the box with new values, but not overwrite
      // existing entries.
      await _localStorageService.exposuresBox.clear();
      data.forEach((event) async{
        var expEvent = ExposureEvent.fromJson(event);
        // print(expEvent.toString());
        await _localStorageService.exposuresBox.add(expEvent);
      });

      

    } catch (e) {
      print(e);
    }
  }
}
