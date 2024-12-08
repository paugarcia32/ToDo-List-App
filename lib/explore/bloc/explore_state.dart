part of 'explore_bloc.dart';

enum ExploreStatus { initial, loading, success, failure }

final class ExploreState extends Equatable {
  const ExploreState({
    this.status = ExploreStatus.initial,
    this.tags = const <Tag>{},
    this.numOfTodos = 0,
    this.title = "",
    this.color = "#FFFFFF",
    this.initialTag,
  });

  final ExploreStatus status;
  final Set<Tag> tags;
  final int numOfTodos;
  final String title;
  final String color;
  final Tag? initialTag;

  bool get isNewTodo => initialTag == null;

  ExploreState copyWith({
    ExploreStatus? status,
    Set<Tag>? tags,
    int? numOfTodos,
    String? title,
    String? color,
    Tag? initialTag,
  }) {
    return ExploreState(
      status: status ?? this.status,
      tags: tags ?? this.tags,
      numOfTodos: numOfTodos ?? this.numOfTodos,
      title: title ?? this.title,
      color: color ?? this.color,
      initialTag: initialTag ?? this.initialTag,
    );
  }

  @override
  List<Object?> get props => [
        status,
        tags,
        numOfTodos,
        title,
        color,
        initialTag,
      ];
}
