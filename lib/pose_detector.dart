import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/pose_classifier_processor.dart';
import 'package:fitness_app/pose_painter.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

// Make sure you have the camera and google_mlkit_pose_detection packages in your pubspec.yaml

// We need a list of available cameras. This is often done in main.dart
// List<CameraDescription> cameras;

class PoseDetectorView extends StatefulWidget {
  final dynamic data;
  const PoseDetectorView({super.key, required this.data});

  @override
  State<PoseDetectorView> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  final PoseClassifierProcessor _classifierProcessor = PoseClassifierProcessor();
  // Detector instance
  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
      model: PoseDetectionModel.base,
    ),
  );

  // Camera controller
  CameraController? _cameraController;
  // A flag to prevent processing multiple images at once
  bool _isBusy = false;
  // Custom painter to draw the landmarks
  CustomPaint? _customPaint;
  // The size of the image being processed
  Size? _imageSize;

  String _poseResult = 'Initializing...';

  @override
  void initState() {
    super.initState();
    // Initialize the camera
    _startLiveFeed();
  }

  @override
  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _poseDetector.close();
    _classifierProcessor.close();
    super.dispose();
  }

  // Starts the camera stream
  Future<void> _startLiveFeed() async {
    // Get the back camera
    final camera = (await availableCameras()).firstWhere(
      (desc) => desc.lensDirection == CameraLensDirection.back,
    );

    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    // Initialize the camera and start the image stream
    _cameraController?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _cameraController?.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  // Processes each image frame from the camera
  Future<void> _processCameraImage(CameraImage cameraImage) async {
    // Return early if the detector is busy
    if (_isBusy) return;
    _isBusy = true;

    // Create InputImage from the camera frame
    final inputImage = _inputImageFromCameraImage(cameraImage);
    if (inputImage == null) {
      _isBusy = false;
      return;
    }

    // Process the image with the pose detector
    final List<Pose> poses = await _poseDetector.processImage(inputImage);
    // 
    
    // Create the custom painter to draw the poses
    if (poses.isNotEmpty) {
      final results = _classifierProcessor.getPoseResult(poses.first);
      setState(() {
        _poseResult = results.join('\n');
      });
      _customPaint = CustomPaint(
        painter: PosePainter(
          poses,
          _imageSize!,
        ),
      );
    } else {
      _customPaint = null;
    }
    
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  // Helper function to create InputImage from a CameraImage
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    _imageSize = Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );

    // Use the first plane's bytes
    final plane = image.planes.first;
    final bytes = _yuv420ToNV21(image);
    // Get the rotation of the camera for correct landmark orientation
    final rotation = _cameraController?.description.sensorOrientation;

    if (rotation == null) {
      return null;
    }

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: _imageSize!,
        rotation: _rotationFromDegrees(rotation),
        format: InputImageFormat.nv21, // Most Android devices
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  Uint8List _yuv420ToNV21(CameraImage image) {
    var nv21 = Uint8List(image.planes[0].bytes.length +
        image.planes[1].bytes.length +
        image.planes[2].bytes.length);
    var yBuffer = image.planes[0].bytes;
    var uBuffer = image.planes[1].bytes;
    var vBuffer = image.planes[2].bytes;

    nv21.setRange(0, yBuffer.length, yBuffer);

    int i = 0;
    for (var j = 0; j < uBuffer.length; j++) {
      nv21[yBuffer.length + i] = vBuffer[j];
      nv21[yBuffer.length + i + 1] = uBuffer[j];
      i += 2;
    }

    return nv21;
  }

  // Converts sensor orientation to InputImageRotation
  InputImageRotation _rotationFromDegrees(int degrees) {
    switch (degrees) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data["name"]),
      ),
      body: Stack(
        children: [
          // Display the camera feed
          CameraPreview(_cameraController!),
          // Overlay the pose detection landmarks
          if (_customPaint != null) 
            SizedBox.expand(
              child: _customPaint!,
            ),
          // Display the classification results
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _poseResult,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}