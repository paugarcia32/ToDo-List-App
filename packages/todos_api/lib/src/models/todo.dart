import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:todos_api/src/models/json_map.dart';
import 'package:todos_api/todos_api.dart';
import 'package:uuid/uuid.dart';

part 'todo.g.dart';

@immutable
@JsonSerializable()
class Todo extends Equatable {
  Todo({
    required this.title,
    String? id,
    this.description = '',
    this.isCompleted = false,
    Set<String>? tagIds,
    this.date,
  })  : assert(
          id == null || id.isNotEmpty,
          'id must either be null or not empty',
        ),
        id = id ?? const Uuid().v4(),
        tagIds = tagIds ?? <String>{};

  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final Set<String> tagIds;
  final DateTime? date;

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    Set<String>? tagIds,
    DateTime? date,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      tagIds: tagIds ?? this.tagIds,
      date: date ?? this.date,
    );
  }

  static Todo fromJson(JsonMap json) => _$TodoFromJson(json);

  JsonMap toJson() => _$TodoToJson(this);

  @override
  List<Object?> get props => [id, title, description, isCompleted, tagIds, date];
}
