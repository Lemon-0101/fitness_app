import 'package:fitness_app/pose_detector.dart';
import 'package:fitness_app/pose_detector_page.dart';
import 'package:fitness_app/select_list_item_card.dart';
import 'package:fitness_app/video_player_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExerciseDetailsPage extends StatefulWidget {
  final User? user;
  final String exerciseId;
  const ExerciseDetailsPage({super.key, required this.user, required this.exerciseId});

  @override
  State<ExerciseDetailsPage> createState() => _ExerciseDetailsPageState();
}

class _ExerciseDetailsPageState extends State<ExerciseDetailsPage> {
  dynamic cardData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  } 

  Future<void> _fetchData() async {
    try {
      print(Uri.https('v2.exercisedb.dev', '/api/v1/exercises/${widget.exerciseId}').toString());
      final response = await http.get(Uri.https('v2.exercisedb.dev', '/api/v1/exercises/${widget.exerciseId}'));

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
          title: Text(cardData["name"]),
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
                            cardData["imageUrl"],
                            fit: BoxFit.contain, // Ensures the image fills the space without distortion
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    SelectListItem(
                      title: 'Details:',
                      subtitle: 'Name: ${cardData["name"]}\nEquipments: ${cardData["equipments"].join(",")}\nBody Parts: ${cardData["bodyParts"].join(",")}\nType: ${cardData["exerciseType"]}',
                    ),
                    SizedBox(height: 10),
                    SelectListItem(
                      title: 'Overview:',
                      subtitle: cardData["overview"],
                    ),
                    SizedBox(height: 10),
                    SelectListItem(
                      title: 'Tips:',
                      subtitle: cardData["exerciseTips"].join("\n\n"),
                    ),
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: VideoPlayerWidget(videoUrl: cardData["videoUrl"]),
                      ),
                    ),
                    SizedBox(height: 10),
                    SelectListItem(
                      title: 'Instructions:',
                      subtitle: cardData["instructions"].join("\n\n"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add your action here, for example:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PoseDetectorView(user: widget.user, data: cardData)),
            );
          },
          child: const Icon(Icons.start),
        ),
      )
    );
  }
}