import 'package:fitness_app/fullscreen_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      _controller.setLooping(true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return InkWell(
            onTap: () {
              setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              });
            },
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  VideoPlayer(_controller),
                  if (!_controller.value.isPlaying)
                    const Positioned.fill(
                      child: Center(
                        child: Icon(Icons.play_arrow, size: 50, color: Colors.black),
                      ),
                    ),
                  // Fullscreen button
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: IconButton(
                      icon: const Icon(Icons.fullscreen, color: Colors.black),
                      onPressed: () {
                        // Pause the current video and push the new screen
                        _controller.pause();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                FullscreenVideoPlayer(controller: _controller),
                          ),
                        ).then((_) {
                          // Resume the video after returning from fullscreen
                          _controller.play();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}