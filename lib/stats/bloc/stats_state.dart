part of 'stats_bloc.dart';

enum StatsStatus { initial, loading, success, failure }

final class StatsState extends Equatable {
  const StatsState({
    this.status = StatsStatus.initial,
    this.completedTodos = 0,
    this.activeTodos = 0,
    this.totalTags = 0,
  });

  final StatsStatus status;
  final int completedTodos;
  final int activeTodos;
  final int totalTags;

  @override
  List<Object> get props => [status, completedTodos, activeTodos, totalTags];

  StatsState copyWith({
    StatsStatus? status,
    int? completedTodos,
    int? activeTodos,
    int? totalTags,
  }) {
    return StatsState(
      status: status ?? this.status,
      completedTodos: completedTodos ?? this.completedTodos,
      activeTodos: activeTodos ?? this.activeTodos,
      totalTags: totalTags ?? this.totalTags,
    );
  }
}
