import 'package:covid_tracker/model/location_event.dart';
import 'package:hive/hive.dart';

//based on user_id = 51
createTestLocations() async {
  Box box = await Hive.openBox('locationBox');
  await box.put(68, LocationEvent(
    latitude: 33.874574,
    longitude: -117.558228,
    altitude: 10.0,
    startTime: DateTime.parse('2020-04-11 09:25:03.852'),
    endTime: DateTime.parse('2020-04-11 09:26:37.757'),
  ));
  await box.put(311, LocationEvent(
    latitude: 33.871772,
    longitude: -117.549097,
    altitude: 10.0,
    startTime: DateTime.parse('2020-04-11 09:36:03.133'),
    endTime: DateTime.parse('2020-04-11 09:36:39.146'),
  ));
  await box.put(170, LocationEvent(
    latitude: 33.872727,
    longitude: -117.558857,
    altitude: 10.0,
    startTime: DateTime.parse('2020-04-11 09:30:27.734'),
    endTime: DateTime.parse('2020-04-11 09:30:53.886'),
  ));
  await box.put(436, LocationEvent(
    latitude: 33.869493,
    longitude: -117.548829,
    altitude: 10.0,
    startTime: DateTime.parse('2020-04-11 09:40:43.126'),
    endTime: DateTime.parse('2020-04-11 09:42:17.036'),
  ));
}