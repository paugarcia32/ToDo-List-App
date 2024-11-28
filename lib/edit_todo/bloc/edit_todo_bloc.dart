import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todos_api/todos_api.dart';
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
            selectedTags: [],
          ),
        ) {
    on<EditTodoTitleChanged>(_onTitleChanged);
    on<EditTodoDescriptionChanged>(_onDescriptionChanged);
    on<EditTodoTagToggled>(_onTagToggled);
    on<EditTodoTagsChanged>(_onTagsChanged);
    on<EditTodoLoadTags>(_onLoadTags);
    on<EditTodoSubmitted>(_onSubmitted);

    add(const EditTodoLoadTags());
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

  void _onTagToggled(
    EditTodoTagToggled event,
    Emitter<EditTodoState> emit,
  ) {
    final updatedTags = [...state.selectedTags];
    if (updatedTags.contains(event.tag)) {
      updatedTags.remove(event.tag);
    } else {
      updatedTags.add(event.tag);
    }
    emit(state.copyWith(selectedTags: updatedTags));
  }

  void _onTagsChanged(
    EditTodoTagsChanged event,
    Emitter<EditTodoState> emit,
  ) {
    emit(state.copyWith(selectedTags: event.tags));
  }

  Future<void> _onLoadTags(
    EditTodoLoadTags event,
    Emitter<EditTodoState> emit,
  ) async {
    if (state.initialTodo != null && state.initialTodo!.tagIds.isNotEmpty) {
      final tagIds = state.initialTodo!.tagIds;

      final allTags = await _todosRepository.getTags().first;

      final selectedTags = allTags.where((tag) => tagIds.contains(tag.id)).toList();

      print('Tags seleccionados: ${selectedTags.map((tag) => tag.title).toList()}');

      emit(state.copyWith(selectedTags: selectedTags));
      print('tagIds en el Todo inicial: ${state.initialTodo!.tagIds}');
    } else {
      print('No hay Todo inicial o no tiene tags.');
    }

    print('tagIds en el Todo inicial: ${state.initialTodo?.tagIds}');
  }

  Future<void> _onSubmitted(
    EditTodoSubmitted event,
    Emitter<EditTodoState> emit,
  ) async {
    emit(state.copyWith(status: EditTodoStatus.loading));
    final todo = (state.initialTodo ?? Todo(title: '')).copyWith(
      title: state.title,
      description: state.description,
      tagIds: state.selectedTags.map((tag) => tag.id).toList(),
    );

    try {
      await _todosRepository.saveTodo(todo);
      emit(state.copyWith(status: EditTodoStatus.success));
      print('Tags en el todo guardado: ${todo.tagIds}');
      await Future.delayed(const Duration(milliseconds: 500));
      emit(state.copyWith(status: EditTodoStatus.initial));
    } catch (e) {
      emit(state.copyWith(status: EditTodoStatus.failure));
      await Future.delayed(const Duration(milliseconds: 500));
      emit(state.copyWith(status: EditTodoStatus.initial));
    }
  }
}
