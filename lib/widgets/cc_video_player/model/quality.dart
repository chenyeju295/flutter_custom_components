import 'dart:io';

class Quality {
  String url, label;
  Map<String, String>? httpHeaders;
  bool isFile = false;
  File? file;
  Quality({this.url = "", this.label = "", this.httpHeaders, this.isFile = false, this.file});
  int quality() {
    if (label.contains("x")) {
      return int.parse(label.split("x")[0]);
    }
    return int.parse(label.replaceAll(RegExp('[^0-9]'), ''));
  }

  int compareTo(Quality other) {
    int epDifference = 0;
    try {
      epDifference = quality().compareTo(other.quality());
    } catch (_) {}
    return epDifference;
  }
}
