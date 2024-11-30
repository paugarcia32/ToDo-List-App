// lib/todos_overview/bloc/tags_state.dart

part of 'tags_bloc.dart';

enum TagsStatus { initial, loading, success, failure }

class TagsState extends Equatable {
  const TagsState({
    this.status = TagsStatus.initial,
    this.tags = const [],
    this.tagIdToTitleMap = const {},
  });

  final TagsStatus status;
  final List<Tag> tags;
  final Map<String, String> tagIdToTitleMap;

  TagsState copyWith({
    TagsStatus? status,
    List<Tag>? tags,
    Map<String, String>? tagIdToTitleMap,
  }) {
    return TagsState(
      status: status ?? this.status,
      tags: tags ?? this.tags,
      tagIdToTitleMap: tagIdToTitleMap ?? this.tagIdToTitleMap,
    );
  }

  @override
  List<Object> get props => [status, tags, tagIdToTitleMap];
}
