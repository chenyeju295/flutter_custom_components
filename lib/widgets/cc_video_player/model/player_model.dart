import 'package:video_player/video_player.dart';

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
