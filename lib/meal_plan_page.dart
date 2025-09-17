import 'package:fitness_app/meal_list_page.dart';
import 'package:fitness_app/textbox_list_item_card.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/select_list_item_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MealPlanPage extends StatefulWidget {
  const MealPlanPage({super.key});

  @override
  State<MealPlanPage> createState() => _MealPlanPageState();
}

class _MealPlanPageState extends State<MealPlanPage> {
  List<String> _selectedDuration = [];
  String _caloriesValue = "";

  @override
  void initState() {
    super.initState();
  } 

  void _updateItem(item, selectedItems) {
    setState(() {
      switch (item) {
        case 1:
          _selectedDuration = selectedItems;
          break;
        case 2:
          _caloriesValue = selectedItems;
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
        title: Text('Meal'),
        actions: <Widget>[
          // TextButton with both an icon and text
          TextButton.icon(
            icon: const Icon(Icons.skip_next, color: Colors.white), // Set icon color for contrast
            label: const Text(
              'Generate',
              style: TextStyle(color: Colors.white), // Set text color for contrast
            ),
            onPressed: () {
              if (_selectedDuration.isNotEmpty && _caloriesValue.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MealListPage(selectedDuration: _selectedDuration, caloriesValue: _caloriesValue)),
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
              Text("Generate meal plan", style: theme.textTheme.displayMedium!.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold
                )
              ),
              SizedBox(height: 10),
              SelectListItem(
                title: 'Target Duration',
                subtitle: 'This is the first item in the list.',
                icon: Icons.filter_1,
                options: [
                  "Day",
                  "Week",
                ],
                defaultSelectedItems: ["Week"],
                isMultiSelect: false,
                onSelectedItemsChanged: (newSelectedItems) {
                  _updateItem(1, newSelectedItems);
                }
              ),
              SizedBox(height: 10), // Add spacing between items
              TextboxListItem(
                title: 'Target Calories',
                subtitle: 'This is the second item in the list.',
                icon: Icons.filter_2,
                onChanged: (newValue){
                  _updateItem(2, newValue);
                }
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      )
    );
  }
}