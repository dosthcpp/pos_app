import 'package:flutter/material.dart';
import 'package:pos_app/main.dart';
import 'package:pos_app/main_page.dart';
import 'package:provider/provider.dart';

class PurchaseSpec extends StatelessWidget {

  final renderIdx;

  PurchaseSpec({this.renderIdx});

  _renderTime(purchase) {
    final _date = orderProvider.purchaseList?.length == 0
        ? DateTime.now()
        : purchase.date;
    if (_date != null) {
      final hour = _date.hour > 12 ? _date.hour - 12 : _date.hour;
      final hourString = hour < 10 ? "0$hour" : hour;
      final minute = _date.minute < 10 ? "0${_date.minute}" : _date.minute;

      return "${_date.difference(DateTime.now()).inDays == 0 ? "Today" : _date.toLocal().toString().split(" ")[0].split("-").join(".")} at $hourString:$minute${_date.hour < 13 ? "AM" : "PM"}";
    } else {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, _) {
        final purchase = provider?.purchaseList?.length == 0
            ? Purchase()
            : provider?.purchaseList?.elementAt(renderIdx);
        return Column(
          children: [
            Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 250.0,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        image: ExactAssetImage('assets/background.jpg'),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(
                        color: Colors.black12,
                      )),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 15.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_renderTime(purchase)),
                        Text(
                          "\$${oCcy.format(purchase.totalPrice ?? 0)}",
                          style: TextStyle(fontSize: 40.0),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 90.0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 130.0,
                    color: Colors.white,
                    child: Padding(
                      padding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Purchase Info",
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              Text(
                                "Buyer",
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    'assets/user.png',
                                    width: 40.0,
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Tobi Lutke"),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Text(
                                        "Ottawa, Ontario",
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.black54,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0, left: 20.0, bottom: 5.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Items",
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: purchase?.itemNames?.length ?? 0,
                itemBuilder: (context, index) {
                  final _name = purchase?.itemNames?.elementAt(index);
                  final _count = purchase?.itemCounts?.elementAt(index);
                  final _price = purchase?.prices?.elementAt(index);
                  final _totalPrice = _price * _count;
                  if (_name != null && _count != null) {
                    return Column(
                      children: [
                        Container(
                            height: 100.0,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 18.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 10.0,
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _name,
                                              style: TextStyle(
                                                  color: Colors.black, fontSize: 18.0),
                                            ),
                                            SizedBox(
                                              height: 8.0,
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "\$${oCcy.format(_totalPrice)}",
                                        style: TextStyle(
                                          fontSize: 18.0,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Text(
                                        "(\$${oCcy.format(_totalPrice)} x $_count)",
                                        style: TextStyle(
                                          color: Colors.black54,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            )),
                        Divider(),
                      ],
                    );
                  }
                  return CircularProgressIndicator();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}