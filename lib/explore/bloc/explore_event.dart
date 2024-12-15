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

class TagAdded extends ExploreEvent {
  const TagAdded(this.addedTag);

  final Tag addedTag;

  @override
  List<Object> get props => [addedTag];
}

class TagEdited extends ExploreEvent {
  const TagEdited(this.deletedTag);

  final Tag deletedTag;

  @override
  List<Object> get props => [deletedTag];
}

class AddTagName extends ExploreEvent {
  const AddTagName(this.tagName);

  final String tagName;

  @override
  List<Object> get props => [tagName];
}

final class AddTagSubmitted extends ExploreEvent {
  const AddTagSubmitted();
}

class AddTagColor extends ExploreEvent {
  const AddTagColor(this.tagColor);

  final String tagColor;

  @override
  List<Object> get props => [tagColor];
}
