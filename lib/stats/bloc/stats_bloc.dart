import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todos_api/todos_api.dart';
import 'package:todos_repository/todos_repository.dart';
import 'package:rxdart/rxdart.dart';

part 'stats_event.dart';
part 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  StatsBloc({
    required TodosRepository todosRepository,
  })  : _todosRepository = todosRepository,
        super(const StatsState()) {
    on<StatsSubscriptionRequested>(_onSubscriptionRequested);
  }

  final TodosRepository _todosRepository;

  Future<void> _onSubscriptionRequested(
    StatsSubscriptionRequested event,
    Emitter<StatsState> emit,
  ) async {
    emit(state.copyWith(status: StatsStatus.loading));

    await Future.wait([
      _subscribeToTodos(emit),
      _subscribeToTags(emit),
    ]);
  }

  Future<void> _subscribeToTodos(Emitter<StatsState> emit) async {
    try {
      await emit.forEach<List<Todo>>(
        _todosRepository.getTodos(),
        onData: (todos) => state.copyWith(
          completedTodos: todos.where((todo) => todo.isCompleted).length,
          activeTodos: todos.where((todo) => !todo.isCompleted).length,
        ),
        onError: (error, stackTrace) {
          print('Error al escuchar todos: $error');
          return state.copyWith(status: StatsStatus.failure);
        },
      );
    } catch (error) {
      print('Error general en _subscribeToTodos: $error');
      emit(state.copyWith(status: StatsStatus.failure));
    }
  }

  Future<void> _subscribeToTags(Emitter<StatsState> emit) async {
    try {
      await emit.forEach<List<Tag>>(
        _todosRepository.getTags(),
        onData: (tags) {
          final uniqueTagIds = tags.map((tag) => tag.id).toSet();
          print(uniqueTagIds);
          return state.copyWith(
            totalTags: uniqueTagIds.length,
            status: StatsStatus.success,
          );
        },
        onError: (error, stackTrace) {
          print('Error al escuchar tags: $error');
          return state.copyWith(status: StatsStatus.failure);
        },
      );
    } catch (error) {
      print('Error general en _subscribeToTags: $error');
      emit(state.copyWith(status: StatsStatus.failure));
    }
  }
}
