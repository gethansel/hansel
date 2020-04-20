// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exposure_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExposureEventAdapter extends TypeAdapter<ExposureEvent> {
  @override
  final typeId = 1;

  @override
  ExposureEvent read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExposureEvent(
      recordId: fields[0] as int,
      startTime: fields[1] as DateTime,
      endTime: fields[2] as DateTime,
      hashLoc: fields[4] as String,
      dismissed: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ExposureEvent obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.recordId)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.dismissed)
      ..writeByte(4)
      ..write(obj.hashLoc);
  }
}
