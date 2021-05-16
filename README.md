# flutter-live

![](https://ossrs.net/gif/v1/sls.gif?site=github.com&path=/srs/flutter_live)
[![Pub Version](https://img.shields.io/pub/v/flutter_live)](https://pub.dev/packages/flutter_live)
[![](https://cloud.githubusercontent.com/assets/2777660/22814959/c51cbe72-ef92-11e6-81cc-32b657b285d5.png)](https://github.com/ossrs/srs/wiki/v1_CN_Contact#wechat)

跨平台(iOS+Andriod)多协议(RTMP/HTTP-FLV/HLS/WebRTC)直播播放器, Flutter+[SRS](https://github.com/ossrs/srs)。

Live Streaming player, iOS+Android, RTMP/HTTP-FLV/HLS/WebRTC, by Flutter+[SRS](https://github.com/ossrs/srs).

## Usage

国内设置代理：

```bash
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn && 
export PUB_HOSTED_URL=https://pub.flutter-io.cn
```

编译和运行SRS直播（iOS可以从[这里](https://ossrs.net)安装）：

```
git clone https://github.com/ossrs/flutter_live.git &&
cd flutter_live/example && flutter run
```

> Warning: Not support iOS simulator, [#14647](https://github.com/flutter/flutter/issues/14647).

![Home](https://ossrs.net/srs.release/images/01-home-02.jpg)

![Home](https://ossrs.net/srs.release/images/02-show-01.jpg)

![Home](https://ossrs.net/srs.release/images/03-realtime.jpg)

