// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocationEventAdapter extends TypeAdapter<LocationEvent> {
  @override
  final typeId = 0;

  @override
  LocationEvent read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationEvent(
      latitude: fields[0] as double,
      longitude: fields[1] as double,
      altitude: fields[2] as double,
      floor: fields[3] as int,
      startTime: fields[4] as DateTime,
      endTime: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LocationEvent obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.latitude)
      ..writeByte(1)
      ..write(obj.longitude)
      ..writeByte(2)
      ..write(obj.altitude)
      ..writeByte(3)
      ..write(obj.floor)
      ..writeByte(4)
      ..write(obj.startTime)
      ..writeByte(5)
      ..write(obj.endTime);
  }
}
