import 'package:flutter/material.dart';

class SelectListItem extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final List<String> options;
  final bool isMultiSelect;
  final ValueChanged<List<String>> onSelectedItemsChanged;
  final List<String> defaultSelectedItems;

  const SelectListItem({
    super.key,
    required this.title,
    this.subtitle = "",
    this.icon,
    this.options = const [],
    this.isMultiSelect = false, // Default to multi-select
    this.onSelectedItemsChanged = _defaultOnChanged,
    this.defaultSelectedItems = const [],
  });

  static void _defaultOnChanged(List<String> items) {}

  @override
  _SelectListItemState createState() => _SelectListItemState();
}

class _SelectListItemState extends State<SelectListItem> {
  List<String> _selectedItems = [];

   @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.defaultSelectedItems);

    if (_selectedItems.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onSelectedItemsChanged(_selectedItems);
      });
    }
  }

  void _showSelectionDialog() async {
    dynamic results;
    if (widget.isMultiSelect) {
      results = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return MultiSelectDialog(
            options: widget.options,
            selectedOptions: _selectedItems,
          );
        },
      );
    } else {
      results = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SingleSelectDialog(
            options: widget.options,
            selectedOption: _selectedItems.isNotEmpty ? _selectedItems.first : null,
          );
        },
      );
    }

    if (results != null) {
      setState(() {
        if (widget.isMultiSelect) {
          _selectedItems = results as List<String>;
        } else {
          _selectedItems = [results as String];
        }
        widget.onSelectedItemsChanged(_selectedItems);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: widget.icon != null ? Icon(widget.icon) : null,
            title: Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(widget.subtitle),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _selectedItems.map((item) {
                return Chip(
                  label: Text(item),
                  onDeleted: widget.options.isNotEmpty ? () {
                    setState(() {
                      _selectedItems.remove(item);
                      widget.onSelectedItemsChanged(_selectedItems);
                    });
                  }
                  : null,
                );
              }).toList(),
            ),
          ),
          if (widget.options.isNotEmpty) 
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _showSelectionDialog,
                child: const Text('Select Options'),
              ),
            )
          else
            SizedBox(height: 14)
        ],
      ),
    );
  }
}

// A custom dialog widget for multi-select
class MultiSelectDialog extends StatefulWidget {
  final List<String> options;
  final List<String> selectedOptions;

  const MultiSelectDialog({
    super.key,
    required this.options,
    required this.selectedOptions,
  });

  @override
  _MultiSelectDialogState createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  final List<String> _tempSelectedOptions = [];

  @override
  void initState() {
    super.initState();
    _tempSelectedOptions.addAll(widget.selectedOptions);
  }

  void _onOptionSelected(String option, bool isSelected) {
    if (isSelected) {
      _tempSelectedOptions.add(option);
    } else {
      _tempSelectedOptions.remove(option);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Options'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.options.map((option) {
            return CheckboxListTile(
              title: Text(option),
              value: _tempSelectedOptions.contains(option),
              onChanged: (bool? isSelected) {
                setState(() {
                  _onOptionSelected(option, isSelected!);
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_tempSelectedOptions),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

// A custom dialog widget for single-select
class SingleSelectDialog extends StatefulWidget {
  final List<String> options;
  final String? selectedOption;

  const SingleSelectDialog({
    super.key,
    required this.options,
    this.selectedOption,
  });

  @override
  _SingleSelectDialogState createState() => _SingleSelectDialogState();
}

class _SingleSelectDialogState extends State<SingleSelectDialog> {
  String? _tempSelectedOption;

  @override
  void initState() {
    super.initState();
    _tempSelectedOption = widget.selectedOption;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select an Option'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.options.map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: _tempSelectedOption,
              onChanged: (String? value) {
                setState(() {
                  _tempSelectedOption = value;
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_tempSelectedOption),
          child: const Text('OK'),
        ),
      ],
    );
  }
}