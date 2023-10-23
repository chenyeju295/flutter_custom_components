import 'package:flutter/material.dart';
import 'package:flutter_custom_components/pages/video/video_view.dart';
import 'package:provider/provider.dart';

import 'provider.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (BuildContext context) => MainProvider(), builder: (context, child) => _buildPage(context));
  }

  Widget _buildPage(BuildContext context) {
    // final provider = context.read<MainProvider>();
    return Scaffold(
        appBar: AppBar(centerTitle: true, title: const Text('Flutter Custom Components')),
        backgroundColor: Colors.white,
        body: Align(
          alignment: Alignment.topCenter,
          child: Wrap(spacing: 10, runSpacing: 10, children: [
            _buildTextButton('CCVideoPlayer', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const VideoPage(),
                ),
              );
            }),
            _buildTextButton('CCVideoPlayer', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const VideoPage(),
                ),
              );
            }),
          ]),
        ));
  }

  ///文字按钮
  Widget _buildTextButton(String text, onPressed) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.blue)),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
