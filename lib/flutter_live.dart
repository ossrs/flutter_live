import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:fijkplayer/fijkplayer.dart' as fijkplayer;
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;

/// The live streaming tools for flutter.
class FlutterLive {
  /// The channel for platform.
  static const MethodChannel _channel = const MethodChannel('flutter_live');

  /// Get the platform information.
  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// Set the speaker phone on.
  // [enabled] Use Earpiece if false, or Loudspeaker if true.
  static Future<void> setSpeakerphoneOn(bool enabled) async {
    await _channel.invokeMethod('setSpeakerphoneOn', <String, dynamic>{'enabled': enabled});
  }

  /// RTMP demo stream by https://ossrs.net/
  static const String rtmp = 'rtmp://r.ossrs.net/live/livestream';

  /// HLS demo stream by https://ossrs.net/
  static const String hls = 'http://r.ossrs.net/live/livestream.m3u8';

  /// HTTP-FLV demo stream by https://ossrs.net/
  static const String flv = 'http://r.ossrs.net/live/livestream.flv';

  /// HTTPS-FLV demo stream by https://ossrs.net/
  static const String flvs = 'https://d.ossrs.net/live/livestream.flv';

  /// HTTPS-HLS demo stream by https://ossrs.net/
  static const String hlss = 'https://d.ossrs.net/live/livestream.m3u8';

  /// WebRTC demo stream by https://ossrs.net/
  static const String rtc = 'webrtc://d.ossrs.net/live/livestream';

  // Publish demo stream by https://ossrs.net/
  static const String rtmp_publish = 'rtmp://r.ossrs.net/live/show';
  static const String rtmp_publish2 = 'rtmp://d.ossrs.net/live/show';

  /// The constructor for flutter live.
  FlutterLive();
}

/// A realtime player, using [fijkplayer](https://pub.dev/packages/fijkplayer).
class RealtimePlayer {
  /// The under-layer fijkplayer.
  final fijkplayer.FijkPlayer _player;

  /// Create a realtime player with [fijkplayer](https://pub.dev/packages/fijkplayer).
  RealtimePlayer(this._player);

  /// Get the under-layer [fijkplayer](https://pub.dev/packages/fijkplayer).
  fijkplayer.FijkPlayer get fijk => _player;

  /// Initialize the player.
  void initState() {
    _player.enterFullScreen();
  }

  /// Start play a url.
  /// [url] must a path for [FijkPlayer.setDataSource](https://pub.dev/documentation/fijkplayer/latest/fijkplayer/FijkPlayer/setDataSource.html
  ///
  /// It can be a RTMP live streaming, like [FlutterLive.rtmp] or hls like [FlutterLive.hls],
  /// or flv like [FlutterLive.flv].
  ///
  /// For security live streaming over HTTPS, like [FlutterLive.flvs] for HTTPS-FLV, or
  /// hls over HTTPS [FlutterLive.hlss].
  ///
  /// Note that we support all urls which FFmpeg supports.
  Future<void> play(String url) async {
    print('Start play live streaming $url');

    await _player.setOption(fijkplayer.FijkOption.playerCategory, "mediacodec-all-videos", 1);
    await _player.setOption(fijkplayer.FijkOption.hostCategory, "request-screen-on", 1);
    await _player.setOption(fijkplayer.FijkOption.hostCategory, "request-audio-focus", 1);

    // Live low-latency: https://www.jianshu.com/p/d6a5d8756eec
    // For all options, read https://github.com/Bilibili/ijkplayer/blob/master/ijkmedia/ijkplayer/ff_ffplay_options.h
    await _player.setOption(fijkplayer.FijkOption.formatCategory, "probesize", 16 * 1024); // in bytes
    await _player.setOption(fijkplayer.FijkOption.formatCategory, "analyzeduration", 100 * 1000); // in us
    await _player.setOption(fijkplayer.FijkOption.playerCategory, "packet-buffering", 0); // 0, no buffer.
    await _player.setOption(fijkplayer.FijkOption.playerCategory, "max_cached_duration", 800); // in ms
    await _player.setOption(fijkplayer.FijkOption.playerCategory, "max-buffer-size", 32 * 1024); // in bytes
    await _player.setOption(fijkplayer.FijkOption.playerCategory, "infbuf", 1); // 1 for realtime.
    await _player.setOption(fijkplayer.FijkOption.playerCategory, "min-frames", 1); // in frames

    await _player.setDataSource(url, autoPlay: true).catchError((e) {
      print("setDataSource error: $e");
    });
  }

  /// Dispose the player.
  void dispose() {
    _player.release();
  }
}

/// The uri for webrtc, for example, [FlutterLive.rtc]:
///   webrtc://d.ossrs.net:11985/live/livestream
/// is parsed as a WebRTCUri:
///   api: http://d.ossrs.net:11985/rtc/v1/play/
///   streamUrl: "webrtc://d.ossrs.net:11985/live/livestream"
class WebRTCUri {
  /// The api server url for WebRTC streaming.
  String api;
  /// The stream url to play or publish.
  String streamUrl;

  /// Parse the url to WebRTC uri.
  static WebRTCUri parse(String url) {
    Uri uri = Uri.parse(url);

    var schema = 'https'; // For native, default to HTTPS
    if (uri.queryParameters.containsKey('schema')) {
      schema = uri.queryParameters['schema'];
    } else {
      schema = 'https';
    }

    var port = (uri.port > 0)? uri.port : 443;
    if (schema == 'https') {
      port = (uri.port > 0)? uri.port : 443;
    } else if (schema == 'http') {
      port = (uri.port > 0)? uri.port : 1985;
    }

    var api = '/rtc/v1/play/';
    if (uri.queryParameters.containsKey('play')) {
      api = uri.queryParameters['play'];
    }

    var apiParams = [];
    for (var key in uri.queryParameters.keys) {
      if (key != 'api' && key != 'play' && key != 'schema') {
        apiParams.add('${key}=${uri.queryParameters[key]}');
      }
    }

    var apiUrl = '${schema}://${uri.host}:${port}${api}';
    if (!apiParams.isEmpty) {
      apiUrl += '?' + apiParams.join('&');
    }

    WebRTCUri r = WebRTCUri();
    r.api = apiUrl;
    r.streamUrl = url;
    print('Url ${url} parsed to api=${r.api}, stream=${r.streamUrl}');
    return r;
  }
}

/// A WebRTC player, using [flutter_webrtc](https://pub.dev/packages/flutter_webrtc)
class WebRTCPlayer {
  webrtc.AddStreamCallback _onRemoteStream;
  webrtc.RTCPeerConnection _pc;

  /// When got a remote stream.
  set onRemoteStream(webrtc.AddStreamCallback v) {
    _onRemoteStream = v;
  }

  /// Initialize the player.
  void initState() {
  }

  /// Start play a url.
  /// [url] must a path parsed by [WebRTCUri.parse] in https://github.com/rtcdn/rtcdn-draft
  Future<void> play(String url) async {
    if (_pc != null) {
      await _pc.close();
    }

    // Create the peer connection.
    _pc = await webrtc.createPeerConnection({
      // AddTransceiver is only available with Unified Plan SdpSemantics
      'sdpSemantics': "unified-plan"
    });

    print('WebRTC: createPeerConnection done');

    // Setup the peer connection.
    _pc.onAddStream = (webrtc.MediaStream stream) {
      print('WebRTC: got stream ${stream.id}');
      if (_onRemoteStream == null) {
        print('Warning: Stream ${stream.id} is leak');
        return;
      }
      _onRemoteStream(stream);
    };

    _pc.addTransceiver(
        kind: webrtc.RTCRtpMediaType.RTCRtpMediaTypeAudio,
        init: webrtc.RTCRtpTransceiverInit(direction: webrtc.TransceiverDirection.RecvOnly),
    );
    _pc.addTransceiver(
      kind: webrtc.RTCRtpMediaType.RTCRtpMediaTypeVideo,
      init: webrtc.RTCRtpTransceiverInit(direction: webrtc.TransceiverDirection.RecvOnly),
    );
    print('WebRTC: Setup PC done, A|V RecvOnly');

    // Start SDP handshake.
    webrtc.RTCSessionDescription offer = await _pc.createOffer({
      'mandatory': {'OfferToReceiveAudio': true, 'OfferToReceiveVideo': true},
    });
    await _pc.setLocalDescription(offer);
    print('WebRTC: createOffer, ${offer.type} is ${offer.sdp.replaceAll('\n', '\\n').replaceAll('\r', '\\r')}');

    webrtc.RTCSessionDescription answer = await _handshake(url, offer.sdp);
    print('WebRTC: got ${answer.type} is ${answer.sdp.replaceAll('\n', '\\n').replaceAll('\r', '\\r')}');

    await _pc.setRemoteDescription(answer);
  }

  /// Handshake to exchange SDP, send offer and got answer.
  Future<webrtc.RTCSessionDescription> _handshake(String url, String offer) async {
    // Setup the client for HTTP or HTTPS.
    HttpClient client = HttpClient();

    try {
      // Allow self-sign certificate, see https://api.flutter.dev/flutter/dart-io/HttpClient/badCertificateCallback.html
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;

      // Parsing the WebRTC uri form url.
      WebRTCUri uri = WebRTCUri.parse(url);

      // Do signaling for WebRTC.
      // @see https://github.com/rtcdn/rtcdn-draft
      //
      // POST http://d.ossrs.net:11985/rtc/v1/play/
      //    {api: "xxx", sdp: "offer", streamurl: "webrtc://d.ossrs.net:11985/live/livestream"}
      // Response:
      //    {code: 0, sdp: "answer", sessionid: "007r51l7:X2Lv"}
      HttpClientRequest req = await client.postUrl(Uri.parse(uri.api));
      req.headers.set('Content-Type', 'application/json');
      req.add(utf8.encode(json.encode({'api': uri.api, 'streamurl': uri.streamUrl, 'sdp': offer})));
      print('WebRTC request: ${uri.api} offer=${offer.length}B');

      HttpClientResponse res = await req.close();
      String reply = await res.transform(utf8.decoder).join();
      print('WebRTC reply: ${reply.length}B, ${res.statusCode}');

      Map<String, dynamic> o = json.decode(reply);
      if (!o.containsKey('code') || !o.containsKey('sdp') || o['code'] != 0) {
        return Future.error(reply);
      }

      return Future.value(webrtc.RTCSessionDescription(o['sdp'], 'answer'));
    } finally {
      client.close();
    }
  }

  /// Dispose the player.
  void dispose() {
    if (_pc != null) {
      _pc.close();
    }
  }
}

