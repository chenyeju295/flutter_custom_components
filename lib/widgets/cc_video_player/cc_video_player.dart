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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => widget.controller,
      builder: (context, child) => _buildPage(context),
    );
  }

  Widget _buildPage(BuildContext context) {
    final _ = context.read<CCVideoPlayerController>();
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: Stack(alignment: Alignment.center, children: [
          Positioned.fill(
              child: _.videoPlayerController != null
                  ? VideoPlayer(key: _key, _.videoPlayerController!)
                  : const CircularProgressIndicator(strokeWidth: 3)),
          const Positioned.fill(child: PlayerControls())
        ]),
      ),
    );
  }
}
