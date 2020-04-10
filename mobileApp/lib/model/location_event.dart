import 'package:encryptions/encryptions.dart';
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

  Future<String> toPayloadString() async {
  // String toPayloadString(){
    int precision = 4;
    String long = longitude.toStringAsFixed(precision);
    String lat = latitude.toStringAsFixed(precision);
    String alt = altitude.toStringAsFixed(precision);

    var salt = utf8.encode('somelongrandomstring');

    var bytes = utf8.encode('$long$lat$alt');

    // var hash = md5.convert(bytes);
    Argon2 argon2 = Argon2(iterations: 16, hashLength: 64, memory: 256, parallelism: 2);
    var hash = await argon2.argon2i(bytes, salt);

    print('$key,$startTime,$endTime,$hash');
    return '$key,$startTime,$endTime,$hash';
  }

  @override
  String toString() {
    return '$latitude, $longitude, $floor, $startTime, $endTime';
  }
}