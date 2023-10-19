import 'dart:io';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_components/widgets/cc_video_player/model/player_model.dart';
import 'package:flutter_custom_components/widgets/cc_video_player/widgets/fullscreen_page.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:video_player/video_player.dart';

import 'package:flutter/widgets.dart';
import 'package:volume_controller/volume_controller.dart';

class CCVideoPlayerController extends ChangeNotifier {
  VideoPlayerController? _videoPlayerController;
  Duration _position = Duration.zero;
  Duration _sliderPosition = Duration.zero;
  Duration _duration = Duration.zero;
  bool _autoPlay = false;
  bool _looping = false;
  bool _mute = false;
  bool _fullscreen = false;
  double _volumeBeforeMute = 0;
  double _playbackSpeed = 1.0;
  double _currentVolume = 1.0;
  double _currentBrightness = 1.0;

  Duration get position => _position;

  Duration get sliderPosition => _sliderPosition;

  Duration get duration => _duration;

  bool get mute => _mute;

  bool get fullscreen => _fullscreen;

  double get currentBrightness => _currentBrightness;

  double get playbackSpeed => _playbackSpeed;

  bool get looping => _looping;

  bool get autoplay => _autoPlay;

  double get currentVolume => _currentVolume;

  VideoPlayerController? get videoPlayerController => _videoPlayerController;

  final VideoPlayerStatus playerStatus = VideoPlayerStatus();
  final PlayerDataStatus dataStatus = PlayerDataStatus();

  ///设置视频源
  Future<void> setDataSource(
    DataSource dataSource, {
    bool autoplay = false,
    bool looping = false,
    Duration seekTo = Duration.zero,
  }) async {
    try {
      _autoPlay = autoplay;
      _looping = looping;
      dataStatus.status = DataStatus.loading;
      if (_videoPlayerController != null && _videoPlayerController!.value.isPlaying) {
        await pause();
      }
      VideoPlayerController? oldController = _videoPlayerController;
      if (oldController != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          oldController.removeListener(_listener);
          await oldController.dispose();
        });
      }

      _videoPlayerController = _createVideoController(dataSource);
      await _videoPlayerController!.initialize();
      _duration = _videoPlayerController!.value.duration;
      dataStatus.status = DataStatus.loaded;
      await _initializePlayer(seekTo: seekTo);
      _videoPlayerController!.addListener(_listener);
    } catch (e) {
      dataStatus.status = DataStatus.error;
      debugPrint(e.toString());
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
        httpHeaders: dataSource.httpHeaders ?? {},
      );
    } else {
      tmp = VideoPlayerController.file(
        dataSource.file!,
        httpHeaders: dataSource.httpHeaders ?? {},
      );
    }
    return tmp;
  }

  void _listener() {
    if (_videoPlayerController == null || !_videoPlayerController!.value.isInitialized) {
      return;
    }
    final value = _videoPlayerController!.value;
    playerStatus.status = value.isPlaying ? PlayerStatus.playing : PlayerStatus.paused;
    _duration = value.duration;
    _position = value.position;
    _sliderPosition = value.position;
    final volume = value.volume;
    if (!mute && _volumeBeforeMute != volume) {
      _volumeBeforeMute = volume;
    }
    if ((_position.inSeconds >= _duration.inSeconds) && !playerStatus.completed) {
      playerStatus.status = PlayerStatus.completed;
    }
    notifyListeners();
  }

  Future _initializePlayer({
    Duration seekTo = Duration.zero,
  }) async {
    if (seekTo != Duration.zero) {
      await this.seekTo(seekTo);
    }

    if (_playbackSpeed != 1.0) {
      await setPlaybackSpeed(_playbackSpeed);
    }

    if (_looping) {
      await setLooping(_looping);
    }

    if (_autoPlay) {
      await play();
    }
  }

  Future<void> disposePlayer() async {
    _videoPlayerController?.removeListener(_listener);
    await _videoPlayerController?.dispose();
    _videoPlayerController = null;
  }

  Future<void> setMute(bool enabled) async {
    if (enabled) {
      _volumeBeforeMute = _videoPlayerController!.value.volume;
    }
    _mute = enabled;
    await setVolume(enabled ? 0 : _volumeBeforeMute, videoPlayerVolume: true);
  }

  Future<void> setVolume(double volumeNew, {bool videoPlayerVolume = false}) async {
    if (volumeNew >= 0.0 && volumeNew <= 1.0) {
      _currentVolume = volumeNew;

      try {
        VolumeController().setVolume(volumeNew, showSystemUI: false);
      } catch (_) {
        debugPrint(_.toString());
      }
    }

    //
  }

  Future<void> setPlaybackSpeed(double speed) async {
    await _videoPlayerController?.setPlaybackSpeed(speed);
    _playbackSpeed = speed;
  }

  Future<void> setLooping(bool looping) async {
    await _videoPlayerController?.setLooping(looping);
    _looping = looping;
  }

  Future<void> play({bool repeat = false, bool hideControls = true}) async {
    if (repeat) {
      await seekTo(Duration.zero);
    }
    await _videoPlayerController?.play();
    await getCurrentVolume();
    await getCurrentBrightness();
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
    if (seekPosition >= _duration) {
      seekPosition = _duration - const Duration(milliseconds: 100);
    }
    if (seekPosition < Duration.zero) {
      seekPosition = Duration.zero;
    }
    _position = seekPosition;
    if (_duration.inSeconds != 0) {
      await _videoPlayerController?.seekTo(seekPosition);
    }
  }

  Future<void> setVideoAsAppFullScreen(BuildContext context,
      {bool applyOverlaysAndOrientations = true, bool disposePlayer = false}) async {
    final route = PageRouteBuilder(
      opaque: false,
      fullscreenDialog: true,
      pageBuilder: (_, __, ___) {
        return CCVideoPlayerFullscreenPage(
          controller: this,
          disposePlayer: disposePlayer,
        );
      },
    );
    setFullScreenOrNot(true);
    await Navigator.of(context).push(route);
  }

  Future<void> setBrightness(double brightness) async {
    try {
      _currentBrightness = brightness;
      ScreenBrightness().setScreenBrightness(brightness);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getCurrentBrightness() async {
    try {
      _currentBrightness = await ScreenBrightness().current;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getCurrentVolume() async {
    try {
      _currentVolume = await VolumeController().getVolume();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> videoPlayerClosed() async {
    _position = Duration.zero;
    _videoPlayerController?.removeListener(_listener);
    await _videoPlayerController?.dispose();
    _videoPlayerController = null;
  }

  Future<void> setFullScreenOrNot(bool full) async {
    if (full) {
      AutoOrientation.landscapeAutoMode();
      if (Platform.isAndroid) {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
      }
    } else {
      AutoOrientation.portraitAutoMode();
      if (Platform.isAndroid) {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
            overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
      }
    }
    _fullscreen = full;
    notifyListeners();
  }

  Future<void> onFullscreenClose() async {
    try {
      await ScreenBrightness().resetScreenBrightness();
    } catch (e) {
      debugPrint(e.toString());
    }
    setFullScreenOrNot(false);
  }
}
