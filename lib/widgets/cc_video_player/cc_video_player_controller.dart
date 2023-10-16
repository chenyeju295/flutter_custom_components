import 'package:flutter/material.dart';
import 'package:flutter_custom_components/widgets/cc_video_player/cc_video_player.dart';
import 'package:video_player/video_player.dart';

import 'package:flutter/widgets.dart';

class CCVideoPlayerController {
  VideoPlayerController? _videoPlayerController;

  Duration _position = Duration.zero;
  Duration _sliderPosition = Duration.zero;
  Duration _duration = Duration.zero;
  final bool _mute = false;
  double _volumeBeforeMute = 0;

  Duration get position => _position;
  Duration get sliderPosition => _sliderPosition;
  Duration get duration => _duration;
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
    _duration = value.duration;
    final position = value.position;
    _position = position;
    _sliderPosition = position;
    final volume = value.volume;
    if (!mute && _volumeBeforeMute != volume) {
      _volumeBeforeMute = volume;
    }
    if ((_position.inSeconds >= duration.inSeconds) && !playerStatus.completed) {
      playerStatus.status = PlayerStatus.completed;
    }
  }

  Future<void> play({bool repeat = false, bool hideControls = true}) async {
    await _videoPlayerController?.play();
    playerStatus.status = PlayerStatus.playing;
  }

  Future<void> pause({bool notify = true}) async {
    await _videoPlayerController?.pause();
    playerStatus.status = PlayerStatus.paused;
  }

  Future<void> togglePlay() async {
    if (_videoPlayerController!.value.isPlaying) {
      pause();
    } else {
      play();
    }
  }

  Future<void> seekTo(Duration position) async {
    if (position >= duration) {
      position = duration - const Duration(milliseconds: 100);
    }
    if (position < Duration.zero) {
      position = Duration.zero;
    }
    _position = position;
    if (duration.inSeconds != 0) {
      await _videoPlayerController?.seekTo(position);
    }
  }

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

  static CCVideoPlayerController of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CCVideoPlayerProvider>()!.controller;
  }
}

class DataSource {
  DataSourceType type;
  String? source, package;
  DataSource({
    this.source,
    required this.type,
    this.package,
  }) : assert((type == DataSourceType.file) || source != null);
}

enum DataStatus { none, loading, loaded, error }

class PlayerDataStatus {
  DataStatus status = (DataStatus.none);

  bool get none => status == DataStatus.none;
  bool get loading => status == DataStatus.loading;
  bool get loaded => status == DataStatus.loaded;
  bool get error => status == DataStatus.error;
}

enum PlayerStatus { stopped, completed, playing, paused }

class VideoPlayerStatus {
  PlayerStatus status = PlayerStatus.stopped;

  bool get stopped {
    return status == PlayerStatus.stopped;
  }

  bool get playing {
    return status == PlayerStatus.playing;
  }

  bool get paused {
    return status == PlayerStatus.paused;
  }

  bool get completed {
    return status == PlayerStatus.completed;
  }
}
