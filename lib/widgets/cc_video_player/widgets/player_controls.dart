import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_custom_components/widgets/cc_video_player/cc_video_player_controller.dart';
import 'package:flutter_custom_components/widgets/cc_video_player/model/player_model.dart';
import 'package:flutter_custom_components/widgets/cc_video_player/utils/utils.dart';
import 'package:provider/provider.dart';

class PlayerControls extends StatefulWidget {
  const PlayerControls({super.key});

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls> {
  final textStyle = const TextStyle(color: Colors.white, fontSize: 10);
  late double _maxHeight;
  late double _maxWidth;
  Timer? _showControlsTimer;
  bool showControls = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _showControlsTimer?.cancel();
    super.dispose();
  }

  // 开启ui
  void _startTimer() {
    _showControlsTimer?.cancel();
    showControls = true;
    _showControlsTimer = Timer(const Duration(seconds: 3), () {
      showControls = false;
      _showControlsTimer?.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _startTimer,
      behavior: HitTestBehavior.opaque,
      child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        _maxHeight = constraints.maxHeight;
        _maxWidth = constraints.maxWidth;
        return Consumer<CCVideoPlayerController>(
          builder: (context, _, child) {
            if (!showControls) return const Center();
            if (_.playerStatus.none) {
              return _.dataStatus.loaded
                  ? Center(
                      child: IconButton(
                          icon: const Icon(Icons.play_circle, size: 40, color: Colors.white),
                          onPressed: () => _.play()))
                  : const SizedBox();
            }
            return Stack(
              children: [
                _buildTopBar(_),
                _buildVideoStateWidget(_),
                _buildVolumeControls(_),
                _buildBrightnessControls(_),
                if (_.playerStatus.completed)
                  Center(
                      child:
                          IconButton(icon: const Icon(Icons.replay, color: Colors.white), onPressed: () => _.play())),
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
                          onTap: () => _.togglePlay(),
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(_.playerStatus.playing ? Icons.pause : Icons.play_arrow,
                                size: 20, color: Colors.white),
                          ),
                        ),
                        Text(
                          CCVideoPlayerUtils.printDuration(_.duration, _.sliderPosition),
                          style: textStyle,
                        ),
                        Expanded(
                            child: Container(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          constraints: const BoxConstraints(maxHeight: 30),
                          alignment: Alignment.center,
                          child: SliderTheme(
                            data: const SliderThemeData(
                              trackShape: CustomTrackShape(),
                              thumbColor: Colors.redAccent,
                              activeTrackColor: Colors.redAccent,
                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4.0),
                            ),
                            child: Slider(
                              min: 0,
                              divisions: null,
                              value: _.sliderPosition.inMilliseconds.toDouble(),
                              max: _.duration.inMilliseconds.toDouble(),
                              onChanged: (double value) {
                                _.seekTo(Duration(milliseconds: value.toInt()));
                              },
                            ),
                          ),
                        )),
                        Text(
                          CCVideoPlayerUtils.printDuration(_.duration, _.duration),
                          style: textStyle,
                        ),
                        if (_.quality != null)
                          GestureDetector(
                              onTap: () => _.onChangeVideoQuality(context),
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  _.quality?.label ?? '',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              )),
                        GestureDetector(
                          onTap: () {
                            _.setMute(!_.mute);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.all(5.0),
                            child: Icon(_.mute ? Icons.volume_off_outlined : Icons.volume_up_outlined,
                                size: 18, color: Colors.white),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_.fullscreen) {
                              Navigator.maybePop(context);
                            } else {
                              _.setVideoAsAppFullScreen(context);
                            }
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.all(5.0),
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
          },
        );
      }),
    );
  }

  _buildVideoStateWidget(CCVideoPlayerController _) {
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
        return const SizedBox();
    }
  }

  _buildTopBar(CCVideoPlayerController _) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.4),
          ])),
          child: Row(children: [
            GestureDetector(
                onTap: () {
                  Navigator.maybePop(context);
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.arrow_back_ios_new, size: 14, color: Colors.white),
                )),
            // Expanded(
            //     child: Text(_.videoPlayerController?.dataSource.toString() ?? '',
            //         style: const TextStyle(color: Colors.white, fontSize: 14),
            //         maxLines: 1,
            //         overflow: TextOverflow.ellipsis)),
            // GestureDetector(
            //     onTap: () {},
            //     child: const Padding(
            //       padding: EdgeInsets.all(8.0),
            //       child: Icon(Icons.more_horiz, size: 18, color: Colors.white),
            //     )),
          ])),
    );
  }

  _buildVolumeControls(CCVideoPlayerController _) {
    return Positioned(
        right: 0,
        bottom: 0,
        top: 0,
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            _.setVolume((-details.delta.dy / _maxHeight + _.currentVolume));
          },
          child: SizedBox(
            width: _maxWidth * 0.3,
            child: Center(child: Text('', style: textStyle)),
          ),
        ));
  }

  _buildBrightnessControls(CCVideoPlayerController _) {
    return Positioned(
        left: 0,
        bottom: 0,
        top: 0,
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            _.setBrightness((-details.delta.dy / _maxHeight + _.currentBrightness));
          },
          child: SizedBox(
            width: _maxWidth * 0.3,
            child: Center(child: Text('', style: textStyle)),
          ),
        ));
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  const CustomTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackWidth = parentBox.size.width;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight / 2) / 2;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
