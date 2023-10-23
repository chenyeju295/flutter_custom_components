class CCVideoPlayerUtils {
  static const List<double> examplePlaybackRates = <double>[
    0.5,
    1.0,
    2.0,
    3.0,
  ];
  static String printDuration(Duration maxDuration, Duration? duration) {
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
}
