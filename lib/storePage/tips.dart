import 'package:flutter/material.dart';

class Tips extends StatefulWidget {
  static const id = 'tips';

  @override
  _TipsState createState() => _TipsState();
}

class _TipsState extends State<Tips> {
  bool _willEnableTips = false;
  bool _willEnableCustomTips = false;
  bool _willMinimizeTipAmounts = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        height: _willEnableTips ? 400.0 : 100.0,
        duration: Duration(milliseconds: 300),
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
          padding: EdgeInsets.all(15.0),
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              Text(
                "Tips",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 15.0,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Enable Tips",
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                  Switch(
                    value: _willEnableTips,
                    onChanged: (value) {
                      setState(() {
                        _willEnableTips = value;
                      });
                    },
                  ),
                ],
              ),
              Visibility(
                visible: _willEnableTips,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Option 1'
                      ),
                      initialValue: '15%',
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Option 2'
                      ),
                      initialValue: '18%',
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Option 3'
                      ),
                      initialValue: '20%',
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Enable custom tips",
                              style: TextStyle(
                                fontSize: 20.0,
                              ),
                            ),
                            Text(
                              "Allows the customer to customize\ntip amounts",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _willEnableCustomTips,
                          onChanged: (value) {
                            setState(() {
                              _willEnableCustomTips = value;
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Minimun tip amounts",
                              style: TextStyle(
                                fontSize: 20.0,
                              ),
                            ),
                            Text(
                              "Allows tips to be paid in specified\namounts under the transaction limit.",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _willMinimizeTipAmounts,
                          onChanged: (value) {
                            setState(() {
                              _willMinimizeTipAmounts = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
