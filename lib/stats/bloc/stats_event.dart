part of 'stats_bloc.dart';

sealed class StatsEvent extends Equatable {
  const StatsEvent();

  @override
  List<Object> get props => [];
}

final class TodosSubscriptionRequested extends StatsEvent {
  const TodosSubscriptionRequested();
}

final class TagsSubscriptionRequested extends StatsEvent {
  const TagsSubscriptionRequested();
}
