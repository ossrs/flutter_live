import 'package:flutter/material.dart';

import 'package:flutter_live/flutter_live.dart';
import 'package:fijkplayer/fijkplayer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home()
    );
  }
}

class Home extends StatefulWidget {
  @override
  State createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SRS: Flutter Live Streaming'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            autofocus: false,
          ),
          RadioListTile(
            title: Text('RTMP'),
            subtitle: Text(FlutterLive.rtmp),
            value: FlutterLive.rtmp,
            selected: _controller.text == FlutterLive.rtmp,
            groupValue: _controller.text,
            onChanged: (v) {
              setState(() {
                updateUrls(v);
              });
            },
          ),
          RadioListTile(
            title: Text('HLS'),
            value: FlutterLive.hls,
            subtitle: Text(FlutterLive.hls),
            selected: _controller.text == FlutterLive.hls,
            groupValue: _controller.text,
            onChanged: (v) {
              setState(() {
                updateUrls(v);
              });
            },
          ),
          RadioListTile(
            title: Text('HTTP-FLV'),
            subtitle: Text(FlutterLive.flv),
            value: FlutterLive.flv,
            selected: _controller.text == FlutterLive.flv,
            groupValue: _controller.text,
            onChanged: (v) {
              setState(() {
                updateUrls(v);
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              RaisedButton(
                child: Text('Play'),
                onPressed: () {
                  startPlay(context);
                },
              ),
              Container(
                width: 10,
              )
            ],
          ),
        ],
      ),
    );
  }

  void updateUrls(String v) {
    _controller.text = v;
  }

  void startPlay(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return VideoPlayer(url: _controller.text);
    }));
  }
}

class VideoPlayer extends StatefulWidget {
  final String url;

  VideoPlayer({@required this.url});

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
    print('Start play ${widget.url}');

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

    await player.setDataSource(widget.url, autoPlay: true).catchError((e) {
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
