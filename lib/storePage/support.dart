import 'package:flutter/material.dart';

class Support extends StatelessWidget {
  static const id = 'support';
  final Function callback;

  Support(this.callback);

  List<String> _title = [
    'Give us a call',
    'Send an email',
    'Troubleshoot',
    'Send a report',
    'Rate the app',
    'Start checkout tour'
  ];

  List<String> _subTitle = [
    '02-1234-5678',
    'retail-support@gavincorp.com',
    'https://help.gavincorp.com/kr/',
    'Help us improve',
    'Tell us how we\'re doing.',
    'Learn how to print a simple receipt.'
  ];

  List<String> _pic = [
    'phone-call',
    'email_support',
    'tools',
    'bug',
    'star',
    'chat_support'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: 400.0,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 1.0), //(x,y)
              blurRadius: 6.0,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Support",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _title.length,
                itemBuilder: (context, index) {
                  return MaterialButton(
                    onPressed: () {
                      if(index == 5) {
                        callback();
                      }
                    },
                    child: Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Transform(
                            child: Image.asset(
                              'assets/${_pic[index]}.png',
                              width: 20.0,
                            ),
                            transform: Matrix4.translationValues(0, -10, 0),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _title[index],
                                style: TextStyle(
                                  fontSize: 15.0,
                                ),
                              ),
                              Text(
                                _subTitle[index],
                                style: TextStyle(
                                  fontSize: 13.0,
                                  color: Colors.black54,
                                ),
                              ),
                              index != _title.length - 1
                                  ? Divider(
                                      color: Colors.black,
                                    )
                                  : SizedBox(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
