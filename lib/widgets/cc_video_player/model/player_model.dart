import 'dart:io';

import 'package:video_player/video_player.dart';

class DataSource {
  DataSourceType type;
  String? source, package;
  File? file;
  Map<String, String>? httpHeaders;

  DataSource({
    this.source,
    required this.type,
    this.file,
    this.package,
    this.httpHeaders,
  }) : assert((type == DataSourceType.file && file != null) || source != null);

  DataSource copyWith({
    File? file,
    String? source,
    String? package,
    DataSourceType? type,
    Map<String, String>? httpHeaders,
  }) {
    return DataSource(
      file: file ?? this.file,
      source: source ?? this.source,
      type: type ?? this.type,
      package: package ?? this.package,
      httpHeaders: httpHeaders ?? this.httpHeaders,
    );
  }
}

enum DataStatus { none, loading, loaded, error }

class PlayerDataStatus {
  DataStatus status = DataStatus.none;

  bool get none => status == DataStatus.none;
  bool get loading => status == DataStatus.loading;
  bool get loaded => status == DataStatus.loaded;
  bool get error => status == DataStatus.error;
}

enum PlayerStatus { completed, playing, paused, error }

class VideoPlayerStatus {
  PlayerStatus status = PlayerStatus.paused;

  bool get playing => status == PlayerStatus.playing;
  bool get paused => status == PlayerStatus.paused;
  bool get completed => status == PlayerStatus.completed;
  bool get error => status == PlayerStatus.error;
}
