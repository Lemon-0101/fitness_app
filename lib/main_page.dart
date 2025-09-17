import 'package:fitness_app/meal_plan_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/pressable_card.dart';
import 'package:fitness_app/exercise_plan_page.dart';
import 'package:fitness_app/model/user.dart' as UserModel;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<Map<String, String>> cardData = [
    {
      'title': 'Meal Plan',
      'subtitle': 'Your plate is your canvas; paint it with vibrant colors of nourishment.',
      'image': 'assets/images/food_card.png',
      'id': '1',
    },
    {
      'title': 'Exercise',
      'subtitle': 'Motivation is what gets you started. Habit is what keeps you going.',
      'image': 'assets/images/exercise_card.png',
      'id': '2',
    },
  ];

  void _navigateToPage(value) {
    switch (value) {
      case '1':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MealPlanPage()),
        );
        break;
      case '2':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ExercisePlanPage()),
        );
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      appBar: AppBar(
        title: Text('Hi, ${UserModel.User().name ?? 'User'}!'),
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              height: 200, // <-- Set a fixed height for the card
              child: PressableCardWithImage(
                title: data['title']!,
                subtitle: data['subtitle']!,
                backgroundImage: data['image']!,
                onTap: () {
                  // Individual action for each card
                  _navigateToPage(data['id']);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}