// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tag _$TagFromJson(Map<String, dynamic> json) => Tag(
      title: json['title'] as String,
      id: json['id'] as String?,
      isArchived: json['isArchived'] as bool? ?? false,
      color: json['color'] as String? ?? '#FFFFFFFF',
      todoIds:
          (json['todoIds'] as List<dynamic>?)?.map((e) => e as String).toSet(),
    );

Map<String, dynamic> _$TagToJson(Tag instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'isArchived': instance.isArchived,
      'color': instance.color,
      'todoIds': instance.todoIds.toList(),
    };
