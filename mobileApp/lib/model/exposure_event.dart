import 'package:hive/hive.dart';

part 'exposure_event.g.dart';

@HiveType(typeId: 0)
class ExposureEvent extends HiveObject {
  @HiveField(0)
  final int recordId;
  @HiveField(1)
  final DateTime startTime;
  @HiveField(2)
  final DateTime endTime;
  @HiveField(3)
  bool dismissed;

  ExposureEvent({
    this.recordId,
    this.startTime,
    this.endTime,
    this.dismissed = false
  });

  factory ExposureEvent.fromJson(Map<String, dynamic> json) {
    return ExposureEvent(
      recordId: int.parse(json['record_id']),
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      dismissed: false,
    );
  }

  @override
  String toString() {
    String recId = recordId.toString();
    return '$key,$startTime,$endTime,$recId,$dismissed';
  }
}