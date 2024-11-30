import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:todos_api/src/models/json_map.dart';
import 'package:uuid/uuid.dart';

part 'tag.g.dart';

@immutable
@JsonSerializable()
class Tag extends Equatable {
  Tag({
    required this.title,
    String? id,
    this.isArchived = false,
    this.color = '#FFFFFF',
    Set<String>? todoIds,
  })  : assert(title.isNotEmpty, 'Title cannot be empty'),
        id = id?.isNotEmpty == true ? id! : const Uuid().v4(),
        todoIds = todoIds ?? <String>{};

  final String id;
  final String title;
  final bool isArchived;
  final String color;
  final Set<String> todoIds;

  Tag copyWith({
    String? id,
    String? title,
    bool? isArchived,
    String? color,
    Set<String>? todoIds,
  }) {
    return Tag(
      id: id ?? this.id,
      title: title ?? this.title,
      isArchived: isArchived ?? this.isArchived,
      color: color ?? this.color,
      todoIds: todoIds ?? this.todoIds,
    );
  }

  static Tag fromJson(JsonMap json) => _$TagFromJson(json);

  JsonMap toJson() => _$TagToJson(this);

  @override
  List<Object?> get props => [id, title, isArchived, color, todoIds];
}
