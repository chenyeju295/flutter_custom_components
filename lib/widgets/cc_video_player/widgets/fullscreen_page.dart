import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_components/widgets/cc_video_player/cc_video_player_controller.dart';
import 'package:flutter_custom_components/widgets/cc_video_player/widgets/player_controls.dart';
import 'package:provider/provider.dart';
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
    return ChangeNotifierProvider.value(
      value: widget.controller,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: AspectRatio(
            aspectRatio: widget.controller.videoPlayerController!.value.aspectRatio,
            child: Selector<CCVideoPlayerController, VideoPlayerController?>(
              selector: (context, provider) => provider.videoPlayerController,
              builder: (context, value, child) {
                return Stack(
                  children: [VideoPlayer(widget.controller.videoPlayerController!), child ?? Container()],
                );
              },
              child: const Positioned.fill(child: PlayerControls()),
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
