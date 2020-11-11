import 'dart:async';

import 'package:flutter/services.dart';
import 'package:fijkplayer/fijkplayer.dart';

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

  /// WebRTC demo stream by https://ossrs.net/
  static const String rtc = 'webrtc://d.ossrs.net:11985/live/livestream';

  /// The constructor for flutter live.
  FlutterLive() {
  }
}

/// A realtime player, use FijkPlayer.
class RealtimePlayer {
  /// The under-layer fijkplayer.
  final FijkPlayer _player;

  /// Create a realtime player with fijkplayer.
  RealtimePlayer(this._player);

  /// Get the under-layer fijkplayer.
  FijkPlayer get fijk => _player;

  /// Initialize the player.
  void initState() {
    _player.enterFullScreen();
  }

  /// Start play a url.
  /// [url] must a path for FijkPlayer.setDataSource
  ///
  /// It can be a RTMP live streaming, like FlutterLive.rtmp or hls like FlutterLive.hls,
  /// or flv like FlutterLive.flv.
  ///
  /// For security live streaming over HTTPS, like FlutterLive.flvs for HTTPS-FLV, or
  /// hls over HTTPS FlutterLive.hlss.
  ///
  /// Note that we support all urls which FFmpeg supports.
  Future<void> play(String url) async {
    print('Start play live streaming ${url}');

    await _player.setOption(FijkOption.playerCategory, "mediacodec-all-videos", 1);
    await _player.setOption(FijkOption.hostCategory, "request-screen-on", 1);
    await _player.setOption(FijkOption.hostCategory, "request-audio-focus", 1);

    // Live low-latency: https://www.jianshu.com/p/d6a5d8756eec
    // For all options, read https://github.com/Bilibili/ijkplayer/blob/master/ijkmedia/ijkplayer/ff_ffplay_options.h
    await _player.setOption(FijkOption.formatCategory, "probesize", 16 * 1024); // in bytes
    await _player.setOption(FijkOption.formatCategory, "analyzeduration", 100 * 1000); // in us
    await _player.setOption(FijkOption.playerCategory, "packet-buffering", 0); // 0, no buffer.
    await _player.setOption(FijkOption.playerCategory, "max_cached_duration", 800); // in ms
    await _player.setOption(FijkOption.playerCategory, "max-buffer-size", 32 * 1024); // in bytes
    await _player.setOption(FijkOption.playerCategory, "infbuf", 1); // 1 for realtime.
    await _player.setOption(FijkOption.playerCategory, "min-frames", 1); // in frames

    await _player.setDataSource(url, autoPlay: true).catchError((e) {
      print("setDataSource error: $e");
    });
  }

  /// Dispose the player.
  void dispose() {
    _player.release();
  }
}

