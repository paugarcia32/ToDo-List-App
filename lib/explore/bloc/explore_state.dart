part of 'explore_bloc.dart';

enum ExploreStatus { initial, loading, success, failure }

final class ExploreState extends Equatable {
  const ExploreState({
    this.status = ExploreStatus.initial,
    this.tags = const <Tag>{},
    this.numOfTodos = 0,
    this.title = "",
    this.color = "#FFFFFF",
  });

  final ExploreStatus status;
  final Set<Tag> tags;
  final int numOfTodos;
  final String title;
  final String color;

  @override
  List<Object> get props => [
        status,
        tags,
        numOfTodos,
        title,
        color,
      ];

  ExploreState copyWith({
    ExploreStatus? status,
    Set<Tag>? tags,
    int? numOfTodos,
    String? title,
    String? color,
  }) {
    return ExploreState(
      status: status ?? this.status,
      tags: tags ?? this.tags,
      numOfTodos: numOfTodos ?? this.numOfTodos,
      title: title ?? this.title,
      color: color ?? this.color,
    );
  }
}
