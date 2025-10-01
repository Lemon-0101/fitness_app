import 'package:fitness_app/exercise_details_page.dart';
import 'package:fitness_app/meal_details_page.dart';
import 'package:fitness_app/model/meal.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/pressable_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fitness_app/model/user.dart' as UserModel;
import 'package:table_calendar/table_calendar.dart';

// Helper function to get rid of time component for comparison
int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}


class MealListPage extends StatefulWidget {
  final List<String> selectedDuration;
  final String caloriesValue;
  const MealListPage({super.key, required this.selectedDuration, required this.caloriesValue});

  @override
  State<MealListPage> createState() => _MealListPageState();
}

class _MealListPageState extends State<MealListPage> {
  // Calendar State
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  // REMOVED: CalendarFormat _calendarFormat;

  // Note/Event State
  late final ValueNotifier<List<Meal>> _selectedEvents;
  late final List<Meal> Function(DateTime) _getEventsForDay;
  Map<DateTime, List<Meal>> cardData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _selectedDay = DateTime.utc(_focusedDay.year, _focusedDay.month, _focusedDay.day);
    
    // Define the function to get events for a day
    _getEventsForDay = (day) {
      return cardData[DateTime.utc(day.year, day.month, day.day)] ?? [];
    };

    // Initialize the ValueNotifier with today's events
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
    // REMOVED: format-related dispose
  }

  // Event handler when a date is selected
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    // if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      // Update the ValueNotifier with the new day's events
      _selectedEvents.value = _getEventsForDay(selectedDay);
    // }
  }

  Future<void> _fetchData() async {
    try {

      final Map<String, String> queryParameters = {
        'apiKey': "7f8d7f5a07bb4e59b8ddbfb09698e7ba",
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
        if (widget.selectedDuration[0] == "Day") {
          List<Meal> tempMeals = [];
          DateTime now = DateTime.now();
          DateTime utcDateOnly = DateTime.utc(
            now.year,
            now.month,
            now.day
          );
          for (dynamic mealData in data["meals"]){
            tempMeals.add(Meal(mealData["id"].toString(), mealData["title"], utcDateOnly));
          }
          cardData.addAll({utcDateOnly: tempMeals});
        } else {
          final Map<String, dynamic> weekData = data["week"];
          int index = 0;
          for (dynamic dayKey in weekData.keys){
            List<Meal> tempMeals = [];
            DateTime now = DateTime.now();
            now = now.add(Duration(days: index));
            DateTime utcDateOnly = DateTime.utc(
              now.year,
              now.month,
              now.day
            );
            for (dynamic mealData in weekData[dayKey]["meals"]){
              tempMeals.add(Meal(mealData["id"].toString(), mealData["title"], utcDateOnly));
            }
            cardData.addAll({utcDateOnly: tempMeals});
            index++;
          }
        }
        
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
      body: Column(
        children: [
          // 💡 WRAPPING THE CALENDAR IN A CARD 💡
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Card(
              // Optional: Customize the card's elevation or shape
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: TableCalendar<Meal>(
                // Ensure the calendar background is white to look clean inside the Card
                calendarStyle: const CalendarStyle(
                  defaultDecoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  weekendDecoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  todayDecoration: BoxDecoration(color: Color(0xFFE6E6E6), shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                  markerDecoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),

                  defaultTextStyle: TextStyle(color: Colors.black),
                  weekendTextStyle: TextStyle(color: Colors.red),
                ),
                
                // Header Customization (Can also use a white decoration here)
                headerStyle: const HeaderStyle(
                  decoration: BoxDecoration(color: Colors.white), 
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                
                // Calendar Logic Properties
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: _getEventsForDay,
                onDaySelected: _onDaySelected,
              ),
            ),
          ),
          
          // Separator line
          const SizedBox(height: 8.0),
          const Divider(thickness: 1),
          const SizedBox(height: 8.0),
          
          // Event List (Notes Display)
          Expanded(
            child: ValueListenableBuilder<List<Meal>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                if (value.isEmpty) {
                  return Center(
                    child: Text('No meals for ${_selectedDay.toString().split(' ')[0]}', style: TextStyle(color: Colors.white),),
                  );
                }
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
                      child: SizedBox(
                        height: 200, 
                        child: PressableCardWithImage(
                          title: value[index].title,
                          subtitle: "",
                          backgroundImage: "https://img.spoonacular.com/recipes/${value[index].id}-636x393.jpg",
                          onTap: () {
                            // Individual action for each card
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MealDetailsPage(recipeId: value[index].id.toString())),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      )
    );
  }
}