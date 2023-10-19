import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_components/widgets/cc_video_player/cc_video_player.dart';
import 'package:flutter_custom_components/widgets/cc_video_player/cc_video_player_controller.dart';
import 'package:video_player/video_player.dart';

class CCVideoPlayerFullscreenPage extends StatefulWidget {
  final CCVideoPlayerController controller;
  final bool disposePlayer;
  const CCVideoPlayerFullscreenPage({super.key, required this.controller, this.disposePlayer = false});

  @override
  State<CCVideoPlayerFullscreenPage> createState() => _CCVideoPlayerFullscreenPageState();
}

class _CCVideoPlayerFullscreenPageState extends State<CCVideoPlayerFullscreenPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: AspectRatio(
            aspectRatio: widget.controller.videoPlayerController!.value.aspectRatio,
            child: VideoPlayer(
              widget.controller.videoPlayerController!,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.onFullscreenClose();
    super.dispose();
  }
}
