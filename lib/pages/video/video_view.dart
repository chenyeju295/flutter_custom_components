import 'package:flutter/material.dart';
import 'package:flutter_custom_components/widgets/cc_video_player/cc_video_player.dart';
import 'package:provider/provider.dart';

import 'video_provider.dart';

class VideoPage extends StatelessWidget {
  const VideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => VideoProvider(),
      builder: (context, child) => _buildPage(context),
    );
  }

  Widget _buildPage(BuildContext context) {
    final provider = context.read<VideoProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(
              width: 375,
              height: 375 * (9 / 16),
              child: CCVideoPlayer(
                controller: provider.controller,
              ))
        ],
      ),
    );
  }
}
