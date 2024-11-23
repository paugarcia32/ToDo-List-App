import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/edit_todo/edit_todo.dart';
import 'package:todo_app/l10n/l10n.dart';
import 'package:todos_repository/todos_repository.dart';

class EditTodoPage extends StatelessWidget {
  const EditTodoPage({super.key});

  static Route<void> route({Todo? initialTodo}) {
    return MaterialPageRoute(
      fullscreenDialog: false,
      builder: (context) => BlocProvider(
        create: (context) => EditTodoBloc(
          todosRepository: context.read<TodosRepository>(),
          initialTodo: initialTodo,
        ),
        child: const EditTodoView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditTodoBloc, EditTodoState>(
      listenWhen: (previous, current) => previous.status != current.status && current.status == EditTodoStatus.success,
      listener: (context, state) => Navigator.of(context).pop(),
      child: const EditTodoView(),
    );
  }
}

class EditTodoView extends StatelessWidget {
  const EditTodoView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status = context.select((EditTodoBloc bloc) => bloc.state.status);
    final isNewTodo = context.select(
      (EditTodoBloc bloc) => bloc.state.isNewTodo,
    );

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isNewTodo ? l10n.editTodoAddAppBarTitle : l10n.editTodoEditAppBarTitle,
            ),
            const SizedBox(height: 16),
            const _TitleField(),
            const SizedBox(height: 16),
            const _DescriptionField(),
            const SizedBox(height: 16),
            const _TagsField(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed:
                  status.isLoadingOrSuccess ? null : () => context.read<EditTodoBloc>().add(const EditTodoSubmitted()),
              child:
                  status.isLoadingOrSuccess ? const CupertinoActivityIndicator() : Text(l10n.editTodoSaveButtonTooltip),
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleField extends StatelessWidget {
  const _TitleField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<EditTodoBloc>().state;
    final hintText = state.initialTodo?.title ?? '';

    return TextFormField(
      key: const Key('editTodoView_title_textFormField'),
      initialValue: state.title,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: l10n.editTodoTitleLabel,
        hintText: hintText,
      ),
      maxLength: 50,
      inputFormatters: [
        LengthLimitingTextInputFormatter(50),
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
      ],
      onChanged: (value) {
        context.read<EditTodoBloc>().add(EditTodoTitleChanged(value));
      },
    );
  }
}

class _DescriptionField extends StatelessWidget {
  const _DescriptionField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final state = context.watch<EditTodoBloc>().state;
    final hintText = state.initialTodo?.description ?? '';

    return TextFormField(
      key: const Key('editTodoView_description_textFormField'),
      initialValue: state.description,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: l10n.editTodoDescriptionLabel,
        hintText: hintText,
      ),
      inputFormatters: [
        LengthLimitingTextInputFormatter(300),
      ],
      onChanged: (value) {
        context.read<EditTodoBloc>().add(EditTodoDescriptionChanged(value));
      },
    );
  }
}

class _TagsField extends StatefulWidget {
  const _TagsField();

  @override
  _TagsFieldState createState() => _TagsFieldState();
}

class _TagsFieldState extends State<_TagsField> {
  final TextEditingController _controller = TextEditingController();
  List<String> _allTags = [];
  StreamSubscription<List<Todo>>? _todosSubscription;

  @override
  void initState() {
    super.initState();
    _loadAllTags();
  }

  void _loadAllTags() {
    final todosRepository = context.read<TodosRepository>();
    _todosSubscription = todosRepository.getTodos().listen((todos) {
      final Set<String> tagsSet = {};
      for (var todo in todos) {
        tagsSet.addAll(todo.tags ?? []);
      }
      setState(() {
        _allTags = tagsSet.toList();
      });
    });
  }

  void _addTag(String tag) {
    if (tag.trim().isEmpty) return;

    final bloc = context.read<EditTodoBloc>();
    final tags = List<String>.from(bloc.state.tags);
    final newTag = tag.trim();

    if (!tags.contains(newTag)) {
      tags.add(newTag);
      bloc.add(EditTodoTagsChanged(tags));
    }

    _controller.clear();
  }

  void _removeTag(String tag) {
    final bloc = context.read<EditTodoBloc>();
    final tags = List<String>.from(bloc.state.tags);

    tags.remove(tag);
    bloc.add(EditTodoTagsChanged(tags));
  }

  @override
  void dispose() {
    _todosSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditTodoBloc>().state;
    final tags = state.tags;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags
              .map(
                (tag) => InputChip(
                  label: Text(tag),
                  onDeleted: () => _removeTag(tag),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return _allTags.where((String option) {
              return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (String selection) {
            _addTag(selection);
          },
          fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController,
              FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
            return TextField(
              controller: fieldTextEditingController,
              focusNode: fieldFocusNode,
              decoration: InputDecoration(
                labelText: 'Add tag',
                hintText: 'Enter a tag',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addTag(fieldTextEditingController.text),
                ),
              ),
              onSubmitted: (String value) {
                _addTag(value);
              },
            );
          },
        ),
      ],
    );
  }
}
