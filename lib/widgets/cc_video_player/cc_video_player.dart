import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import 'cc_video_player_controller.dart';
import 'widgets/player_controls.dart';

class CCVideoPlayer extends StatefulWidget {
  final CCVideoPlayerController controller;

  const CCVideoPlayer({super.key, required this.controller});

  @override
  State<CCVideoPlayer> createState() => _CCVideoPlayerState();
}

class _CCVideoPlayerState extends State<CCVideoPlayer> {
  final ValueKey _key = const ValueKey(true);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => widget.controller,
      builder: (context, child) => _buildPage(context),
    );
  }

  Widget _buildPage(BuildContext context) {
    return Selector<CCVideoPlayerController, VideoPlayerController?>(
      selector: (context, provider) => provider.videoPlayerController,
      builder: (context, videoPlayerController, child) {
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            color: Colors.black,
            child: Stack(alignment: Alignment.center, children: [
              Positioned.fill(
                  child: videoPlayerController != null
                      ? VideoPlayer(key: _key, videoPlayerController)
                      : const Center(child: CircularProgressIndicator(strokeWidth: 3, color: Colors.green))),
              child ?? Container()
            ]),
          ),
        );
      },
      child: const Positioned.fill(child: PlayerControls()),
    );
  }
}
