import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelectorField extends StatefulWidget {
  final String labelText;
  final String? initialDateString;
  final String? Function(String?)? validator;
  final Function(DateTime?)? onDateChanged;

  const DateSelectorField({
    super.key,
    required this.labelText,
    this.initialDateString,
    this.validator,
    this.onDateChanged,
  });

  @override
  State<DateSelectorField> createState() => _DateSelectorFieldState();
}

class _DateSelectorFieldState extends State<DateSelectorField> {
  final _dateController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialDateString != null) {
      try {
        _selectedDate = DateFormat('yyyy-MM-dd').parse(widget.initialDateString!);
        _dateController.text = widget.initialDateString!;
      } catch (e) {
        _selectedDate = null;
        _dateController.text = '';
      }
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      });
      widget.onDateChanged?.call(_selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _dateController,
      decoration: InputDecoration(
        labelText: widget.labelText,
        suffixIcon: const Icon(Icons.calendar_today),
        border: const OutlineInputBorder(),
      ),
      readOnly: true,
      onTap: () => _selectDate(context),
      validator: widget.validator,
    );
  }
}