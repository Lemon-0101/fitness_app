import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/static_list_item_card.dart';
import 'package:fitness_app/text_list_item_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ExercisePlanPage extends StatefulWidget {
  final User? user;
  const ExercisePlanPage({super.key, required this.user});

  @override
  State<ExercisePlanPage> createState() => _ExercisePlanPageState();
}

class _ExercisePlanPageState extends State<ExercisePlanPage> {
  List<String> _selectedDays = [];
  List<String> _selectedMuscles = [];
  String _numberOfDays = "";
  bool _isLoading = false;

  void _updateItem(item, selectedItems) {
    setState(() {
      switch (item) {
        case 1:
          _selectedDays = selectedItems;
          break;
        case 2:
          _selectedMuscles = selectedItems;
          break;
        case 3:
          _numberOfDays = selectedItems;
          break;
        default:
      }
    });
  }

  Future<void> _fetchData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final equipment = prefs.getStringList('equipment')?.join(',');

      final Map<String, String> queryParameters = {
        'muscles': _selectedMuscles.join(','),
        'equipment': ?equipment,
        'limit': _numberOfDays,
      };
      print(Uri.https('www.exercisedb.dev', '/api/v1/exercises/filter', queryParameters).toString());
      final response = await http.get(Uri.https('www.exercisedb.dev', '/api/v1/exercises/filter', queryParameters));

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        final data = json.decode(response.body);
        print('GET request successful! Data: $data');
      } else {
        // If the server did not return a 200 OK response,
        // throw an exception or handle the error.
        print('Failed to load data. Status code: ${response.statusCode}');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('An error occurred during the GET request: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
              _fetchData();
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
              StaticListItem(
                title: 'Days',
                subtitle: 'This is the first item in the list.',
                icon: Icons.filter_1,
                options: [
                  "Monday",
                  "Tuesday",
                  "Wednesday",
                  "Thursday",
                  "Friday",
                  "Saturday",
                  "Sunday",
                ],
                isMultiSelect: true,
                onSelectedItemsChanged: (newSelectedItems) {
                  _updateItem(1, newSelectedItems);
                }
              ),
              SizedBox(height: 10),
              StaticListItem(
                title: 'Target Muscle',
                subtitle: 'This is the second item in the list.',
                icon: Icons.filter_2,
                options: [
                  "shins",
                  "hands",
                  "sternocleidomastoid",
                  "soleus",
                  "inner thighs",
                  "lower abs",
                  "grip muscles",
                  "abdominals",
                  "wrist extensors",
                  "wrist flexors",
                  "latissimus dorsi",
                  "upper chest",
                  "rotator cuff",
                  "wrists",
                  "groin",
                  "brachialis",
                  "deltoids",
                  "feet",
                  "ankles",
                  "trapezius",
                  "rear deltoids",
                  "chest",
                  "quadriceps",
                  "back",
                  "core",
                  "shoulders",
                  "ankle stabilizers",
                  "rhomboids",
                  "obliques",
                  "lower back",
                  "hip flexors",
                  "levator scapulae",
                  "abductors",
                  "serratus anterior",
                  "traps",
                  "forearms",
                  "delts",
                  "biceps",
                  "upper back",
                  "spine",
                  "cardiovascular system",
                  "triceps",
                  "adductors",
                  "hamstrings",
                  "glutes",
                  "pectorals",
                  "calves",
                  "lats",
                  "quads",
                  "abs"
                ],  
                isMultiSelect: true,
                onSelectedItemsChanged: (newSelectedItems) {
                  _updateItem(2, newSelectedItems);
                }
              ),
              SizedBox(height: 10), // Add spacing between items
              TextListItem(
                title: 'Number of Days',
                subtitle: 'This is the third item in the list.',
                icon: Icons.filter_3,
                onChanged: (newValue) {
                  _updateItem(3, newValue);
                }
              ),
              SizedBox(height: 10), // Add spacing between items
            ],
          ),
        ),
      )
    );
  }
}