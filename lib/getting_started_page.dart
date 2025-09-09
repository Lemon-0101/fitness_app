import 'package:fitness_app/main_page.dart';
import 'package:fitness_app/textbox_list_item_card.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_app/select_list_item_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GettingStartedPage extends StatefulWidget {
  final User? user;
  const GettingStartedPage({super.key, required this.user});

  @override
  State<GettingStartedPage> createState() => _GettingStartedPageState();
}

class _GettingStartedPageState extends State<GettingStartedPage> {
  List<String> _selectedDiet = [];
  List<String> _selectedIntolerances = [];
  List<String> _selectedFitnessLevel = [];
  List<String> _selectedEquipment = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (widget.user?.uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(widget.user?.uid).get().then((data) {
         if (mounted) {
          setState(() {
            if (data.exists) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainPage(user: widget.user)),
              );
            }
            else {
              _isLoading = false;
            }
          });
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        print("Failed to get data: $error");
      });
    }
  }

  void _updateItem(item, selectedItems) {
    setState(() {
      switch (item) {
        case 1:
          _selectedDiet = selectedItems;
          break;
        case 2:
          _selectedIntolerances = selectedItems;
          break;
        case 3:
          _selectedFitnessLevel = selectedItems;
          break;
        case 4:
          _selectedEquipment = selectedItems;
          break;
        default:
      }
    });
  }

  void _saveItem() {
    if (widget.user?.uid != null) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
      final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

      final Map<String, dynamic> userData = {
        'diet': _selectedDiet,
        'intolerances': _selectedIntolerances,
        'fitness_level': _selectedFitnessLevel,
        'equipment': _selectedEquipment,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      usersCollection.doc(widget.user?.uid).set(userData).then((_) async {
        print("User data saved successfully to Firestore!");
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        // Save the list using a key
        await prefs.setStringList('diet', _selectedDiet);
        await prefs.setStringList('intolerances', _selectedIntolerances);
        await prefs.setStringList('fitness_level', _selectedFitnessLevel);
        await prefs.setStringList('equipment', _selectedEquipment);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage(user: widget.user)),
        );
      }).catchError((error) {
        if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
        print("Failed to save data: $error");
      });
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
        title: Text('Hi, ${widget.user?.displayName ?? 'User'}!'),
        actions: <Widget>[
          // TextButton with both an icon and text
          TextButton.icon(
            icon: const Icon(Icons.skip_next, color: Colors.white), // Set icon color for contrast
            label: const Text(
              'Next',
              style: TextStyle(color: Colors.white), // Set text color for contrast
            ),
            onPressed: () {
              _saveItem();
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
              SelectListItem(
                title: 'Diet',
                subtitle: 'This is the first item in the list.',
                icon: Icons.filter_1,
                options: [
                  "Gluten Free",
                  "Ketogenic",
                  "Vegetarian",
                  "Lacto-Vegetarian",
                  "Ovo-Vegetarian",
                  "Vegan",
                  "Pescetarian",
                  "Paleo",
                  "Primal",
                  "Low FODMAP",
                  "Whole30",
                ],
                isMultiSelect: true,
                onSelectedItemsChanged: (newSelectedItems) {
                  _updateItem(1, newSelectedItems);
                }
              ),
              SizedBox(height: 10), // Add spacing between items
              SelectListItem(
                title: 'Intolerances/Allergies',
                subtitle: 'This is the second item in the list.',
                icon: Icons.filter_2,
                options: [
                  "Dairy",
                  "Egg",
                  "Gluten",
                  "Grain",
                  "Peanut",
                  "Seafood",
                  "Sesame",
                  "Shellfish",
                  "Soy",
                  "Sulfite",
                  "Tree Nut",
                  "Wheat"
                ],
                isMultiSelect: true,
                onSelectedItemsChanged: (newSelectedItems) {
                  _updateItem(2, newSelectedItems);
                }
              ),
              SizedBox(height: 10),
              SelectListItem(
                title: 'Fitness Level',
                subtitle: 'This is the third item in the list.',
                icon: Icons.filter_3,
                options: [
                  "Beginner",
                  "Intermediate",
                  "Pro"
                ],
                defaultSelectedItems: ["Beginner"],
                onSelectedItemsChanged: (newSelectedItems) {
                  _updateItem(3, newSelectedItems);
                }
              ),
              SizedBox(height: 10),
              SelectListItem(
                title: 'Equipment',
                subtitle: 'This is the fourth item in the list.',
                icon: Icons.filter_4,
                options: [
                  "Stepmill machine",
                  "Elliptical machine",
                  "Trap bar",
                  "Stationary bike",
                  "Wheel roller",
                  "Smith machine",
                  "Skierg machine",
                  "Roller",
                  "Resistance band",
                  "Bosu ball",
                  "Olympic barbell",
                  "Kettlebell",
                  "Upper body ergometer",
                  "Sled machine",
                  "EZ barbell",
                  "Dumbbell",
                  "Rope",
                  "Barbell",
                  "Band",
                  "Stability ball",
                  "Medicine ball",
                  "Leverage machine",
                  "Cable"
                ],
                isMultiSelect: true,
                onSelectedItemsChanged: (newSelectedItems) {
                  _updateItem(4, newSelectedItems);
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