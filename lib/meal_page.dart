import 'package:fitness_app/date_selector_field.dart';
import 'package:fitness_app/fitness_page.dart';
import 'package:fitness_app/main_page.dart';
import 'package:fitness_app/textbox_list_item_card.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_app/select_list_item_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_app/model/user.dart' as UserModel;
import 'package:multi_select_flutter/multi_select_flutter.dart';

class MealPage extends StatefulWidget {
  const MealPage({super.key});

  @override
  State<MealPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _allergies = [ "Dairy", "Egg", "Gluten", "Grain", "Peanut", "Seafood", "Sesame", "Shellfish", "Soy", "Sulfite", "Tree Nut", "Wheat"];
  final List<String> _diets = ["Gluten Free", "Ketogenic", "Vegetarian", "Lacto-Vegetarian", "Ovo-Vegetarian", "Vegan", "Pescetarian", "Paleo", "Primal", "Low FODMAP", "Whole30"];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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
        title: null,
        actions: <Widget>[
          // TextButton with both an icon and text
          TextButton.icon(
            icon: const Icon(Icons.skip_next, color: Colors.white), // Set icon color for contrast
            label: const Text(
              'Next',
              style: TextStyle(color: Colors.white), // Set text color for contrast
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FitnessPage()),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Text("Meal Information", style: theme.textTheme.displayMedium!.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold
                  )
                ),
                SizedBox(height: 10),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MultiSelectDialogField(
                          items: _allergies.map((item) => MultiSelectItem<String>(item, item)).toList(),
                          title: const Text("Select Allergies"),
                          buttonText: const Text("Allergies"),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(
                              width: 1.0,
                            ),
                          ),
                          // Customize the button to match the text field's style
                          buttonIcon: const Icon(Icons.arrow_drop_down),
                          onConfirm: (results) {
                            setState(() {
                             UserModel.User().allergies = results;
                            });
                          },
                          validator: (values) {
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        MultiSelectDialogField(
                          items: _diets.map((item) => MultiSelectItem<String>(item, item)).toList(),
                          title: const Text("Select Diets"),
                          buttonText: const Text("Diets"),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(
                              width: 1.0,
                            ),
                          ),
                          // Customize the button to match the text field's style
                          buttonIcon: const Icon(Icons.arrow_drop_down),
                          onConfirm: (results) {
                            setState(() {
                             UserModel.User().diets = results;
                            });
                          },
                          validator: (values) {
                            return null;
                          },
                        ),
                      ]
                    )
                  )
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      )
    );
  }
}