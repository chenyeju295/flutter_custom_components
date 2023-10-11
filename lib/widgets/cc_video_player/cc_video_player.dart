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
  double videoWidth(VideoPlayerController? controller) {
    double width = controller != null
        ? controller.value.size.width != 0
            ? controller.value.size.width
            : 640
        : 640;
    return width;
  }

  double videoHeight(VideoPlayerController? controller) {
    double height = controller != null
        ? controller.value.size.height != 0
            ? controller.value.size.height
            : 480
        : 480;
    return height;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => CCVideoPlayerController(),
      builder: (context, child) => _buildPage(context),
    );
  }

  Widget _buildPage(BuildContext context) {
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
                  width: videoWidth(_.videoPlayerController),
                  height: videoHeight(_.videoPlayerController),
                  child: _.videoPlayerController != null ? VideoPlayer(_.videoPlayerController!) : Container()),
            ),
          ),
          Positioned.fill(child: GestureDetector(
            onTap: () {
              _.togglePlay();
            },
          ))
        ]),
      ),
    );
  }
}
