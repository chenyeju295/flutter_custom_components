import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import 'cc_video_player_controller.dart';

class CCVideoPlayer extends StatefulWidget {
  final CCVideoPlayerController controller;
  const CCVideoPlayer({super.key, required this.controller});

  @override
  State<CCVideoPlayer> createState() => _CCVideoPlayerState();
}

class _CCVideoPlayerState extends State<CCVideoPlayer> {
  @override
  Widget build(BuildContext context) {
    final _ = widget.controller;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: Stack(alignment: Alignment.center, children: [
          Positioned.fill(
            child: FittedBox(
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                  width: _.videoWidth(_.videoPlayerController),
                  height: _.videoHeight(_.videoPlayerController),
                  child: _.videoPlayerController != null ? VideoPlayer(_.videoPlayerController!) : Container()),
            ),
          ),
          Positioned.fill(child: GestureDetector(
            onTap: () {
              _.togglePlay();
              print(_.playerStatus.status);
              print(_.videoPlayerController?.value.isPlaying);
            },
          ))
        ]),
      ),
    );
  }
}
