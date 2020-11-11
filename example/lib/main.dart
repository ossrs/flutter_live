import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import 'package:flutter_live/flutter_live.dart';
import 'package:fijkplayer/fijkplayer.dart';

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
          Text(FlutterLive.rtmp, style: TextStyle(color: Colors.grey[500])),
        ]),
        onTap: () => _onUrlChanged(FlutterLive.rtmp), contentPadding: EdgeInsets.zero,
        leading: Radio(value: FlutterLive.rtmp, groupValue: _url, onChanged: _onUrlChanged),
      ),
      ListTile(
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('HLS', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(FlutterLive.hls, style: TextStyle(color: Colors.grey[500])),
          ]),
          onTap: () => _onUrlChanged(FlutterLive.hls), contentPadding: EdgeInsets.zero,
          leading: Radio(value: FlutterLive.hls, groupValue: _url, onChanged: _onUrlChanged),
      ),
      ListTile(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('HTTP-FLV', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(FlutterLive.flv, style: TextStyle(color: Colors.grey[500])),
        ]),
        onTap: () => _onUrlChanged(FlutterLive.flv), contentPadding: EdgeInsets.zero,
        leading: Radio(value: FlutterLive.flv, groupValue: _url, onChanged: _onUrlChanged),
      ),
      ListTile(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('WebRTC', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(FlutterLive.rtc, style: TextStyle(color: Colors.grey[500], fontSize: 15)),
        ]),
        onTap: () => _onUrlChanged(FlutterLive.rtc), contentPadding: EdgeInsets.zero,
        leading: Radio(value: FlutterLive.rtc, groupValue: _url, onChanged: _onUrlChanged),
      ),
      ListTile(
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('HTTPS-FLV', style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              child: Text(FlutterLive.flvs, style: TextStyle(color: Colors.grey[500], fontSize: 15)),
              padding: EdgeInsets.only(top: 3, bottom:3),
            ),
          ]),
          onTap: () => _onUrlChanged(FlutterLive.flvs), contentPadding: EdgeInsets.zero,
          leading: Radio(value: FlutterLive.flvs, groupValue: _url, onChanged: _onUrlChanged),
      ),
      ListTile(
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('HTTPS-HLS', style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              child: Text(FlutterLive.hlss, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
              padding: EdgeInsets.only(top: 3, bottom: 3),
            ),
          ]),
          onTap: () => _onUrlChanged(FlutterLive.hlss), contentPadding: EdgeInsets.zero,
          leading: Radio(value: FlutterLive.hlss, groupValue: _url, onChanged: _onUrlChanged),
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
  final RealtimePlayer _player = RealtimePlayer(FijkPlayer());

  @override
  void initState() {
    super.initState();
    _player.initState();
    // Auto start play live streaming.
    _player.play(widget._url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('SRS Live Streaming')),
        body: FijkView(player: _player.fijk, panelBuilder: fijkPanel2Builder(), fsFit: FijkFit.fill),
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
  @override
  void initState() {
    super.initState();
    startPlay();
  }

  void startPlay() async {
    print('start play WebRTC streaming ${widget._url}');
  }

  @override
  Widget build(BuildContext context) {
    return null;
  }

  @override
  void dispose() {
    super.dispose();
  }
}

