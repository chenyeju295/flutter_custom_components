import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_components/widgets/cc_video_player/cc_video_player_controller.dart';
import 'package:flutter_custom_components/widgets/cc_video_player/model/player_model.dart';
import 'package:flutter_custom_components/widgets/cc_video_player/utils.dart';
import 'package:provider/provider.dart';

class PlayerControls extends StatefulWidget {
  const PlayerControls({super.key});

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls> {
  final textStyle = const TextStyle(color: Colors.white, fontSize: 10);

  @override
  Widget build(BuildContext context) {
    final _ = context.watch<CCVideoPlayerController>();
    switch (_.dataStatus.status) {
      case DataStatus.none:
      case DataStatus.loading:
        return const Center(child: CircularProgressIndicator(strokeWidth: 3));
      case DataStatus.error:
        return const Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, size: 24, color: Colors.white),
            SizedBox(height: 4),
            Text('视频资源错误', style: TextStyle(color: Colors.white, fontSize: 10))
          ],
        ));
      case DataStatus.loaded:
        return _buildControls(_);
    }
  }

  Widget _buildControls(CCVideoPlayerController _) {
    switch (_.playerStatus.status) {
      case PlayerStatus.none:
      case PlayerStatus.paused:
        return Center(
            child: IconButton(
                icon: const Icon(Icons.play_circle, color: Colors.white),
                onPressed: () {
                  _.play();
                }));
      case PlayerStatus.completed:
      case PlayerStatus.playing:
        return Stack(
          children: [
            if (_.playerStatus.completed)
              Center(
                  child: IconButton(
                      icon: const Icon(Icons.replay, color: Colors.white),
                      onPressed: () {
                        _.play();
                      })),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.4),
                ])),
                child: Row(
                  children: [
                    GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(_.playerStatus.playing ? Icons.pause : Icons.play_arrow,
                              size: 20, color: Colors.white),
                        ),
                        onTap: () {
                          _.togglePlay();
                        }),
                    Text(
                      printDuration(_.duration, _.sliderPosition),
                      style: textStyle,
                    ),
                    Expanded(
                        child: Container(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      constraints: const BoxConstraints(maxHeight: 30),
                      alignment: Alignment.center,
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackShape: MSliderTrackShape(),
                          thumbColor: Colors.redAccent,
                          activeTrackColor: Colors.redAccent,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4.0),
                        ),
                        child: Slider(
                          min: 0,
                          divisions: null,
                          value: _.sliderPosition.inMilliseconds.toDouble(),
                          onChangeStart: (v) {},
                          onChangeEnd: (v) {},
                          max: _.duration.inMilliseconds.toDouble(),
                          onChanged: (double value) {},
                        ),
                      ),
                    )),
                    Text(
                      printDuration(_.duration, _.duration),
                      style: textStyle,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_.fullscreen) {
                          _.onFullscreenClose();
                          Navigator.of(context).pop();
                        } else {
                          _.setVideoAsAppFullScreen(context);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(!_.fullscreen ? Icons.fullscreen : Icons.fullscreen_exit,
                            size: 20, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        );
    }
  }
}

class MSliderTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    SliderThemeData? sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    const double trackHeight = 1;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight / 2) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
