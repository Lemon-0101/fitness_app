// pose_classifier_processor.dart

import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

enum RepetitionState {
  unknown,
  down,
  up,
}

class PoseClassifierProcessor {
  final String _modelPath = 'assets/model/pose_classifier.tflite'; 
  final List<String> _poseClasses = ['pushups_up', 'pushups_down', 'squats_up', 'squats_down']; 
  final double _minConfidence = 0.8;
  final int _bufferSize = 10; // Use a buffer of 5 frames

  late final Interpreter _interpreter;
  
  // Repetition counting state
  int _reps = 0;
  RepetitionState _lastState = RepetitionState.unknown;
  
  // Frame buffer for smoothing predictions
  final List<String> _poseBuffer = [];

  PoseClassifierProcessor() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(_modelPath);
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  List<String> getPoseResult(Pose pose) {
    if (pose.landmarks.isEmpty) {
      return ['No pose detected'];
    }

    var input = _convertPoseToModelInput(pose);
    var output = List.filled(_poseClasses.length, 0).reshape([1, _poseClasses.length]);
    
    if (_interpreter.isDeleted) {
      return ['Model not loaded'];
    }
    _interpreter.run(input, output);

    String classifiedPose = _processModelOutput(output);
    double confidence = _getConfidence(output);

    // Add the new pose to the buffer and remove the oldest if full
    _poseBuffer.add(classifiedPose);
    if (_poseBuffer.length > _bufferSize) {
      _poseBuffer.removeAt(0);
    }

    // Get the smoothed pose prediction from the buffer
    String smoothedPose = _getSmoothedPose();

    // Only process if the model's confidence is above the threshold
    if (confidence < _minConfidence) {
      return [
        'Pushups: $_reps reps',
        'Pose is uncertain: ${confidence.toStringAsFixed(2)}',
      ];
    }

    // Repetition counting logic using the smoothed pose
    if (smoothedPose == 'pushups_down') {
      if (_lastState == RepetitionState.unknown || _lastState == RepetitionState.up) {
        _lastState = RepetitionState.down;
      }
    } else if (smoothedPose == 'pushups_up') {
      if (_lastState == RepetitionState.down) {
        _reps++;
        _lastState = RepetitionState.up;
      }
    } else {
      _lastState = RepetitionState.unknown;
    }

    return [
      'Pushups: $_reps reps',
      '$smoothedPose: ${confidence.toStringAsFixed(2)} confidence',
    ];
  }

  String _getSmoothedPose() {
    if (_poseBuffer.isEmpty) {
      return 'No pose detected';
    }

    final Map<String, int> counts = {};
    for (var pose in _poseBuffer) {
      counts[pose] = (counts[pose] ?? 0) + 1;
    }
    
    String mostCommonPose = '';
    int maxCount = 0;
    counts.forEach((pose, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommonPose = pose;
      }
    });
    return mostCommonPose;
  }

  List<double> _convertPoseToModelInput(Pose pose) {
    List<double> flatData = [];
    for (var landmark in pose.landmarks.values) {
      flatData.addAll([landmark.x, landmark.y, landmark.z]);
    }
    return flatData;
  }

  String _processModelOutput(var output) {
    var confidences = output[0] as List<double>;
    double maxConfidence = 0.0;
    int maxIndex = 0;
    for (int i = 0; i < confidences.length; i++) {
      if (confidences[i] > maxConfidence) {
        maxConfidence = confidences[i];
        maxIndex = i;
      }
    }
    return _poseClasses[maxIndex];
  }

  double _getConfidence(var output) {
    var confidences = output[0] as List<double>;
    return confidences.reduce(max);
  }

  void close() {
    _interpreter.close();
  }
}