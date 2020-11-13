import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import 'package:flutter_live/flutter_live.dart' as flutter_live;
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:fijkplayer/fijkplayer.dart' as fijkplayer;

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: Home()));
}

class Home extends StatefulWidget {
  @override
  State createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _url; // The final url, should equals to controller.text
  PackageInfo _info = PackageInfo(version: '0.0.0', buildNumber: '0');
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller.text = _url;
    _controller.addListener(onUserEditUrl);

    PackageInfo.fromPlatform().then((info) {
      setState(() { _info = info; });
    }).catchError((e) {
      print('platform error $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SRS: Flutter Live Streaming')),
      body: ListView(children: [
        UrlInputDisplay(_controller),
        DemoUrlsDisplay(_url, onUseSelectedUrl),
        ControlDisplay(isUrlValid(), () => this.startPlay(context)),
        PlatformDisplay(this._info),
      ]),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void onUserEditUrl() {
    print('user edit event url=$_url, text=${_controller.text}');
    if (_url != _controller.text) {
      setState(() { _url = _controller.text; });
    }
  }

  void onUseSelectedUrl(String v) {
    print('user select $v, url=$_url, text=${_controller.text}');
    if (_url != v) {
      setState(() { _controller.text = _url = v; });
    }
  }

  bool isUrlValid() {
    return _url != null && _url.contains('://');
  }

  void startPlay(BuildContext context) {
    if (!isUrlValid()) {
      print('Invalid url $_url');
      return;
    }

    Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          if (!_url.startsWith('webrtc://')) {
            return LiveStreamingPlayer(_url);
          } else {
            return WebRTCStreamingPlayer(_url);
          }
        })
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
  final ValueChanged<String> _onUrlChanged;
  DemoUrlsDisplay(this._url, this._onUrlChanged);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ListTile(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('RTMP', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(flutter_live.FlutterLive.rtmp, style: TextStyle(color: Colors.grey[500])),
        ]),
        onTap: () => _onUrlChanged(flutter_live.FlutterLive.rtmp), contentPadding: EdgeInsets.zero,
        leading: Radio(value: flutter_live.FlutterLive.rtmp, groupValue: _url, onChanged: _onUrlChanged),
      ),
      ListTile(
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('HLS', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(flutter_live.FlutterLive.hls, style: TextStyle(color: Colors.grey[500])),
          ]),
          onTap: () => _onUrlChanged(flutter_live.FlutterLive.hls), contentPadding: EdgeInsets.zero,
          leading: Radio(value: flutter_live.FlutterLive.hls, groupValue: _url, onChanged: _onUrlChanged),
      ),
      ListTile(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('HTTP-FLV', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(flutter_live.FlutterLive.flv, style: TextStyle(color: Colors.grey[500])),
        ]),
        onTap: () => _onUrlChanged(flutter_live.FlutterLive.flv), contentPadding: EdgeInsets.zero,
        leading: Radio(value: flutter_live.FlutterLive.flv, groupValue: _url, onChanged: _onUrlChanged),
      ),
      ListTile(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('WebRTC', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(flutter_live.FlutterLive.rtc, style: TextStyle(color: Colors.grey[500], fontSize: 15)),
        ]),
        onTap: () => _onUrlChanged(flutter_live.FlutterLive.rtc), contentPadding: EdgeInsets.zero,
        leading: Radio(value: flutter_live.FlutterLive.rtc, groupValue: _url, onChanged: _onUrlChanged),
      ),
      ListTile(
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('HTTPS-FLV', style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              child: Text(flutter_live.FlutterLive.flvs, style: TextStyle(color: Colors.grey[500], fontSize: 15)),
              padding: EdgeInsets.only(top: 3, bottom:3),
            ),
          ]),
          onTap: () => _onUrlChanged(flutter_live.FlutterLive.flvs), contentPadding: EdgeInsets.zero,
          leading: Radio(value: flutter_live.FlutterLive.flvs, groupValue: _url, onChanged: _onUrlChanged),
      ),
      ListTile(
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('HTTPS-HLS', style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              child: Text(flutter_live.FlutterLive.hlss, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
              padding: EdgeInsets.only(top: 3, bottom: 3),
            ),
          ]),
          onTap: () => _onUrlChanged(flutter_live.FlutterLive.hlss), contentPadding: EdgeInsets.zero,
          leading: Radio(value: flutter_live.FlutterLive.hlss, groupValue: _url, onChanged: _onUrlChanged),
      ),
    ]);
  }
}

class ControlDisplay extends StatelessWidget {
  final bool _urlAvailable;
  final VoidCallback _onPlayUrl;
  ControlDisplay(this._urlAvailable, this._onPlayUrl);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          child: Text('Play'), onPressed: _urlAvailable? _onPlayUrl : null,
        ),
        Container(width: 10)
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

