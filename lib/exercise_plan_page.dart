import 'package:fitness_app/date_list_item_card.dart';
import 'package:fitness_app/exercise_list_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/select_list_item_card.dart';

class ExercisePlanPage extends StatefulWidget {
  final User? user;
  const ExercisePlanPage({super.key, required this.user});

  @override
  State<ExercisePlanPage> createState() => _ExercisePlanPageState();
}

class _ExercisePlanPageState extends State<ExercisePlanPage> {
  List<String> _selectedBodyParts = [];
  List<DateTime> _selectedDates = [];

  void _updateItem(item, selectedItems) {
    setState(() {
      switch (item) {
        case 1:
          _selectedBodyParts = selectedItems;
          break;
        case 2:
          _selectedDates = selectedItems;
          break;
        default:
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      appBar: AppBar(
        title: Text('Exercise'),
        actions: <Widget>[
          // TextButton with both an icon and text
          TextButton.icon(
            icon: const Icon(Icons.skip_next, color: Colors.white), // Set icon color for contrast
            label: const Text(
              'Generate',
              style: TextStyle(color: Colors.white), // Set text color for contrast
            ),
            onPressed: () {
              if (_selectedDates.isNotEmpty && _selectedBodyParts.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExerciseListPage(user: widget.user, selectedDates: _selectedDates, selectedBodyParts: _selectedBodyParts)),
                );
              }
              else {
                null;
              }
              // Navigator.pop(context);
            }
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Text("Generate exercise plan", style: theme.textTheme.displayMedium!.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold
                )
              ),
              SizedBox(height: 10),
              SelectListItem(
                title: 'Target Body Part',
                subtitle: 'This is the second item in the list.',
                icon: Icons.filter_2,
                options: [
                  "BACK",
                  "CALVES",
                  "CHEST",
                  "FOREARMS",
                  "HIPS",
                  "NECK",
                  "SHOULDERS",
                  "THIGHS",
                  "WAIST",
                  "HANDS",
                  "FEET",
                  "FACE",
                  "FULL BODY",
                  "BICEPS",
                  "UPPER ARMS",
                  "TRICEPS",
                  "HAMSTRINGS",
                  "QUADRICEPS"
                ],  
                isMultiSelect: true,
                onSelectedItemsChanged: (newSelectedItems) {
                  _updateItem(1, newSelectedItems);
                }
              ),
              SizedBox(height: 10), // Add spacing between items
              DateListItem(
                title: 'Select Available Dates',
                subtitle: 'Choose one or more dates for your event.',
                icon: Icons.calendar_month,
                // 2. The callback function to receive the updated list
                onSelectedDatesChanged: (newlySelectedDates) {
                  _updateItem(2, newlySelectedDates);
                },
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      )
    );
  }
}