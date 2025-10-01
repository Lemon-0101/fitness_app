import 'package:fitness_app/pose_detector.dart';
import 'package:fitness_app/pose_detector_page.dart';
import 'package:fitness_app/select_list_item_card.dart';
import 'package:fitness_app/video_player_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MealDetailsPage extends StatefulWidget {
  final String recipeId;
  const MealDetailsPage({super.key, required this.recipeId});

  @override
  State<MealDetailsPage> createState() => _MealDetailsPageState();
}

class _MealDetailsPageState extends State<MealDetailsPage> {
  dynamic cardData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  } 

  Future<void> _fetchData() async {
    try {
      final Map<String, String> queryParameters = {
        'apiKey': "7f8d7f5a07bb4e59b8ddbfb09698e7ba",
        'includeNutrition': 'true',
      };
      
      print(Uri.https('api.spoonacular.com', '/recipes/${widget.recipeId}/information', queryParameters).toString());
      final response = await http.get(Uri.https('api.spoonacular.com', '/recipes/${widget.recipeId}/information', queryParameters));

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        final data = json.decode(response.body);
        print('GET request successful! Data: $data');
        cardData = data;
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

  String getIngredients(data) {
    String temp_value = "";

    for (dynamic temp_data in data) {
      temp_value += temp_data["original"] + "\n";
    }

    temp_value = temp_value.substring(0, temp_value.lastIndexOf('\n'));

    return temp_value;
  }

  String getInstructions(data) {
    String temp_value = "";

    for (dynamic temp_data in data) {
      temp_value += "${temp_data["number"]}.) ${temp_data["step"]}\n";

      // if (temp_data["equipment"].length > 0) {
      //   String temp_equipment = "\t\t\t\t(Equipment: ";
      //   for (dynamic temp_data2 in temp_data["equipment"]) {
      //     temp_equipment += "${temp_data2["name"]},";
      //   }
      //   temp_value += "$temp_equipment)\n";
      // }

      // if (temp_data["ingredients"].length > 0) {
      //   String temp_ingredients = "\t\t\t\t(Ingredients: ";
      //   for (dynamic temp_data2 in temp_data["ingredients"]) {
      //     temp_ingredients += "${temp_data2["name"]},";
      //   }
      //   temp_value += "$temp_ingredients)\n";
      // }
    }

    temp_value = temp_value.substring(0, temp_value.lastIndexOf('\n'));

    return temp_value;
  }

  String getNutrients(data) {
    String temp_value = "";

    for (dynamic temp_data in data) {
      temp_value += "${temp_data["name"]}: ${temp_data["amount"]} ${temp_data["unit"]}\n";
    }

    temp_value = temp_value.substring(0, temp_value.lastIndexOf('\n'));

    return temp_value;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return DefaultTabController(
      length: 2, // Set the number of tabs you want
      child: Scaffold(
        backgroundColor: theme.colorScheme.primary,
        appBar: AppBar(
          title: Text(cardData["title"]),
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
          bottom: const TabBar(
            labelStyle: TextStyle(color: Colors.white),
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'Instruction'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Content for the 'Details' tab
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: Card(
                        elevation: 4, // Adds a shadow below the card
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0), // Adds rounded corners
                        ),
                        child: SizedBox(
                          child: Image.network(
                            "https://img.spoonacular.com/recipes/${cardData['id']}-636x393.jpg",
                            fit: BoxFit.fitWidth, // Ensures the image fills the space without distortion
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    SelectListItem(
                      title: 'Details:',
                      subtitle: "Name: ${cardData["title"]}\nPreparation Time: ${cardData["readyInMinutes"]} minutes\nServings: ${cardData["servings"]}\nCaloric Breakdow: Carbs ${cardData["nutrition"]["caloricBreakdown"]["percentCarbs"]}% Fat ${cardData["nutrition"]["caloricBreakdown"]["percentFat"]}% Protein ${cardData["nutrition"]["caloricBreakdown"]["percentProtein"]}%",
                    ),
                    SizedBox(height: 10),
                    SelectListItem(
                      title: 'Ingredients:',
                      subtitle: getIngredients(cardData["extendedIngredients"]),
                    ),
                    SizedBox(height: 10),
                    SelectListItem(
                      title: 'Nutrients:',
                      subtitle: getNutrients(cardData["nutrition"]["nutrients"]),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    SelectListItem(
                      title: 'Instructions:',
                      subtitle: getInstructions(cardData["analyzedInstructions"][0]["steps"]),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            // ListView.builder(
            //   itemCount: cardData["analyzedInstructions"][0]["steps"].length,
            //   itemBuilder: (context, index) {
            //     final data = cardData["analyzedInstructions"][0]["steps"][index];
            //     return Padding(
            //       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
            //       child: SizedBox(
            //         child: SelectListItem(
            //           title: data["step"],
            //           subtitle: data["number"].toString(),
            //         )
            //       ),
            //     );
            //   },
            // ),
          ],
        )
      )
    );
  }
}