import 'dart:async';

import 'package:flutter/services.dart';

/// The live streaming tools for flutter.
class FlutterLive {
  /// The channel for platform.
  static const MethodChannel _channel = const MethodChannel('flutter_live');

  /// Get the platform information.
  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// RTMP demo stream by https://ossrs.net/
  static const String rtmp = 'rtmp://r.ossrs.net/live/livestream';

  /// HLS demo stream by https://ossrs.net/
  static const String hls = 'http://r.ossrs.net/live/livestream.m3u8';

  /// HTTP-FLV demo stream by https://ossrs.net/
  static const String flv = 'http://r.ossrs.net/live/livestream.flv';

  /// HTTPS-FLV demo stream by https://ossrs.net/
  static const String flvs = 'https://d.ossrs.net:18088/live/livestream.flv';

  /// HTTPS-HLS demo stream by https://ossrs.net/
  static const String hlss = 'https://d.ossrs.net:18088/live/livestream.m3u8';

  /// The constructor for flutter live.
  FlutterLive() {
  }
}

