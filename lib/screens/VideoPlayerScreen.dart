import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:unitedindians/values/colors.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String duration,link,name;
  VideoPlayerScreen(this.duration,this.link,this.name);
  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController _videoPlayerController1;
  ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController1 = VideoPlayerController.network(widget.link);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1,
      aspectRatio:2.0,
      autoPlay: true,      
      autoInitialize: true,
      looping: false,
      fullScreenByDefault: false,
      allowedScreenSleep: true,      
      showControlsOnInitialize: true,
     errorBuilder : (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _videoPlayerController1.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: black,
        ),
        child: Expanded(
          child: Center(
            child: Chewie(
              controller: _chewieController,
            ),
          ),
        ),
      ),
    );
  }
}
