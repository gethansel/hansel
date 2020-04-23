import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';
import 'package:background_locator/location_settings.dart';
import 'package:covid_tracker/model/location_event.dart';
import 'package:covid_tracker/services/api_client.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class LocationService {
  final ReceivePort port = ReceivePort();
  // static final _isolateName = 'LocatorIsolate';
  bool isRunning = false;
  bool initialized = false;
  // static String _dbFilePath;
  static final _exposureTimeLimit = 60*0.1;
  StreamController<bool> _stateStreamController = StreamController();
  Stream get stateStream => _stateStreamController.stream;

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
    isRunning = await BackgroundLocator.isRegisterLocationUpdate();
    _stateStreamController.sink.add(isRunning);
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
    try {
      Directory dir = await getApplicationDocumentsDirectory();
      Hive
      ..init('${dir.path}/db')
      ..registerAdapter(LocationEventAdapter());
    } on HiveError {}


    final date = DateTime.now();

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
      List locations = box.values.where((l) => l.startTime.isAfter(syncDate) && l.endTime != null).toList();
      for (LocationEvent l in locations) {
        String payloadString = await l.toPayloadString();
        payload.writeln(payloadString);
      }
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
        notificationTitle: "Hansel",
        notificationMsg: "Hansel is tracking your Location",
        wakeLockTime: 20,
        distanceFilter: 10,
        autoStop: false,
      ),
    );
    isRunning = true;
    _stateStreamController.sink.add(isRunning);
  }

  void stopLocator() async {
    await BackgroundLocator.unRegisterLocationUpdate();
    isRunning = true;
    _stateStreamController.sink.add(false);
  }
}