import 'package:camera/camera.dart';
import 'package:fitness_app/pose_detector.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PoseDetectorPage extends StatefulWidget {
  final User? user;
  final String exerciseId;
  const PoseDetectorPage({super.key, required this.user, required this.exerciseId});

  @override
  State<PoseDetectorPage> createState() => _PoseDetectorPageState();
}

class _PoseDetectorPageState extends State<PoseDetectorPage> {
  List<CameraDescription> cameras = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCamera();
  } 

  Future<void> _loadCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      cameras = await availableCameras();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } on CameraException catch (e) {
      debugPrint('Error: ${e.code}\nError Message: ${e.description}');
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
      body: const PoseDetectorView(user: null, data: null),
    );
  }
}