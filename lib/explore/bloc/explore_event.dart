part of 'explore_bloc.dart';

sealed class ExploreEvent extends Equatable {
  const ExploreEvent();

  @override
  List<Object> get props => [];
}

final class TagsSubscriptionRequested extends ExploreEvent {
  const TagsSubscriptionRequested();
}

class TagDeleted extends ExploreEvent {
  const TagDeleted(this.tagId);

  final String tagId;

  @override
  List<Object> get props => [tagId];
}
