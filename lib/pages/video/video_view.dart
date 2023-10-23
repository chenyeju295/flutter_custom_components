import 'package:flutter/material.dart';
import 'package:flutter_custom_components/widgets/cc_video_player/cc_video_player.dart';
import 'package:flutter_custom_components/widgets/cc_video_player/cc_video_player_controller.dart';
import 'package:flutter_custom_components/widgets/cc_video_player/model/player_model.dart';
import 'package:video_player/video_player.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  List<CCVideoPlayerController> videoControllerList = [
    CCVideoPlayerController(),
    CCVideoPlayerController(),
    CCVideoPlayerController(),
  ];

  @override
  void initState() {
    super.initState();
    videoControllerList[0].initializeVideo(
      DataSource(type: DataSourceType.network, source: 'http://www.w3school.com.cn/example/html5/mov_bbb.mp4'),
      autoplay: true,
    );
    videoControllerList[1].initializeVideo(
      DataSource(
          type: DataSourceType.network, source: 'http://vfx.mtime.cn/Video/2021/07/10/mp4/210710122716702150.mp4'),
    );
    videoControllerList[2].initializeVideo(
      DataSource(type: DataSourceType.network, source: 'https://content.jwplatform.com/manifests/vM7nH0Kl.m3u8'),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildPage(context);
  }

  Widget _buildPage(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [const SizedBox(height: 120), ...videoControllerList.map((e) => CCVideoPlayer(controller: e))],
          ),
        ),
      ),
    );
  }
}
