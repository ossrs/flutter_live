
import 'dart:async';

import 'package:flutter/services.dart';

class FlutterLive {
  static const MethodChannel _channel =
      const MethodChannel('flutter_live');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  // Demo streams by https://ossrs.net/
  static const String rtmp = 'rtmp://r.ossrs.net/live/livestream';
  static const String hls = 'http://r.ossrs.net/live/livestream.m3u8';
  static const String flv = 'http://r.ossrs.net:8080/live/livestream.flv';
}
