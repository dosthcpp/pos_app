import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pos_app/main_page.dart';

class StartingPage extends StatefulWidget {
  static const id = 'starting_page';

  @override
  _StartingPageState createState() => _StartingPageState();
}

class _StartingPageState extends State<StartingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Image.asset(
            "assets/starting.jpg",
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
          ),
          _LoginForm(() {
            Navigator.pushNamed(context, MainPage.id);
          }),
        ],
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  Function callback;

  _LoginForm(this.callback);

  @override
  __LoginFormState createState() => __LoginFormState();
}

class __LoginFormState extends State<_LoginForm> {
  TextStyle style = TextStyle(
    fontSize: 20.0,
  );

  var email, passwd;
  double _progress = 0;

  void startTimer() {
    Timer.periodic(
      Duration(milliseconds: 400),
      (Timer timer) => setState(
        () {
          if (_progress == 1) {
            timer.cancel();
          } else {
            _progress += 0.2;
          }
        },
      ),
    );
  }

  @override
  void initState() {
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final emailField = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          40.0,
        ),
      ),
      child: TextField(
        onChanged: (val) => {
          setState(() => {email = val})
        },
        obscureText: false,
        style: style,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            hintText: "Email",
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      ),
    );
    final passwordField = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          40.0,
        ),
      ),
      child: TextField(
        onChanged: (val) => {
          setState(() => {passwd = val})
        },
        obscureText: true,
        style: style,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            hintText: "Password",
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      ),
    );
    final loginButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          if (email == 'test' && passwd == 'test') {
            widget.callback();
          } else {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Alert!'),
                    content: Text("ID or password is wrong!"),
                    actions: [
                      FlatButton(
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.pop(context, "OK");
                        },
                      ),
                    ],
                  );
                });
          }
        },
        child: Text(
          "Login",
          textAlign: TextAlign.center,
          style:
              style.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );

    return Stack(
      children: [
        _progress != 1.0
            ? SizedBox(
                height: 10.0,
                child: Container(
                  child: LinearProgressIndicator(
                    value: _progress,
                  ),
                ),
              )
            : Container(),
        _progress == 1.0
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: MediaQuery.of(context).size.width / 10 * 3,
                    height: MediaQuery.of(context).size.height / 10 * 5,
                    decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(25.0)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15.0,
                        vertical: 0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          emailField,
                          SizedBox(height: 25.0),
                          passwordField,
                          SizedBox(
                            height: 35.0,
                          ),
                          loginButton,
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : Container(),
        Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            "v1.0.0",
            style: TextStyle(fontSize: 15.0),
          ),
        )
      ],
    );
  }
}
