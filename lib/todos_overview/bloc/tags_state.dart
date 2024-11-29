// lib/todos_overview/bloc/tags_state.dart

part of 'tags_bloc.dart';

enum TagsStatus { initial, loading, success, failure }

class TagsState extends Equatable {
  const TagsState({
    this.status = TagsStatus.initial,
    this.tags = const [],
  });

  final TagsStatus status;
  final List<Tag> tags;

  TagsState copyWith({
    TagsStatus? status,
    List<Tag>? tags,
  }) {
    return TagsState(
      status: status ?? this.status,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object> get props => [status, tags];
}
