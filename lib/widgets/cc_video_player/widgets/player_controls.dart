import 'package:flutter/material.dart';
import 'package:flutter_custom_components/widgets/cc_video_player/cc_video_player_controller.dart';

class PlayerControls extends StatefulWidget {
  const PlayerControls({super.key});

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls> {
  @override
  Widget build(BuildContext context) {
    final _ = CCVideoPlayerController.of(context);
    return Stack(children: [
      if (_.playerStatus.stopped)
        Center(
          child: IconButton(
              icon: const Icon(Icons.play_circle, color: Colors.white),
              onPressed: () {
                _.play();
                setState(() {});
              }),
        ),
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
                  icon: Icon(_.playerStatus.playing ? Icons.pause : Icons.play_arrow, size: 16, color: Colors.white),
                  onPressed: () {
                    _.togglePlay();
                    setState(() {});
                  }),
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
                    value: 200,
                    onChangeStart: (v) {},
                    onChangeEnd: (v) {},
                    max: 1000,
                    onChanged: (double value) {},
                  ),
                ),
              )),
              Text('进度', style: TextStyle(color: Colors.white))
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
