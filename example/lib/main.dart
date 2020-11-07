import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import 'package:flutter_live/flutter_live.dart';
import 'package:fijkplayer/fijkplayer.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  State createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _url;
  PackageInfo _info;
  _HomeState() {
    _info = PackageInfo(version: '0.0.0', buildNumber: '0');
  }

  @override
  void initState() {
    super.initState();

    PackageInfo.fromPlatform().then((info) {
      setState(() { _info = info; });
    }).catchError((e){
      print('platform error $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SRS: Flutter Live Streaming'),
      ),
      body: Column(children: [
        UrlInputDisplay(_url, onUrlChanged),
        DemoUrlsDisplay(_url, onUrlChanged),
        ControlDisplay((){ this.startPlay(context); }),
        PlatformDisplay(this._info),
      ]),
    );
  }

  void onUrlChanged(String v) {
    setState(() { _url = v; });
  }

  void startPlay(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return VideoPlayer(_url);
    }));
  }
}

class ControlDisplay extends StatelessWidget {
  final VoidCallback _onPlayUrl;
  ControlDisplay(this._onPlayUrl);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        RaisedButton(child: Text('Play'), onPressed: _onPlayUrl),
        Container(width: 10)
      ],
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
      RadioListTile(
        title: Text('RTMP'), subtitle: Text(FlutterLive.rtmp), value: FlutterLive.rtmp,
        selected: _url == FlutterLive.rtmp, groupValue: _url, onChanged: _onUrlChanged
      ),
      RadioListTile(
        title: Text('HLS'), value: FlutterLive.hls, subtitle: Text(FlutterLive.hls),
        selected: _url == FlutterLive.hls, groupValue: _url, onChanged: _onUrlChanged
      ),
      RadioListTile(
        title: Text('HTTP-FLV'), subtitle: Text(FlutterLive.flv), value: FlutterLive.flv,
        selected: _url == FlutterLive.flv, groupValue: _url, onChanged: _onUrlChanged
      ),
      RadioListTile(
        title: Text('HTTPS-FLV'), subtitle: Text(FlutterLive.flvs), value: FlutterLive.flvs,
        selected: _url == FlutterLive.flvs, groupValue: _url, onChanged: _onUrlChanged
      ),
      RadioListTile(
        title: Text('HTTPS-HLS'), subtitle: Text(FlutterLive.hlss), value: FlutterLive.hlss,
        selected: _url == FlutterLive.hlss, groupValue: _url, onChanged: _onUrlChanged
      ),
    ]);
  }
}

class UrlInputDisplay extends StatelessWidget {
  final ValueChanged<String> _onUrlChanged;
  final TextEditingController _controller = TextEditingController();
  UrlInputDisplay(String url, this._onUrlChanged) {
    _controller.text = url;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(controller: _controller, autofocus: false, onChanged: _onUrlChanged);
  }
}

class PlatformDisplay extends StatelessWidget {
  final PackageInfo _info;
  PlatformDisplay(this._info);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('SRS/v${_info.version}+${_info.buildNumber}')
      ],
    );
  }
}

class VideoPlayer extends StatefulWidget {
  final String _url;
  VideoPlayer(this._url);

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  final FijkPlayer player = FijkPlayer();

  @override
  void initState() {
    super.initState();
    player.setOption(FijkOption.playerCategory, "mediacodec-all-videos", 1);
    startPlay();
  }

  void startPlay() async {
    print('Start play ${widget._url}');

    await player.setOption(FijkOption.hostCategory, "request-screen-on", 1);
    await player.setOption(FijkOption.hostCategory, "request-audio-focus", 1);

    // Live low-latency: https://www.jianshu.com/p/d6a5d8756eec
    // For all options, read https://github.com/Bilibili/ijkplayer/blob/master/ijkmedia/ijkplayer/ff_ffplay_options.h
    await player.setOption(FijkOption.formatCategory, "probesize", 16 * 1024); // in bytes
    await player.setOption(FijkOption.formatCategory, "analyzeduration", 100 * 1000); // in us
    await player.setOption(FijkOption.playerCategory, "packet-buffering", 0); // 0, no buffer.
    await player.setOption(FijkOption.playerCategory, "max_cached_duration", 800); // in ms
    await player.setOption(FijkOption.playerCategory, "max-buffer-size", 32 * 1024); // in bytes
    await player.setOption(FijkOption.playerCategory, "infbuf", 1); // 1 for realtime.
    await player.setOption(FijkOption.playerCategory, "min-frames", 1); // in frames

    await player.setDataSource(widget._url, autoPlay: true).catchError((e) {
      print("setDataSource error: $e");
    });

    player.enterFullScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('SRS Live Streaming'),
        ),
        body: Container(
            child: FijkView(
              player: player,
              panelBuilder: fijkPanel2Builder(),
              fsFit: FijkFit.fill,
            )
        )
    );
  }

  @override
  void dispose() {
    super.dispose();
    player.release();
  }
}
