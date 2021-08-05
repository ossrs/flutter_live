import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class Privacy extends StatefulWidget {
  @override
  State createState() => _PrivacyState();
}

class _PrivacyState extends State<Privacy> {
  bool _privacyAggreed = false;
  bool _btnEnabled = false;

  @override
  Widget build(BuildContext context) {
    return _privacyAggreed? Home() : PrivacyDisplay(_btnEnabled, _onReadPrivacy, _onAgreePrivacy);
  }

  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  void asyncInit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _privacyAggreed = prefs.getBool('login')?? false;
    });
  }

  void _onReadPrivacy() {
    setState(() {
      _btnEnabled = !_btnEnabled;
    });
  }

  void _onAgreePrivacy()  async {
    setState(() {
      _privacyAggreed = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("login", _privacyAggreed);
  }
}

class PrivacyDisplay extends StatelessWidget {
  final bool _btnEnabled;
  final VoidCallback _onAgreePrivacy;
  final VoidCallback _onReadPrivacy;
  PrivacyDisplay(this._btnEnabled, this._onReadPrivacy, this._onAgreePrivacy);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SRS: Privacy')),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                MaterialButton(
                  onPressed: _btnEnabled ? this._onAgreePrivacy : null,
                  child: Text(
                    "开始使用",
                    style: TextStyle(
                        fontSize: 15.0, fontWeight: FontWeight.bold),
                  ),
                  color: Color(0xffFFDB2E),
                  textColor: Color(0xff202326),
                  disabledColor: Color(0xffdddddd),
                  height: 44.0,
                  minWidth: 240.0,
                  elevation: 0.0,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Checkbox(value: _btnEnabled, onChanged: (bool) {
                  _onReadPrivacy();
                }),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '我已阅读并同意',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _onReadPrivacy();
                          },
                      ),
                      TextSpan(
                        text: '《隐私政策》',
                        style: TextStyle(color: Color(0xFF00CED2)),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launch('https://ossrs.net/privacy_cn');
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
      ),
    );
  }
}