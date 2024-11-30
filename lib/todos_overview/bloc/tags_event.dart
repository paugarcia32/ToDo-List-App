// lib/todos_overview/bloc/tags_event.dart

part of 'tags_bloc.dart';

abstract class TagsEvent extends Equatable {
  const TagsEvent();

  @override
  List<Object> get props => [];
}

class TagsSubscriptionRequested extends TagsEvent {
  const TagsSubscriptionRequested();
}
