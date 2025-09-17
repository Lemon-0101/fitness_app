import 'package:fitness_app/exercise_details_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/pressable_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ExerciseListPage extends StatefulWidget {
  final List<DateTime> selectedDates;
  final List<String> selectedBodyParts;
  const ExerciseListPage({super.key, required this.selectedDates, required this.selectedBodyParts});

  @override
  State<ExerciseListPage> createState() => _ExerciseListPageState();
}

class _ExerciseListPageState extends State<ExerciseListPage> {
  List<dynamic> cardData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  } 

  Future<void> _fetchData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final equipment = prefs.getStringList('equipment')?.join(',');

      final Map<String, String> queryParameters = {
        'bodyParts': widget.selectedBodyParts.join(','),
        'equipment': ?equipment,
        'limit': widget.selectedDates.length.toString(),
      };
      print(Uri.https('v2.exercisedb.dev', '/api/v1/exercises', queryParameters).toString());
      final response = await http.get(Uri.https('v2.exercisedb.dev', '/api/v1/exercises', queryParameters));

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        final data = json.decode(response.body);
        print('GET request successful! Data: $data');
        cardData = data["data"];
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

  String getDate(date) {
    final DateFormat formatter = DateFormat('MM/dd');
    return formatter.format(date);
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
        title: Text('Exercise List'),
        actions: <Widget>[
          TextButton.icon(
            icon: const Icon(Icons.menu, color: Colors.white),
            label: const Text(
              'Menu',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: cardData.length,
        itemBuilder: (context, index) {
          final data = cardData[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
            child: SizedBox(
              height: 200, // <-- Set a fixed height for the card
              child: PressableCardWithImage(
                title: data['name'],
                subtitle: getDate(widget.selectedDates[index]),
                backgroundImage: data['imageUrl'],
                onTap: () {
                  // Individual action for each card
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ExerciseDetailsPage(exerciseId: data['exerciseId'])),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}