import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'exposure_event.g.dart';

@HiveType(typeId: 1)
class ExposureEvent extends HiveObject {
  @HiveField(0)
  final int recordId;
  @HiveField(1)
  final DateTime startTime;
  @HiveField(2)
  final DateTime endTime;
  @HiveField(3)
  bool dismissed;
  @HiveField(4)
  final String hashLoc;

  ExposureEvent({
    this.recordId,
    this.startTime,
    this.endTime,
    this.hashLoc,
    this.dismissed = false
  });

  factory ExposureEvent.fromJson(Map<String, dynamic> json) {
    return ExposureEvent(
      recordId: int.parse(json['record_id']),
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      hashLoc: json['hash_loc'],
      dismissed: false,
    );
  }

  ExposureEvent copyWithUpdate(ExposureEvent event) {
    return ExposureEvent(
      recordId: recordId,
      startTime: event.startTime ?? startTime,
      endTime: event.endTime ?? endTime,
      hashLoc: event.hashLoc ?? hashLoc,
      dismissed: dismissed,
    );
  }

  Duration get timeSpent => endTime.difference(startTime);

  String get formattedStartDate => DateFormat('EEE, MMM dd, yyyy').format(startTime);
  String get formattedStartTime => DateFormat('h:mm a').format(startTime);

  @override
  String toString() {
    String recId = recordId.toString();
    return '$key,$startTime,$endTime,$recId,$dismissed';
  }
}