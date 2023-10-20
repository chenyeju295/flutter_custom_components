import 'dart:io';

import 'package:flutter_custom_components/widgets/cc_video_player/model/quality.dart';
import 'package:path/path.dart' as path;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart' as dio;

class M3u8Utils {
  static Future<List<Quality>> getStreamUrls(String url) async {
    List<Quality> qualities = [];
    String type;
    Uri parsedLink = Uri.parse(url);
    String path = parsedLink.path;
    String filename = basename(path);
    if (filename.substring(filename.lastIndexOf(".")).contains("?")) {
      type = filename.substring(filename.lastIndexOf("."), filename.substring(filename.lastIndexOf(".")).indexOf("?"));
    } else {
      type = filename.substring(filename.lastIndexOf("."));
    }
    if (type == ".m3u8") {
      qualities = await fromM3u8PlaylistUrl(url);
      qualities.sort((b, a) => a.compareTo(b));
    } else {
      qualities.clear();
      qualities.add(Quality(url: url));
    }
    return qualities;
  }

  static Future<String> getConvertFilesNameToLinks({String link = "", String content = "", bool video = true}) async {
    final RegExp regExpListOfLinks = RegExp("#EXTINF:.+?\n+(.+)", multiLine: true, caseSensitive: false);

    final RegExp netRegUrl = RegExp(r'^(http|https)://([\w.]+/?)\S*');

    Map<String, List<String?>> downloadLinks = {};
    List<RegExpMatch> listOfLinks = regExpListOfLinks.allMatches(content).toList();
    String baseUrl = link;
    String mappingKey = video ? "video" : "audio";
    content = content.replaceAllMapped(regExpListOfLinks, (e) {
      final bool isNetwork = netRegUrl.hasMatch(e.group(1) ?? "");
      if (isNetwork) {
        return e.group(1)!;
      } else {
        return "${baseUrl.substring(0, baseUrl.lastIndexOf('/'))}/${e.group(1) ?? ""}";
      }
    });
    downloadLinks[mappingKey] = listOfLinks.map((e) {}).toList();
    return content;
  }

  static Future<List<Quality>> fromM3u8PlaylistUrl(
    String m3u8, {
    String initialSubtitle = "",
    String Function(String quality)? formatter,
    bool descending = true,
    Map<String, String>? httpHeaders,
  }) async {
    final RegExp netRegUrl = RegExp(r'^(http|https)://([\w.]+/?)\S*');
    final RegExp netReg2 = RegExp(r'(.*)\r?/');
    final RegExp regExpPlaylist = RegExp(
      r"#EXT-X-STREAM-INF:(?:.*,RESOLUTION=(\d+x\d+))?,?(.*)\r?\n(.*)",
      caseSensitive: false,
      multiLine: true,
    );
    final RegExp regExpAudio = RegExp(
      r"""^#EXT-X-MEDIA:TYPE=AUDIO(?:.*,URI="(.*m3u8[^"]*)")""",
      caseSensitive: false,
      multiLine: true,
    );
    late String content = "";
    final dio.Response response = await dio.Dio().get(
      m3u8,
      options: dio.Options(
        headers: httpHeaders,
        followRedirects: true,
        receiveDataWhenStatusError: true,
      ),
    );
    if (response.statusCode == 200) {
      content = response.data;
    }
    final String? directoryPath;

    directoryPath = (await getTemporaryDirectory()).path;
    List<RegExpMatch> playlistMatches = regExpPlaylist.allMatches(content).toList();
    List<RegExpMatch> audioMatches = regExpAudio.allMatches(content).toList();
    Map<String, dynamic> sources = {};
    Map<String, String> sourceUrls = {};
    final List<String> audioUrls = [];
    if (playlistMatches.isEmpty) {}
    for (int i = 0; i < playlistMatches.length; i++) {
      RegExpMatch playlistMatch = playlistMatches[i];
      final RegExpMatch? playlist = netReg2.firstMatch(m3u8);
      final String sourceURL = (playlistMatch.group(3)).toString();
      final String quality = (playlistMatch.group(1)).toString();
      final bool isNetwork = netRegUrl.hasMatch(sourceURL);
      String playlistUrl = sourceURL;

      if (!isNetwork) {
        final String? dataURL = playlist!.group(0);
        playlistUrl = "$dataURL$sourceURL";
      }
      for (final RegExpMatch audioMatch in audioMatches) {
        final String audio = (audioMatch.group(1)).toString();
        final bool isNetwork = netRegUrl.hasMatch(audio);
        final RegExpMatch? match = netReg2.firstMatch(playlistUrl);
        String audioUrl = audio;

        if (!isNetwork && match != null) {
          audioUrl = "${match.group(0)}$audio";
        }
        audioUrls.add(audioUrl);
      }

      final String audioMetadata;
      if (audioUrls.isNotEmpty) {
        if (i < audioUrls.length) {
          audioMetadata =
              """#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio-medium",NAME="audio-medium",AUTOSELECT=YES,DEFAULT=YES,CHANNELS="2",URI="${audioUrls[i]}"\n""";
        } else {
          audioMetadata =
              """#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio-medium",NAME="audio-medium",AUTOSELECT=YES,DEFAULT=YES,CHANNELS="2",URI="${audioUrls.last}"\n""";
        }
      } else {
        audioMetadata = "";
      }
      final File file = File(path.join(directoryPath, 'hls$quality.m3u8'));
      file.writeAsStringSync(
        """#EXTM3U\n#EXT-X-VERSION:3\n#EXT-X-INDEPENDENT-SEGMENTS\n$audioMetadata#EXT-X-STREAM-INF:CLOSED-CAPTIONS=NONE,BANDWIDTH=1469712,RESOLUTION=$quality,AUDIO="audio-medium",GROUP-ID="audio-medium",FRAME-RATE=30.000\n$playlistUrl""",
      );
      sources[quality] = file;
    }
    List<Quality> qualities = [];
    for (String key in sources.keys) {
      qualities.add(Quality(
        label: key,
        file: sources[key]!,
        isFile: true,
        httpHeaders: httpHeaders,
      ));
    }
    for (String key in sourceUrls.keys) {
      qualities.add(Quality(
        label: key,
        url: sourceUrls[key]!,
        isFile: false,
        httpHeaders: httpHeaders,
      ));
    }
    qualities.add(Quality(
      label: "Auto",
      url: m3u8,
      httpHeaders: httpHeaders,
    ));
    return qualities;
  }
}
