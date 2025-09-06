// post_painter.dart
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;

  PosePainter(this.poses, this.imageSize);

  @override
  void paint(Canvas canvas, Size size) {
    // Save the original state of the canvas
    canvas.save();

    // Scale the canvas by -1 on the x-axis to flip it horizontally
    // and translate it to the right by the canvas width to bring it back into view.
    canvas.scale(-1, 1);
    canvas.translate(-size.width, 0);

    // Define paint properties for drawing the landmarks and lines
    final pointPaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0
      ..color = Colors.redAccent;
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.blueAccent;

    // Helper function to draw circles for each landmark
    void drawLandmark(Offset point) {
      canvas.drawCircle(point, 5, pointPaint);
    }

    // Helper function to draw a line between two landmarks
    void drawLine(PoseLandmark start, PoseLandmark end) {
      if (start.likelihood > 0.5 && end.likelihood > 0.5) {
        final Offset startPoint = Offset(
          start.x * size.width / imageSize.width,
          start.y * size.height / imageSize.height,
        );
        final Offset endPoint = Offset(
          end.x * size.width / imageSize.width,
          end.y * size.height / imageSize.height,
        );
        canvas.drawLine(startPoint, endPoint, linePaint);
      }
    }

    // Iterate through each detected pose
    for (final pose in poses) {
      // Draw a circle for each of the 33 landmarks
      for (final landmark in pose.landmarks.values) {
        final Offset point = Offset(
          landmark.x * size.width / imageSize.width,
          landmark.y * size.height / imageSize.height,
        );
        drawLandmark(point);
      }

      // Draw the connections (lines) between key landmarks to form a skeleton
      drawLine(pose.landmarks[PoseLandmarkType.leftShoulder]!,
          pose.landmarks[PoseLandmarkType.leftElbow]!);
      drawLine(pose.landmarks[PoseLandmarkType.leftElbow]!,
          pose.landmarks[PoseLandmarkType.leftWrist]!);
      drawLine(pose.landmarks[PoseLandmarkType.leftShoulder]!,
          pose.landmarks[PoseLandmarkType.leftHip]!);

      drawLine(pose.landmarks[PoseLandmarkType.rightShoulder]!,
          pose.landmarks[PoseLandmarkType.rightElbow]!);
      drawLine(pose.landmarks[PoseLandmarkType.rightElbow]!,
          pose.landmarks[PoseLandmarkType.rightWrist]!);
      drawLine(pose.landmarks[PoseLandmarkType.rightShoulder]!,
          pose.landmarks[PoseLandmarkType.rightHip]!);

      drawLine(pose.landmarks[PoseLandmarkType.leftHip]!,
          pose.landmarks[PoseLandmarkType.leftKnee]!);
      drawLine(pose.landmarks[PoseLandmarkType.leftKnee]!,
          pose.landmarks[PoseLandmarkType.leftAnkle]!);

      drawLine(pose.landmarks[PoseLandmarkType.rightHip]!,
          pose.landmarks[PoseLandmarkType.rightKnee]!);
      drawLine(pose.landmarks[PoseLandmarkType.rightKnee]!,
          pose.landmarks[PoseLandmarkType.rightAnkle]!);
    }

    // Restore the canvas to its original state to avoid affecting other widgets
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Repaint whenever the data changes
    return true;
  }
}