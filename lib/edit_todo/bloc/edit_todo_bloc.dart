import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todos_repository/todos_repository.dart';

part 'edit_todo_event.dart';
part 'edit_todo_state.dart';

class EditTodoBloc extends Bloc<EditTodoEvent, EditTodoState> {
  EditTodoBloc({
    required TodosRepository todosRepository,
    required Todo? initialTodo,
  })  : _todosRepository = todosRepository,
        super(
          EditTodoState(
              initialTodo: initialTodo,
              title: initialTodo?.title ?? '',
              description: initialTodo?.description ?? '',
              tags: initialTodo?.tags ?? []),
        ) {
    on<EditTodoTitleChanged>(_onTitleChanged);
    on<EditTodoDescriptionChanged>(_onDescriptionChanged);
    on<EditTodoTagsChanged>(_onTagsChanged);
    on<EditTodoSubmitted>(_onSubmitted);
  }

  final TodosRepository _todosRepository;

  void _onTitleChanged(
    EditTodoTitleChanged event,
    Emitter<EditTodoState> emit,
  ) {
    emit(state.copyWith(title: event.title));
  }

  void _onDescriptionChanged(
    EditTodoDescriptionChanged event,
    Emitter<EditTodoState> emit,
  ) {
    emit(state.copyWith(description: event.description));
  }

  void _onTagsChanged(EditTodoTagsChanged event, Emitter<EditTodoState> emit) {
    emit(state.copyWith(tags: event.tags));
  }

  Future<void> _onSubmitted(
    EditTodoSubmitted event,
    Emitter<EditTodoState> emit,
  ) async {
    emit(state.copyWith(status: EditTodoStatus.loading));
    final todo = (state.initialTodo ?? Todo(title: ''))
        .copyWith(title: state.title, description: state.description, tags: state.tags);

    try {
      await _todosRepository.saveTodo(todo);
      emit(state.copyWith(status: EditTodoStatus.success));
      // Resetear el estado después de un pequeño delay para que se vea el cambio de estado
      await Future.delayed(const Duration(milliseconds: 500));
      emit(state.copyWith(status: EditTodoStatus.initial));
    } catch (e) {
      emit(state.copyWith(status: EditTodoStatus.failure));
      // También resetear el estado después de un fallo
      await Future.delayed(const Duration(milliseconds: 500));
      emit(state.copyWith(status: EditTodoStatus.initial));
    }
  }
}
