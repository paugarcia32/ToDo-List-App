part of 'explore_bloc.dart';

enum ExploreStatus { initial, loading, success, failure }

final class ExploreState extends Equatable {
  const ExploreState({
    this.status = ExploreStatus.initial,
    this.tags = const <Tag>{},
    this.numOfTodos = 0,
  });

  final ExploreStatus status;
  final Set<Tag> tags;
  final int numOfTodos;

  @override
  List<Object> get props => [
        status,
        tags,
        numOfTodos,
      ];

  ExploreState copyWith({
    ExploreStatus? status,
    Set<Tag>? tags,
    int? numOfTodos,
  }) {
    return ExploreState(
      status: status ?? this.status,
      tags: tags ?? this.tags,
      numOfTodos: numOfTodos ?? this.numOfTodos,
    );
  }
}
