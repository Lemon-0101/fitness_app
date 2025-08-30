import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class FullscreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;

  const FullscreenVideoPlayer({super.key, required this.controller});

  @override
  State<FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<FullscreenVideoPlayer> {
  @override
  void initState() {
    super.initState();
    // Enter landscape mode when this widget is created
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    widget.controller.play();
  }

  @override
  void dispose() {
    // Return to portrait mode when this widget is removed
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add a simple AppBar to contain the close button
      appBar: AppBar(
        backgroundColor: Colors.white, // Set to black for a cinematic feel
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop(); // Pops the current screen off the stack
          },
        ),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: widget.controller.value.aspectRatio,
          child: VideoPlayer(widget.controller),
        ),
      ),
    );
  }
}