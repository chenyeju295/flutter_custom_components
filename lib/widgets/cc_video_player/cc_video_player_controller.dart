import 'package:flutter/material.dart';
import 'package:flutter_custom_components/widgets/cc_video_player/model/player_model.dart';
import 'package:video_player/video_player.dart';

import 'package:flutter/widgets.dart';

class CCVideoPlayerController extends ChangeNotifier {
  VideoPlayerController? _videoPlayerController;

  Duration position = Duration.zero;
  Duration sliderPosition = Duration.zero;
  Duration duration = Duration.zero;
  final bool _mute = false;
  double _volumeBeforeMute = 0;

  bool get mute => _mute;
  VideoPlayerController? get videoPlayerController => _videoPlayerController;

  final VideoPlayerStatus playerStatus = VideoPlayerStatus();
  final PlayerDataStatus dataStatus = PlayerDataStatus();

  ///设置视频源
  Future<void> setDataSource(
    DataSource dataSource, {
    bool autoplay = true,
    bool looping = false,
    Duration seekTo = Duration.zero,
  }) async {
    try {
      dataStatus.status = DataStatus.loading;
      if (_videoPlayerController != null && _videoPlayerController!.value.isPlaying) {
        await pause(notify: false);
      }
      VideoPlayerController? oldController = _videoPlayerController;
      _videoPlayerController = _createVideoController(dataSource);
      await _videoPlayerController!.initialize();
      if (oldController != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          oldController.removeListener(_listener);
          await oldController.dispose();
        });
      }
      dataStatus.status = DataStatus.loaded;
      _videoPlayerController!.addListener(_listener);
    } catch (e) {
      dataStatus.status = DataStatus.error;
    }
    notifyListeners();
  }

  VideoPlayerController _createVideoController(DataSource dataSource) {
    VideoPlayerController tmp;
    if (dataSource.type == DataSourceType.asset) {
      tmp = VideoPlayerController.asset(
        dataSource.source!,
        package: dataSource.package,
      );
    } else if (dataSource.type == DataSourceType.network) {
      tmp = VideoPlayerController.networkUrl(
        Uri.parse(dataSource.source!),
      );
    } else {
      tmp = VideoPlayerController.networkUrl(
        Uri.parse(dataSource.source!),
      );
    }
    return tmp;
  }

  void _listener() {
    final value = _videoPlayerController!.value;
    playerStatus.status = value.isPlaying ? PlayerStatus.playing : PlayerStatus.paused;
    duration = value.duration;
    position = value.position;
    sliderPosition = position;
    final volume = value.volume;
    if (!mute && _volumeBeforeMute != volume) {
      _volumeBeforeMute = volume;
    }
    if ((position.inSeconds >= duration.inSeconds) && !playerStatus.completed) {
      playerStatus.status = PlayerStatus.completed;
    }
    notifyListeners();
  }

  Future<void> play({bool repeat = false, bool hideControls = true}) async {
    await _videoPlayerController?.play();
  }

  Future<void> pause({bool notify = true}) async {
    await _videoPlayerController?.pause();
  }

  Future<void> togglePlay() async {
    if (playerStatus.playing) {
      pause();
    } else {
      play();
    }
  }

  Future<void> seekTo(Duration seekPosition) async {
    if (seekPosition >= duration) {
      seekPosition = duration - const Duration(milliseconds: 100);
    }
    if (seekPosition < Duration.zero) {
      seekPosition = Duration.zero;
    }
    position = seekPosition;
    if (duration.inSeconds != 0) {
      await _videoPlayerController?.seekTo(seekPosition);
    }
  }
}
