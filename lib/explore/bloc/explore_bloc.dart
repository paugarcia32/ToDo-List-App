import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todos_repository/todos_repository.dart';

part 'explore_event.dart';
part 'explore_state.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final TodosRepository todosRepository;

  ExploreBloc({required this.todosRepository}) : super(const ExploreState()) {
    on<TagsSubscriptionRequested>(_onTagsSubscriptionRequested);
  }

  Future<void> _onTagsSubscriptionRequested(TagsSubscriptionRequested event, Emitter<ExploreState> emit) async {
    emit(state.copyWith(status: ExploreStatus.loading));

    try {
      final tagsList = await todosRepository.getTags().first;

      final tags = tagsList.map((tag) => tag.title).toSet();

      emit(state.copyWith(status: ExploreStatus.success, tags: tags));
    } catch (e) {
      emit(state.copyWith(status: ExploreStatus.failure));
    }
  }
}
