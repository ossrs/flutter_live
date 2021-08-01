import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class Startup extends StatefulWidget {
  @override
  State createState() => _StartupState();
}

class _StartupState extends State<Startup> {
  bool _login = false;
  bool _btnEnabled = false;

  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  void asyncInit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _login = prefs.getBool('login')?? false;
    });
  }

  void _onAgreePrivacy(bool v) {
    setState(() {
      _btnEnabled = v;
    });
  }

  void _onLogin()  async {
    setState(() {
      _login = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("login", _login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SRS: Flutter Live Streaming')),
      body: Container(
        child: _login? Home() : PrivacyDisplay(_btnEnabled, _onAgreePrivacy, _onLogin),
      ),
    );
  }
}

class PrivacyDisplay extends StatelessWidget {
  final bool _btnEnabled;
  final VoidCallback _onLogin;
  final ValueChanged<bool> _onAgreePrivacy;
  PrivacyDisplay(this._btnEnabled, this._onAgreePrivacy, this._onLogin);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget> [
              MaterialButton(
                onPressed: _btnEnabled? this._onLogin : null,
                child: Text(
                  "开始使用",
                  style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
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
            children: <Widget> [
              Checkbox(value: _btnEnabled, onChanged: _onAgreePrivacy),
              Text.rich(
                TextSpan(
                  text: '我已阅读并同意',
                  children: [
                    TextSpan(
                      text: '《隐私政策》',
                      style: TextStyle(color: Color(0xFF00CED2)),
                      recognizer: TapGestureRecognizer()..onTap = () {
                        launch('https://ossrs.net/privacy');
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
    );
  }
}