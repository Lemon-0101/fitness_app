import 'package:fitness_app/exercise_details_page.dart';
import 'package:fitness_app/meal_details_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/pressable_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fitness_app/model/user.dart' as UserModel;

class MealListPage extends StatefulWidget {
  final List<String> selectedDuration;
  final String caloriesValue;
  const MealListPage({super.key, required this.selectedDuration, required this.caloriesValue});

  @override
  State<MealListPage> createState() => _MealListPageState();
}

class _MealListPageState extends State<MealListPage> {
  List<dynamic> cardData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  } 

  Future<void> _fetchData() async {
    try {

      final Map<String, String> queryParameters = {
        'apiKey': "3037ff4b4e9a453b9bd0a0de29aa97c2",
        'timeFrame': widget.selectedDuration[0],
        'targetCalories': widget.caloriesValue,
        'diet': UserModel.User().diets.join(','),
        'exclude': UserModel.User().allergies.join(','),
      };
      
      print(Uri.https('api.spoonacular.com', '/mealplanner/generate', queryParameters).toString());
      final response = await http.get(Uri.https('api.spoonacular.com', '/mealplanner/generate', queryParameters));

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        final data = json.decode(response.body);
        print('GET request successful! Data: $data');
        cardData = data["meals"];
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
        title: Text('Meal List'),
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
                title: data['title'],
                subtitle: "",
                backgroundImage: "https://img.spoonacular.com/recipes/${data['id']}-636x393.jpg",
                onTap: () {
                  // Individual action for each card
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MealDetailsPage(recipeId: data['id'].toString())),
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