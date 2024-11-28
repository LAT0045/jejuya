// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Schedule _$ScheduleFromJson(Map<String, dynamic> json) {
  var scheduleItems = json["ListDestination"] == null
      ? null
      : List<ScheduleItem>.from(
          json["ListDestination"].map((x) => ScheduleItem.fromJson(x)));
  return Schedule(
    id: json['Id'] as String,
    startTime: json['StartDate'] == null
        ? null
        : DateTime.parse(json['StartDate'] as String),
    endTime: json['EndDate'] == null
        ? null
        : DateTime.parse(json['EndDate'] as String),
    accommodation: json['Accommodation'] as String,
    name: json['Name'] as String,
    scheduleItems: scheduleItems,
  );
}

Map<String, dynamic> _$ScheduleToJson(Schedule instance) => <String, dynamic>{
      'id': instance.id,
      'startTime': instance.startTime?.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'accommodation': instance.accommodation,
      'name': instance.name,
    };
