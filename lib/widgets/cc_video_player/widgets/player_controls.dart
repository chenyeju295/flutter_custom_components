import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_custom_components/widgets/cc_video_player/cc_video_player_controller.dart';
import 'package:flutter_custom_components/widgets/cc_video_player/model/player_model.dart';
import 'package:flutter_custom_components/widgets/cc_video_player/model/quality.dart';
import 'package:flutter_custom_components/widgets/cc_video_player/utils/utils.dart';
import 'package:provider/provider.dart';

class PlayerControls extends StatefulWidget {
  const PlayerControls({super.key});

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls> {
  final textStyle = const TextStyle(color: Colors.white, fontSize: 12);
  late double _maxHeight;
  late double _maxWidth;
  Timer? _showControlsTimer;
  bool showControls = true;
  double bottomTextSize = 12;
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
          builder: (context, controller, child) {
            if (!showControls && controller.playerStatus.playing) return const Center();
            return Stack(
              children: [
                buildTopBar(controller),
                buildCenterStateWidget(controller),
                buildVolumeControls(controller),
                buildBrightnessControls(controller),
                buildBottomControls(controller),
              ],
            );
          },
        );
      }),
    );
  }

  buildControlsButton(IconData icon, {double iconSize = 20, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: () {
        _startTimer();
        onTap?.call();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(5.0),
        child: Icon(icon, size: iconSize, color: Colors.white),
      ),
    );
  }

  buildCenterStateWidget(CCVideoPlayerController controller) {
    Widget child = const SizedBox();
    switch (controller.dataStatus.status) {
      case DataStatus.none:
      case DataStatus.loading:
        child = const CircularProgressIndicator(strokeWidth: 3, color: Colors.red);
      case DataStatus.error:
        child = Text(controller.errorText, style: textStyle);
      case DataStatus.loaded:
        switch (controller.playerStatus.status) {
          case PlayerStatus.paused:
            child = buildControlsButton(Icons.play_circle, iconSize: 40, onTap: () => controller.play());
          case PlayerStatus.error:
            child = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error, size: 24, color: Colors.white),
                const SizedBox(height: 4),
                Text(controller.errorText, style: textStyle)
              ],
            );
          case PlayerStatus.completed:
            child = buildControlsButton(Icons.replay, iconSize: 30, onTap: () => controller.play());
          default:
            break;
        }
      default:
        break;
    }
    return Center(child: child);
  }

  buildTopBar(CCVideoPlayerController controller) {
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
            Expanded(
                child: Text(controller.errorText,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis)),
            // GestureDetector(
            //     onTap: () {},
            //     child: const Padding(
            //       padding: EdgeInsets.all(8.0),
            //       child: Icon(Icons.more_horiz, size: 18, color: Colors.white),
            //     )),
          ])),
    );
  }

  buildVolumeControls(CCVideoPlayerController _) {
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

  buildBrightnessControls(CCVideoPlayerController controller) {
    return Positioned(
        left: 0,
        bottom: 0,
        top: 0,
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            controller.setBrightness((-details.delta.dy / _maxHeight + controller.currentBrightness));
          },
          child: SizedBox(
            width: _maxWidth * 0.3,
            child: Center(child: Text('', style: textStyle)),
          ),
        ));
  }

  buildPlaybackSpeedPopupMenuButton(CCVideoPlayerController controller) {
    return PopupMenuButton<double>(
      initialValue: controller.playbackSpeed,
      tooltip: '播放速度',
      onSelected: (double speed) {
        controller.setPlaybackSpeed(speed);
      },
      shadowColor: Colors.transparent,
      color: Colors.black.withOpacity(.5),
      padding: EdgeInsets.zero,
      itemBuilder: (BuildContext context) {
        return <PopupMenuItem<double>>[
          for (final double speed in CCVideoPlayerUtils.examplePlaybackRates)
            PopupMenuItem<double>(
              height: 20,
              padding: EdgeInsets.zero,
              value: speed,
              child: Center(
                child: Text(
                  '${speed}x',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            )
        ];
      },
      child: Padding(
          padding: const EdgeInsets.all(4.0), child: Text('${controller.playbackSpeed.toString()}x', style: textStyle)),
    );
  }

  buildQualityPopupMenuButton(CCVideoPlayerController controller) {
    if (controller.qualities.isEmpty) return const SizedBox();
    return PopupMenuButton<Quality>(
      initialValue: controller.quality,
      tooltip: '清晰度选择',
      onSelected: (quality) {
        quality != controller.quality;
        controller.setQuality(quality);
      },
      shadowColor: Colors.transparent,
      color: Colors.black.withOpacity(.5),
      padding: EdgeInsets.zero,
      itemBuilder: (BuildContext context) {
        return <PopupMenuItem<Quality>>[
          ...controller.qualities.map((e) => PopupMenuItem<Quality>(
                height: 20,
                padding: EdgeInsets.zero,
                value: e,
                child: Center(
                  child: Text(
                    e.label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ))
        ];
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(controller.quality?.label ?? '', style: textStyle),
      ),
    );
  }

  buildBottomControls(CCVideoPlayerController controller) {
    return Positioned(
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
            buildControlsButton(controller.playerStatus.playing ? Icons.pause : Icons.play_arrow,
                iconSize: 22, onTap: () => controller.togglePlay()),
            Text(
              CCVideoPlayerUtils.printDuration(controller.duration, controller.sliderPosition),
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
                  value: controller.sliderPosition.inMilliseconds.toDouble(),
                  max: controller.duration.inMilliseconds.toDouble(),
                  onChanged: (double value) {
                    controller.seekTo(Duration(milliseconds: value.toInt()));
                  },
                ),
              ),
            )),
            Text(
              CCVideoPlayerUtils.printDuration(controller.duration, controller.duration),
              style: textStyle,
            ),
            buildQualityPopupMenuButton(controller),
            buildPlaybackSpeedPopupMenuButton(controller),
            buildControlsButton(controller.mute ? Icons.volume_off_outlined : Icons.volume_up_outlined,
                onTap: () => controller.setMute(!controller.mute)),
            buildControlsButton(!controller.fullscreen ? Icons.fullscreen : Icons.fullscreen_exit, onTap: () {
              if (controller.fullscreen) {
                Navigator.maybePop(context);
              } else {
                controller.setVideoFullScreen(context);
              }
            })
          ],
        ),
      ),
    );
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
