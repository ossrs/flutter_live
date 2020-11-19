import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import 'package:flutter_live/flutter_live.dart' as flutter_live;
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:fijkplayer/fijkplayer.dart' as fijkplayer;
import 'package:camera_with_rtmp/camera.dart' as camera;

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: Home()));
}

class Home extends StatefulWidget {
  @override
  State createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Platform information.
  PackageInfo _info = PackageInfo(version: '0.0.0', buildNumber: '0');

  // The url to play or publish.
  String _url; // The final url, should equals to controller.text
  final TextEditingController _urlController = TextEditingController();

  // For publisher.
  bool _isPublish = false;
  // The controller for publisher.
  camera.CameraController _cameraController = null;

  @override
  void initState() {
    super.initState();

    _urlController.text = _url;
    _urlController.addListener(_onUserEditUrl);

    PackageInfo.fromPlatform().then((info) {
      setState(() { _info = info; });
    }).catchError((e) {
      print('platform error $e');
    });
  }

  @override
  void dispose() {
    super.dispose();
    _urlController.dispose();
    stopPublish();
    print('main state disposed');
  }

  void _onUserEditUrl() {
    print('user edit event url=$_url, text=${_urlController.text}');
    if (_url != _urlController.text) {
      setState(() {
        _url = _urlController.text;
      });
    }
  }

  void _onUserSelectUrl(String v) {
    print('user select $v, url=$_url, text=${_urlController.text}');
    if (_url != v) {
      setState(() {
        _urlController.text = _url = v;
      });
    }
  }

  bool isUrlValid() {
    return _url != null && _url.contains('://');
  }

  void stopPublish() async {
    if (_cameraController == null) {
      return;
    }
    await _cameraController.stopVideoStreaming();
    await _cameraController.dispose();
    _cameraController = null;
    print('camera disposed');
  }

  void _onStartPlayOrPublish(BuildContext context) async {
    if (!isUrlValid()) {
      print('Invalid url $_url');
      return;
    }

    print('${_isPublish? "Publish":"Play"} $_url');

    // For player.
    if (!_isPublish) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return _url.startsWith('webrtc://')? WebRTCStreamingPlayer(_url) : LiveStreamingPlayer(_url);
      }));
      return;
    }

    // For publisher.
    if (_url.startsWith('rtmp://')) {
      stopPublish();

      var cameras = await camera.availableCameras();
      if (cameras.isEmpty) {
        print('Error: no cameras');
        return;
      }

      camera.CameraDescription desc = cameras[0];
      for (var c in cameras) {
        if (c.lensDirection == camera.CameraLensDirection.front) {
          desc = c;
          break;
        }
      }
      print('use camera ${desc.name} ${desc.lensDirection}');

      _cameraController =
          camera.CameraController(desc, camera.ResolutionPreset.low);
      _cameraController.addListener(() {
        setState(() {
          print('got camera event');
        });
      });

      await _cameraController.initialize();
      print('camera initialized ok');

      await _cameraController.startVideoStreaming(_url, bitrate: 300 * 1000);
      print('start streaming to $_url');

      setState(() {});
    }
  }

  void _onSwitchPublish(bool v) {
    if (!v) {
      stopPublish();
    }
    setState(() { _isPublish = v; });
  }

  @override
  Widget build(BuildContext context) {
    var cameraPreviewWidget = () {
      if (!_isPublish) {
        return Container();
      }
      
      if (_cameraController == null) {
        return Container();
      }

      if (!_cameraController.value.isInitialized) {
        return Container(child: Text('camera not available'));
      }

      return AspectRatio(
          aspectRatio: _cameraController.value.aspectRatio,
          child: camera.CameraPreview(_cameraController)
      );
    };

    var _onStartPlayOrPublish = () {
      this._onStartPlayOrPublish(context);
    };

    return Scaffold(
      appBar: AppBar(title: Text('SRS: Flutter Live Streaming')),
      body: ListView(children: [
        UrlInputDisplay(_urlController),
        ControlDisplay(isUrlValid(), _onStartPlayOrPublish, _isPublish, this._onSwitchPublish),
        cameraPreviewWidget(),
        DemoUrlsDisplay(_url, _onUserSelectUrl, _isPublish),
        PlatformDisplay(this._info),
      ]),
    );
  }
}

class UrlInputDisplay extends StatelessWidget {
  final TextEditingController _controller;
  UrlInputDisplay(this._controller);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        controller: _controller, autofocus: false,
        decoration: InputDecoration(hintText: 'Please select or input url...')
      ),
      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
    );
  }
}

class DemoUrlsDisplay extends StatelessWidget {
  final String _url;
  final ValueChanged<String> _onUserSelectUrl;
  final bool _isPublish;
  DemoUrlsDisplay(this._url, this._onUserSelectUrl, this._isPublish);

  @override
  Widget build(BuildContext context) {
    return Container(child:
      _isPublish? Column(children: [
        ListTile(
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('RTMP', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(flutter_live.FlutterLive.rtmp_publish, style: TextStyle(color: Colors.grey[500])),
          ]),
          onTap: () => _onUserSelectUrl(flutter_live.FlutterLive.rtmp_publish), contentPadding: EdgeInsets.zero,
          leading: Radio(value: flutter_live.FlutterLive.rtmp_publish, groupValue: _url, onChanged: _onUserSelectUrl),
        ),
      ],) : Column(children: [
        ListTile(
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('RTMP', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(flutter_live.FlutterLive.rtmp, style: TextStyle(color: Colors.grey[500])),
          ]),
          onTap: () => _onUserSelectUrl(flutter_live.FlutterLive.rtmp), contentPadding: EdgeInsets.zero,
          leading: Radio(value: flutter_live.FlutterLive.rtmp, groupValue: _url, onChanged: _onUserSelectUrl),
        ),
        ListTile(
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('HLS', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(flutter_live.FlutterLive.hls, style: TextStyle(color: Colors.grey[500])),
          ]),
          onTap: () => _onUserSelectUrl(flutter_live.FlutterLive.hls), contentPadding: EdgeInsets.zero,
          leading: Radio(value: flutter_live.FlutterLive.hls, groupValue: _url, onChanged: _onUserSelectUrl),
        ),
        ListTile(
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('HTTP-FLV', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(flutter_live.FlutterLive.flv, style: TextStyle(color: Colors.grey[500])),
          ]),
          onTap: () => _onUserSelectUrl(flutter_live.FlutterLive.flv), contentPadding: EdgeInsets.zero,
          leading: Radio(value: flutter_live.FlutterLive.flv, groupValue: _url, onChanged: _onUserSelectUrl),
        ),
        ListTile(
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('WebRTC', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(flutter_live.FlutterLive.rtc, style: TextStyle(color: Colors.grey[500], fontSize: 15)),
          ]),
          onTap: () => _onUserSelectUrl(flutter_live.FlutterLive.rtc), contentPadding: EdgeInsets.zero,
          leading: Radio(value: flutter_live.FlutterLive.rtc, groupValue: _url, onChanged: _onUserSelectUrl),
        ),
        ListTile(
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('HTTPS-FLV', style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              child: Text(flutter_live.FlutterLive.flvs, style: TextStyle(color: Colors.grey[500], fontSize: 15)),
              padding: EdgeInsets.only(top: 3, bottom:3),
            ),
          ]),
          onTap: () => _onUserSelectUrl(flutter_live.FlutterLive.flvs), contentPadding: EdgeInsets.zero,
          leading: Radio(value: flutter_live.FlutterLive.flvs, groupValue: _url, onChanged: _onUserSelectUrl),
        ),
        ListTile(
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('HTTPS-HLS', style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              child: Text(flutter_live.FlutterLive.hlss, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
              padding: EdgeInsets.only(top: 3, bottom: 3),
            ),
          ]),
          onTap: () => _onUserSelectUrl(flutter_live.FlutterLive.hlss), contentPadding: EdgeInsets.zero,
          leading: Radio(value: flutter_live.FlutterLive.hlss, groupValue: _url, onChanged: _onUserSelectUrl),
        ),
      ]),
    );
  }
}

class ControlDisplay extends StatelessWidget {
  final bool _urlAvailable;
  final VoidCallback _onStartPlayOrPublish;
  final bool _isPubslish;
  final ValueChanged<bool> _onSwitchPublish;
  ControlDisplay(this._urlAvailable, this._onStartPlayOrPublish, this._isPubslish, this._onSwitchPublish);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            Text('Publish'),
            Switch(value: _isPubslish, onChanged: _onSwitchPublish),
          ],
        ),
        Container(
          width: 120,
          child:ElevatedButton(
            child: Text(_isPubslish? 'Publish' : 'Play'),
            onPressed: _urlAvailable? _onStartPlayOrPublish : null,
          ),
        ),
      ],
    );
  }
}

class PlatformDisplay extends StatelessWidget {
  final PackageInfo _info;
  PlatformDisplay(this._info);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Text('SRS/v${_info.version}+${_info.buildNumber}')],
    );
  }
}

class LiveStreamingPlayer extends StatefulWidget {
  final String _url;
  LiveStreamingPlayer(this._url);

  @override
  _LiveStreamingPlayerState createState() => _LiveStreamingPlayerState();
}

class _LiveStreamingPlayerState extends State<LiveStreamingPlayer> {
  final flutter_live.RealtimePlayer _player = flutter_live.RealtimePlayer(fijkplayer.FijkPlayer());

  @override
  void initState() {
    super.initState();
    _player.initState();
    autoPlay();
  }

  void autoPlay() async {
    // Auto start play live streaming.
    await _player.play(widget._url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SRS Live Streaming')),
      body: fijkplayer.FijkView(
        player: _player.fijk, panelBuilder: fijkplayer.fijkPanel2Builder(),
        fsFit: fijkplayer.FijkFit.fill
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _player.dispose();
  }
}

class WebRTCStreamingPlayer extends StatefulWidget {
  final String _url;
  WebRTCStreamingPlayer(this._url);

  @override
  State<StatefulWidget> createState() => _WebRTCStreamingPlayerState();
}

class _WebRTCStreamingPlayerState extends State<WebRTCStreamingPlayer> {
  bool _loudspeaker = true;
  final webrtc.RTCVideoRenderer _video = webrtc.RTCVideoRenderer();
  final flutter_live.WebRTCPlayer _player = flutter_live.WebRTCPlayer();

  @override
  void initState() {
    super.initState();
    _player.initState();
    autoPlay();
  }

  void autoPlay() async {
    await _video.initialize();

    // Render stream when got remote stream.
    _player.onRemoteStream = (webrtc.MediaStream stream) {
      // @remark It's very important to use setState to set the srcObject and notify render.
      setState(() { _video.srcObject = stream; });
    };

    // Auto start play WebRTC streaming.
    await _player.play(widget._url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SRS WebRTC Streaming')),
      body: GestureDetector(onTap: _switchLoudspeaker, child: Container(
        child: webrtc.RTCVideoView(_video), decoration: BoxDecoration(color: Colors.grey[500])
      )),
    );
  }

  void _switchLoudspeaker() {
    print('setSpeakerphoneOn: $_loudspeaker(${_loudspeaker? "Loudspeaker":"Earpiece"})');
    flutter_live.FlutterLive.setSpeakerphoneOn(_loudspeaker);
    _loudspeaker = !_loudspeaker;
  }

  @override
  void dispose() {
    super.dispose();
    _video.dispose();
    _player.dispose();
  }
}

