import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/explore/bloc/explore_bloc.dart';
import 'package:todo_app/l10n/l10n.dart';
import 'package:todo_app/theme/theme.dart';

class AddTagModal extends StatefulWidget {
  const AddTagModal({super.key});

  @override
  State<AddTagModal> createState() => _AddTagModalState();
}

class _AddTagModalState extends State<AddTagModal> {
  String? _selectedColorHex;

  @override
  void initState() {
    super.initState();
    if (FlutterTodosTheme.predefinedColors.isNotEmpty) {
      final initialColor = FlutterTodosTheme.predefinedColors.first;
      _selectedColorHex = '#${initialColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
    }
  }

  void _onColorSelected(String colorHex) {
    setState(() {
      _selectedColorHex = colorHex;
    });

    context.read<ExploreBloc>().add(AddTagColor(_selectedColorHex!));
  }

  @override
  Widget build(BuildContext context) {
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
            const Divider(
              endIndent: 150,
              indent: 150,
            ),
            const SizedBox(height: 16),
            const _NameField(),
            const SizedBox(height: 16),
            _ColorDropdown(
              selectedColorHex: _selectedColorHex!,
              onColorSelected: _onColorSelected,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<ExploreBloc>().add(const AddTagSubmitted());
              },
              child: const Text("Add Tag"),
            ),
          ],
        ),
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField();

  @override
  Widget build(BuildContext context) {
    // final l10n = context.l10n;
    final state = context.watch<ExploreBloc>().state;
    final hintText = state.initialTag?.title ?? '';

    return TextFormField(
      initialValue: state.title,
      decoration: InputDecoration(
        labelText: "Tag Title",
        hintText: hintText,
      ),
      inputFormatters: [
        LengthLimitingTextInputFormatter(100),
      ],
      onChanged: (value) {
        context.read<ExploreBloc>().add(AddTagName(value));
      },
    );
  }
}

class _ColorDropdown extends StatelessWidget {
  final String selectedColorHex;
  final ValueChanged<String> onColorSelected;

  const _ColorDropdown({
    Key? key,
    required this.selectedColorHex,
    required this.onColorSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExploreBloc>().state;
    final colorEntries = FlutterTodosTheme.predefinedColorMap.entries.toList();

    return DropdownButton<String>(
      // value: selectedColorHex,
      value: state.color,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      onChanged: (String? newValue) {
        if (newValue != null) {
          onColorSelected(newValue);
        }
      },
      items: colorEntries.map((entry) {
        final colorName = entry.key;
        final color = entry.value;
        final colorHex = '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';

        return DropdownMenuItem<String>(
          value: colorHex,
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(getLocalizedColorName(context, colorName)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

String getLocalizedColorName(BuildContext context, String colorName) {
  final l10n = context.l10n;
  switch (colorName) {
    case "White":
      return l10n.colorWhite;
    case "Red":
      return l10n.colorRed;
    case "Orange":
      return l10n.colorOrange;
    case "Purple":
      return l10n.colorPurple;
    case "Dark Green":
      return l10n.colorDarkGreen;
    case "Light Green":
      return l10n.colorLightGreen;
    case "Sky Blue":
      return l10n.colorSkyBlue;
    case "Dark Blue":
      return l10n.colorDarkBlue;
    default:
      return colorName;
  }
}
