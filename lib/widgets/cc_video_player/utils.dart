//格式化时间
import 'package:video_player/video_player.dart';

String printDuration(Duration maxDuration, Duration? duration) {
  if (maxDuration.inMinutes >= 60) {
    if (duration == null) return "--:--:--";
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitHours = twoDigits(duration.inHours);
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds";
  }
  if (duration == null) return "--:--";
  String twoDigits(int n) => n.toString().padLeft(2, "0");

  String twoDigitMinutes = twoDigits(duration.inMinutes).replaceAll("-", "");
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60)).replaceAll("-", "");
  return "$twoDigitMinutes:$twoDigitSeconds";
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
