import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class DateListItem extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final ValueChanged<List<DateTime>> onSelectedDatesChanged;

  const DateListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onSelectedDatesChanged,
  });

  @override
  _DateListItemState createState() => _DateListItemState();
}

class _DateListItemState extends State<DateListItem> {
  List<DateTime> _selectedDates = [];

  void _showSelectionDialog() async {
    final List<DateTime>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiDateDialog(
          selectedDates: _selectedDates,
        );
      },
    );

    if (results != null) {
      setState(() {
        _selectedDates = results;
        widget.onSelectedDatesChanged(_selectedDates);
      });
    }
  }

  void _removeDate(DateTime date) {
    setState(() {
      _selectedDates.remove(date);
      widget.onSelectedDatesChanged(_selectedDates);
    });
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
            leading: Icon(widget.icon),
            title: Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(widget.subtitle),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _selectedDates.map((date) {
                return Chip(
                  label: Text(DateFormat('MM/dd').format(date)),
                  onDeleted: () => _removeDate(date),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _showSelectionDialog,
              child: const Text('Select Dates'),
            ),
          ),
        ],
      ),
    );
  }
}

class MultiDateDialog extends StatefulWidget {
  final List<DateTime> selectedDates;

  const MultiDateDialog({
    super.key,
    required this.selectedDates,
  });

  @override
  _MultiDateDialogState createState() => _MultiDateDialogState();
}

class _MultiDateDialogState extends State<MultiDateDialog> {
  // Use a Set to manage temporary selections in the dialog
  late Set<DateTime> _tempSelectedDates;
  DateTime _focusedDay = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    // Initialize with the dates passed from the parent widget
    _tempSelectedDates = Set.from(widget.selectedDates);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      if (_tempSelectedDates.contains(selectedDay)) {
        _tempSelectedDates.remove(selectedDay);
      } else {
        _tempSelectedDates.add(selectedDay);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Dates'),
      content: SizedBox( // Give the SingleChildScrollView a fixed size
        height: 400.0, // Adjust the height as needed
        width: double.maxFinite, // Use the maximum width available
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TableCalendar(
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                selectedDayPredicate: (day) {
                  return _tempSelectedDates.contains(day);
                },
                onDaySelected: _onDaySelected,
                calendarFormat: CalendarFormat.month,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                enabledDayPredicate: (day) {
                return !day.isBefore(DateTime.now());
              },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Return null on cancel
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_tempSelectedDates.toList()),
          child: const Text('OK'),
        ),
      ],
    );
  }
}