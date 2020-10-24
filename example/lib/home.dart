import 'package:flutter/material.dart';
import 'package:flutter_live/flutter_live.dart';

import 'video_player.dart';

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