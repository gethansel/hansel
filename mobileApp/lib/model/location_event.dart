import 'dart:typed_data';
import 'dart:convert';

import 'package:hive/hive.dart';
import 'dart:convert' show utf8;
import 'package:crypto/crypto.dart';
import 'package:encryptions/encryptions.dart';
import 'package:convert/convert.dart';
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

  Future<String> toPayloadString() async{
    int precision = 4;
    String long = longitude.toStringAsFixed(precision);
    String lat = latitude.toStringAsFixed(precision);
    String alt = altitude.toStringAsFixed(precision);

    var bytes = utf8.encode('$long$lat$alt');
    Argon2 argon2 = Argon2();
    Uint8List salt = utf8.encode('somesalt');
    Uint8List hash = await argon2.argon2id(bytes, salt);
    String locationHash = hex.encode(hash);
    return '$key,$startTime,$endTime,$locationHash';
  }

  @override
  String toString() {
    return '$latitude, $longitude, $floor, $startTime, $endTime';
  }
}