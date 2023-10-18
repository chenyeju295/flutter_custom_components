import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_components/widgets/cc_video_player/cc_video_player_controller.dart';
import 'package:flutter_custom_components/widgets/cc_video_player/utils.dart';
import 'package:provider/provider.dart';

class PlayerControls extends StatefulWidget {
  const PlayerControls({super.key});

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls> {
  final textStyle = const TextStyle(color: Colors.white, fontSize: 14);

  @override
  Widget build(BuildContext context) {
    final _ = context.watch<CCVideoPlayerController>();
    if (_.dataStatus.loading) return const Center(child: CupertinoActivityIndicator(color: Colors.red));
    return Stack(children: [
      if (_.playerStatus.stopped)
        Center(
          child: IconButton(
              icon: const Icon(Icons.play_circle, color: Colors.white),
              onPressed: () {
                _.play();
              }),
        ),
      if (!_.playerStatus.stopped)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.4),
            ])),
            child: Row(
              children: [
                IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(_.playerStatus.playing ? Icons.pause : Icons.play_arrow, size: 16, color: Colors.white),
                    onPressed: () {
                      _.togglePlay();
                    }),
                Text(
                  printDuration(_.duration, _.sliderPosition),
                  style: textStyle,
                ),
                Expanded(
                    child: Container(
                  constraints: const BoxConstraints(
                    maxHeight: 30,
                  ),
                  alignment: Alignment.center,
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackShape: MSliderTrackShape(),
                      thumbColor: Colors.redAccent,
                      activeTrackColor: Colors.redAccent,
                      trackHeight: 10,
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
              ],
            ),
          ),
        )
    ]);
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
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2 + 4;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
