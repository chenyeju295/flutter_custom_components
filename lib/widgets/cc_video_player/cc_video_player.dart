import 'package:flutter/material.dart';
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
    final _ = widget.controller;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: CCVideoPlayerProvider(
        controller: _,
        child: Container(
          color: Colors.black,
          child: Stack(alignment: Alignment.center, children: [
            Positioned.fill(
              child: FittedBox(
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                    width: _.videoWidth(_.videoPlayerController),
                    height: _.videoHeight(_.videoPlayerController),
                    child: _.videoPlayerController != null
                        ? VideoPlayer(key: _key, _.videoPlayerController!)
                        : GestureDetector(onTap: () => setState(() {}), child: const Center())),
              ),
            ),
            const Positioned.fill(child: PlayerControls())
          ]),
        ),
      ),
    );
  }
}

class CCVideoPlayerProvider extends InheritedWidget {
  final CCVideoPlayerController controller;

  const CCVideoPlayerProvider({
    Key? key,
    required Widget child,
    required this.controller,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}
