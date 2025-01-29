// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
      id: json['id'] as String?,
      type: $enumDecode(_$ActivityTypeEnumMap, json['type']),
      rawContent: json['rawContent'] as String,
    );

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
      'id': instance.id,
      'type': _$ActivityTypeEnumMap[instance.type]!,
      'rawContent': instance.rawContent,
    };

const _$ActivityTypeEnumMap = {
  ActivityType.quiz: 'quiz',
  ActivityType.definition: 'definition',
};
