import 'package:fitness_app/main_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/static_list_item_card.dart';

class GettingStartedPage extends StatelessWidget {
  final User? user;
  const GettingStartedPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      appBar: AppBar(
        title: Text('Hi, ${user?.displayName ?? 'User'}!'),
        actions: <Widget>[
          // TextButton with both an icon and text
          TextButton.icon(
            icon: const Icon(Icons.skip_next, color: Colors.white), // Set icon color for contrast
            label: const Text(
              'Next',
              style: TextStyle(color: Colors.white), // Set text color for contrast
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainPage(user: user)),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Text("Getting to know you!", style: theme.textTheme.displayMedium!.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold
                )
              ),
              SizedBox(height: 10),
              StaticListItem(
                title: 'Diet',
                subtitle: 'This is the first item in the list.',
                icon: Icons.filter_1,
                options: [
                  "Vegetarian",
                  "Vegan",
                  "Flexitarian",
                  "Ketogenic (Keto)",
                  "Atkins",
                  "Paleo",
                  "Low-Carb",
                  "Mediterranean",
                  "DASH (Dietary Approaches to Stop Hypertension)",
                  "MIND",
                  "Intermittent Fasting",
                  "Whole30",
                  "Gluten-Free"
                ],
                isMultiSelect: true,
              ),
              SizedBox(height: 10), // Add spacing between items
              StaticListItem(
                title: 'Intolerances',
                subtitle: 'This is the second item in the list.',
                icon: Icons.filter_2,
                options: [
                  "Lactose Intolerance",
                  "Gluten Intolerance",
                  "FODMAP Intolerance",
                  "Histamine Intolerance",
                  "Salicylate Sensitivity",
                  "Food Additive Intolerance",
                  "Caffeine Intolerance"
                ],
                isMultiSelect: true,
              ),
              SizedBox(height: 10),
              StaticListItem(
                title: 'Allergies',
                subtitle: 'This is the third item in the list.',
                icon: Icons.filter_3,
                options: [
                  "Milk",
                  "Eggs",
                  "Peanuts",
                  "Tree Nuts",
                  "Wheat",
                  "Soy",
                  "Fish",
                  "Crustacean Shellfish",
                  "Sesame"
                ],
                isMultiSelect: true,
              ),
              SizedBox(height: 10),
              StaticListItem(
                title: 'Fitness Level',
                subtitle: 'This is the fourth item in the list.',
                icon: Icons.filter_4,
                options: [
                  "Beginner",
                  "Intermediate",
                  "Pro"
                ],
                isMultiSelect: false,
              ),
            ],
          ),
        ),
      )
    );
  }
}