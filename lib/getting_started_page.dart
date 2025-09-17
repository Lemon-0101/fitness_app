import 'package:fitness_app/date_selector_field.dart';
import 'package:fitness_app/main_page.dart';
import 'package:fitness_app/medical_history_page.dart';
import 'package:fitness_app/textbox_list_item_card.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_app/select_list_item_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_app/model/user.dart' as UserModel;

class GettingStartedPage extends StatefulWidget {
  const GettingStartedPage({super.key});

  @override
  State<GettingStartedPage> createState() => _GettingStartedPageState();
}

class _GettingStartedPageState extends State<GettingStartedPage> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _genders = ["Male", "Female"];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData () async {
    try {
      await UserModel.User().getData();
      if (UserModel.User().name.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      }
      else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('An unexpected error occurred: $e');
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
                  MaterialPageRoute(builder: (context) => MedicalHistoryPage()),
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
                Text("Personal Information", style: theme.textTheme.displayMedium!.copyWith(
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
                        TextFormField(
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name.';
                            }
                            return null; // Return null if the input is valid
                          },
                          onChanged: (value) {
                            UserModel.User().name = value;
                          },
                        ),
                        SizedBox(height: 10),
                        DateSelectorField(
                          labelText: "Birthdate",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your birthdate.';
                            }
                            return null; // Return null if the input is valid
                          },
                          onDateChanged: (value) {
                            UserModel.User().birthDate = value!;
                          },
                        ),
                        SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Gender',
                            border: OutlineInputBorder(),
                          ),
                          items: _genders.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              UserModel.User().gender = newValue!;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select an option';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            suffix: Text("cm"),
                            labelText: 'Height',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your height.';
                            }
                            return null; // Return null if the input is valid
                          },
                          onChanged: (value) {
                            UserModel.User().height = double.parse(value);
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            suffix: Text("kg"),
                            labelText: 'Weight',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your weight.';
                            }
                            return null; // Return null if the input is valid
                          },
                          onChanged: (value) {
                            UserModel.User().weight = double.parse(value);
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number.';
                            }
                            return null; // Return null if the input is valid
                          },
                          onChanged: (value) {
                            UserModel.User().phone = value;
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