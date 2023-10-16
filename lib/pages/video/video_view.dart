import 'package:flutter/material.dart';
import 'package:flutter_custom_components/widgets/cc_video_player/cc_video_player.dart';
import 'package:flutter_custom_components/widgets/cc_video_player/cc_video_player_controller.dart';
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
    CCVideoPlayerController(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      videoControllerList[0].setDataSource(
        DataSource(type: DataSourceType.network, source: 'http://www.w3school.com.cn/example/html5/mov_bbb.mp4'),
      );
      videoControllerList[1].setDataSource(
        DataSource(
            type: DataSourceType.network, source: 'http://vfx.mtime.cn/Video/2021/07/10/mp4/210710122716702150.mp4'),
      );
      videoControllerList[2].setDataSource(
        DataSource(
            type: DataSourceType.network, source: 'http://vfx.mtime.cn/Video/2021/07/10/mp4/210710094507540173.mp4'),
      );
      videoControllerList[3].setDataSource(
        DataSource(
            type: DataSourceType.network, source: 'http://vfx.mtime.cn/Video/2021/07/10/mp4/210710171112971120.mp4'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildPage(context);
  }

  Widget _buildPage(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              CCVideoPlayer(
                controller: videoControllerList[0],
              ),
              // CCVideoPlayer(
              //   controller: videoControllerList[1],
              // ),
              // CCVideoPlayer(
              //   controller: videoControllerList[2],
              // ),
              // CCVideoPlayer(
              //   controller: videoControllerList[3],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
