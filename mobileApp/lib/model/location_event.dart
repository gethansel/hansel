import 'package:hive/hive.dart';
import 'dart:convert' show utf8;
import 'package:crypto/crypto.dart';

part 'location_event.g.dart';

@HiveType(typeId: 0)
class LocationEvent extends HiveObject {
  @HiveField(0)
  final double latitude;
  @HiveField(1)
  final double longitude;
  @HiveField(2)
  final double altitude;
  @HiveField(3)
  final int floor;
  @HiveField(4)
  final DateTime startTime;
  @HiveField(5)
  DateTime endTime;

  LocationEvent({
    this.latitude,
    this.longitude,
    this.altitude,
    this.floor = 0,
    this.startTime,
    this.endTime
  });

  String toPayloadString() {
    int precision = 4;
    String long = longitude.toStringAsFixed(precision);
    String lat = latitude.toStringAsFixed(precision);
    String alt = altitude.toStringAsFixed(precision);

    var bytes = utf8.encode('$long$lat$alt');

    var locationHash = md5.convert(bytes);
    return '$key,$startTime,$endTime,$locationHash';
  }

  @override
  String toString() {
    return '$latitude, $longitude, $floor, $startTime, $endTime';
  }
}