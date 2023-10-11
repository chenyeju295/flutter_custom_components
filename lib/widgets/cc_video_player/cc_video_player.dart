import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cc_video_player_controller.dart';

class CCVideoPlayer extends StatelessWidget {
  final CCVideoPlayerController controller;

  const CCVideoPlayer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => CCVideoPlayerController(),
      builder: (context, child) => _buildPage(context),
    );
  }

  Widget _buildPage(BuildContext context) {
    final provider = context.read<CCVideoPlayerController>();

    return Container();
  }
}
