import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:flutter/widgets.dart';

class CCVideoPlayerController {
  VideoPlayerController? _videoPlayerController;

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
    playerStatus.status = value.isPlaying ? PlayerStatus.playing : PlayerStatus.stopped;
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
