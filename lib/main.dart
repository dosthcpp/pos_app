import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:pos_app/main_page.dart';
import 'package:pos_app/startingPage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:path_provider/path_provider.dart' as pp;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

final OrderProvider orderProvider = OrderProvider();

void main() async {
  runApp(
    ChangeNotifierProvider<OrderProvider>(
      create: (context) => orderProvider,
      child: Phoenix(child: MyApp()),
    ),
  );
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return this.year == other.year &&
        this.month == other.month &&
        this.day == other.day;
  }
}

class OrderProvider extends ChangeNotifier {
  List<ItemList> itemList = [];

  List<Order> orderList = [];
  List<Order> filteredOrderList = [];

  double price = 0.0;
  int orderNo = 1001;

  double balance = 0.0;
  double initialBalance = 0.0;
  double orderBalance = 0.0;
  double purchaseBalance = 0.0;

  DateTime startDatePicked;
  DateTime endDatePicked;
  bool didModifyDate = false;

  int purchaseNo = 1001;
  double purchaseTotalPrice = 0.0;
  DateTime purchaseDate;
  List<PurchaseItem> purchaseBasket = [];
  List<Purchase> purchaseList = [];
  List<Purchase> filteredPurchaseList = [];
  bool didModifyDateInPurchaseList = false;
  DateTime startDatePickedInPurchaseList;
  DateTime endDatePickedInPurchaseList;

  resetAll() async {
    final directory = await pp.getApplicationDocumentsDirectory();
    final file = File('${directory.path}/orders.json');
    final file2 = File('${directory.path}/product.json');
    final file3 = File('${directory.path}/balance.json');
    final file4 = File('${directory.path}/purchases.json');
    await file.writeAsString('[{}]');
    await file2.writeAsString('[{}]');
    await file3.writeAsString('{}');
    await file4.writeAsString('[{}]').then((_) {
      loadOrderData(null);
      loadPurchaseData(null);
      initDate();
      reset();
    });
  }

  reset() {
    itemList.clear();
    orderList.clear();
    filteredOrderList.clear();
    purchaseBasket.clear();
    purchaseList.clear();
    filteredPurchaseList.clear();
    orderNo = 1001;
    purchaseNo = 1001;
    balance = 0.0;
    initialBalance = 0.0;
    orderBalance = 0.0;
    purchaseBalance = 0.0;
    notifyListeners();
  }

  initDate() {
    DateTime now = DateTime.now();
    startDatePicked = DateTime(now.year, now.month, now.day, 0, 0, 0);
    endDatePicked = DateTime(now.year, now.month, now.day, 23, 59, 59);
    didModifyDate = false;

    purchaseDate = DateTime.now();
    startDatePickedInPurchaseList =
        DateTime(now.year, now.month, now.day, 0, 0, 0);
    endDatePickedInPurchaseList =
        DateTime(now.year, now.month, now.day, 23, 59, 59);
    didModifyDateInPurchaseList = false;
  }

  loadOrderData(functionSnapshot) async {
    Future.delayed(Duration.zero, () async {
      final file = File(
          '${(await pp.getApplicationDocumentsDirectory()).path}/orders.json');
      if (!file.existsSync()) return;
      String data = await file.readAsString();
      List<dynamic> jsonResult = json.decode(data);
      if (data == "[{}]" && jsonResult[0].length == 0) {
        orderList = [];
      } else {
        int functionSnapshotIdx = 0;
        jsonResult.forEach((item) async {
          List<ItemList> _itemList = [];
          for (var i = 0; i < item['itemList'].length; ++i) {
            _itemList.add(
              ItemList(
                image: MemoryImage(base64Decode(item['itemList'][i]['image'])),
                title: item['itemList'][i]['title'],
                price: double.parse(item['itemList'][i]['price']),
                itemCount: int.parse(item['itemList'][i]['itemCount']),
              ),
            );
          }
          orderList.add(
            Order(
              functionSnapshot[functionSnapshotIdx++],
              date: DateTime.parse(item['date']),
              totalPrice: double.parse(item['totalPrice']),
              itemList: _itemList.toList(),
              orderNo: int.parse(item['orderNo']),
              cash: item['willUseCash'],
              cashGet: double.parse(item['cashGet']),
              promotion: item['promotion'].toLowerCase() == 'parse',
            ),
          );
          // print(orders[0].itemList[0].runtimeType);
          orderNo++;
        });
      }
    });
  }

  saveOrderData(base64EncodedMap) async {
    String jsonString = "["
        "{";
    if (orderList.length == 0) {
      jsonString += "}]";
    } else {
      for (var i = 0; i < orderList.length; ++i) {
        jsonString +=
            '"orderNo": "${orderList.elementAt(i).orderNo}", "date": "${orderList.elementAt(i).date}", "totalPrice": "${orderList.elementAt(i).totalPrice}", "cash": "${orderList.elementAt(i).cash}", "cashGet": "${orderList.elementAt(i).cashGet}", "promotion": "${orderList.elementAt(i).promotion}",';
        jsonString += '"itemList": [';
        for (var j = 0; j < orderList.elementAt(i).itemList.length; ++j) {
          jsonString +=
              '{"image":"${base64EncodedMap[orderList.elementAt(i).itemList[j].title]}", "title":"${orderList.elementAt(i).itemList[j].title}", "price":"${orderList.elementAt(i).itemList[j].price}", "itemCount":"${orderList.elementAt(i).itemList[j].itemCount}"}';
          if (j != orderList.elementAt(i).itemList.length - 1) {
            jsonString += ',';
          }
        }
        jsonString += ']}';
        if (i != orderList.length - 1) {
          jsonString += ",{";
        }
      }
      jsonString += "]";
    }
    final directory = await pp.getApplicationDocumentsDirectory();
    final file = File('${directory.path}/orders.json');
    await file.writeAsString(jsonString);
    print("done!");
  }

  loadPurchaseData(functionSnapshot) {
    Future.delayed(Duration.zero, () async {
      final file = File(
          '${(await pp.getApplicationDocumentsDirectory()).path}/purchases.json');
      if (!file.existsSync()) return;
      String data = await file.readAsString();
      List<dynamic> jsonResult = json.decode(data);
      if (data == "[{}]" && jsonResult[0].length == 0) {
        purchaseList = [];
      } else {
        int functionSnapshotIdx = 0;
        jsonResult.forEach((item) async {
          List<String> _itemNames = [];
          List<double> _prices = [];
          List<int> _itemCounts = [];

          for (var i = 0; i < item['itemList'].length; ++i) {
            _itemNames.add(item['itemList'][i]['title']);
            _prices.add(double.parse(item['itemList'][i]['price']));
            _itemCounts.add(int.parse(item['itemList'][i]['itemCount']));
          }

          purchaseList.add(
            Purchase(
              showSpec: functionSnapshot[functionSnapshotIdx++],
              date: DateTime.parse(item['date']),
              totalPrice: double.parse(item['totalPrice']),
              purchaseNo: int.parse(item['purchaseNo']),
              prices: _prices,
              itemNames: _itemNames,
              itemCounts: _itemCounts,
            ),
          );
          // print(orders[0].itemList[0].runtimeType);
          purchaseNo++;
        });
      }
    });
  }

  savePurchaseData() async {
    String jsonString = "["
        "{";
    if (purchaseList.length == 0) {
      jsonString += "}]";
    } else {
      for (var i = 0; i < purchaseList.length; ++i) {
        jsonString +=
            '"purchaseNo": "${purchaseList.elementAt(i).purchaseNo}", "date": "${purchaseList.elementAt(i).date}", "totalPrice": "${purchaseList.elementAt(i).totalPrice}", ';
        jsonString += '"itemList": [';
        for (var j = 0; j < purchaseList.elementAt(i).itemNames.length; ++j) {
          jsonString +=
              '{"title":"${purchaseList.elementAt(i).itemNames.elementAt(j)}", "itemCount":"${purchaseList.elementAt(i).itemCounts.elementAt(j)}", "price":"${purchaseList.elementAt(i).prices.elementAt(j)}"}';
          if (j != purchaseList.elementAt(i).itemNames.length - 1) {
            jsonString += ',';
          }
        }
        jsonString += ']}';
        if (i != purchaseList.length - 1) {
          jsonString += ",{";
        }
      }
      jsonString += "]";
    }
    final directory = await pp.getApplicationDocumentsDirectory();
    final file = File('${directory.path}/purchases.json');
    await file.writeAsString(jsonString);
  }

  addList(item, _price) {
    final found = orderProvider.itemList
        .where((_item) => _item.title.toLowerCase() == item.title)
        .toList();
    if (found.length == 0) {
      // 이름이 없으면
      itemList.add(item);
    } else {
      found[0].itemCount++;
    }
    price += _price;
    notifyListeners();
  }

  removeList(itemCount, title, _price) {
    if (itemCount == 1) {
      orderProvider.itemList.removeWhere((item) => item.title == title);
    } else {
      orderProvider.itemList
          .where((item) => item.title == title)
          .toList()[0]
          .itemCount--;
    }
    price -= _price;
    notifyListeners();
  }

  addOrder(order) {
    orderList.add(order);
    notifyListeners();
  }

  clearListItem() {
    itemList.clear();
    price = 0.0;
    notifyListeners();
  }

  selectStartDate(context, date) {
    if (date.isAfter(endDatePicked)) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Alert!'),
              content: Text("Start date must be earlier than end date."),
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
      return;
    } else if (startDatePicked.isSameDate(date)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Alert!'),
            content: Text("You have selected the same date."),
            actions: [
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context, "OK");
                },
              ),
            ],
          );
        },
      );
    }
    startDatePicked = date;
    didModifyDate = true;
    filteredOrderList = orderList
        .where((order) =>
            (order.date.isAfter(date) || order.date.isSameDate(date)) &&
            (order.date.isBefore(endDatePicked) ||
                order.date.isSameDate(endDatePicked)))
        .toList();
    notifyListeners();
  }

  selectEndDate(context, date) {
    if (date.isBefore(startDatePicked)) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Alert!'),
              content: Text("End date must be later than start date."),
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
      return;
    } else if (endDatePicked.isSameDate(date)) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Alert!'),
              content: Text("You have selected the same date."),
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
    endDatePicked = date;
    didModifyDate = true;
    filteredOrderList = orderList
        .where((order) =>
            (order.date.isAfter(startDatePicked) ||
                order.date.isSameDate(startDatePicked)) &&
            (order.date.isBefore(date) || order.date.isSameDate(date)))
        .toList();
    notifyListeners();
  }

  selectPurchaseStartDate(context, date) {
    if (date.isAfter(endDatePickedInPurchaseList)) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Alert!'),
              content: Text("Start date must be earlier than end date."),
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
      return;
    } else if (startDatePickedInPurchaseList.isSameDate(date)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Alert!'),
            content: Text("You have selected the same date."),
            actions: [
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context, "OK");
                },
              ),
            ],
          );
        },
      );
    }
    startDatePickedInPurchaseList = date;
    didModifyDateInPurchaseList = true;
    filteredPurchaseList = purchaseList
        .where((purchase) =>
            (purchase.date.isAfter(date) || purchase.date.isSameDate(date)) &&
            (purchase.date.isBefore(endDatePicked) ||
                purchase.date.isSameDate(endDatePicked)))
        .toList();
    notifyListeners();
  }

  selectPurchaseEndDate(context, date) {
    if (date.isBefore(startDatePickedInPurchaseList)) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Alert!'),
              content: Text("End date must be later than start date."),
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
      return;
    } else if (endDatePickedInPurchaseList.isSameDate(date)) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Alert!'),
              content: Text("You have selected the same date."),
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
    endDatePickedInPurchaseList = date;
    didModifyDateInPurchaseList = true;
    filteredPurchaseList = purchaseList
        .where((purchase) =>
            (purchase.date.isAfter(startDatePicked) ||
                purchase.date.isSameDate(startDatePicked)) &&
            (purchase.date.isBefore(date) || purchase.date.isSameDate(date)))
        .toList();
    notifyListeners();
  }

  selectPurchaseDate(date) {
    purchaseDate = date;
    notifyListeners();
  }

  resetPurchaseDate() {
    purchaseDate = DateTime.now();
    notifyListeners();
  }

  orderUp() {
    orderNo++;
    notifyListeners();
  }

  exportOrdersAsPdf() async {
    final pdf = pw.Document();

    if (!didModifyDate) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.ListView.builder(
              itemBuilder: (context, index) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Order Number: ${orderList[index].orderNo}"),
                    pw.Text(
                        "Order Time: ${orderList[index].date.toString().split(" ")[0]} ${orderList[index].date.toString().split(" ")[1].split(".")[0]}"),
                    orderList[0].cash
                        ? pw.Column(children: [
                            pw.Text("Payment method: Cash"),
                            pw.Text("Cash Get: ${orderList[index].cashGet}"),
                          ])
                        : pw.Text("Payment method: Card"),
                    pw.Text("Sold by: Ricardo Vazquez"),
                    pw.Text("Customer: Tobi Lutke, Ottawa, Ontario"),
                    pw.Text("Item List : "),
                    orderList[index].itemList.length != 0
                        ? pw.Column(
                            children: orderList[index].itemList.map((item) {
                              return pw.Row(
                                children: [
                                  // pw.Image.provider(item.image),
                                  pw.Text(
                                      "${item.title} (\$${oCcy.format(item.price)} * ${item.itemCount}) : \$${oCcy.format(item.price * item.itemCount)} "),
                                ],
                              );
                            }).toList(),
                          )
                        : pw.Text("null"),
                    index != orderList.length - 1
                        ? pw.Divider()
                        : pw.Container(),
                  ],
                );
              },
              itemCount: orderList.length,
            );
          },
        ),
      ); // Page
    } else {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.ListView.builder(
              itemBuilder: (context, index) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                        "Order Number: ${filteredOrderList[index].orderNo}"),
                    pw.Text(
                        "Order Time: ${filteredOrderList[index].date.toString().split(" ")[0]} ${filteredOrderList[index].date.toString().split(" ")[1].split(".")[0]}"),
                    filteredOrderList[0].cash
                        ? pw.Column(children: [
                            pw.Text("Payment method: Cash"),
                            pw.Text(
                                "Cash Get: ${filteredOrderList[index].cashGet}"),
                          ])
                        : pw.Text("Payment method: Card"),
                    pw.Text("Sold by: Ricardo Vazquez"),
                    pw.Text("Customer: Tobi Lutke, Ottawa, Ontario"),
                    pw.Text("Item List : "),
                    filteredOrderList[index].itemList.length != 0
                        ? pw.Column(
                            children:
                                filteredOrderList[index].itemList.map((item) {
                              return pw.Row(
                                children: [
                                  // pw.Image.provider(item.image),
                                  pw.Text(
                                      "${item.title} (\$${oCcy.format(item.price)} * ${item.itemCount}) : \$${oCcy.format(item.price * item.itemCount)} "),
                                ],
                              );
                            }).toList(),
                          )
                        : pw.Text("null"),
                    index != filteredOrderList.length - 1
                        ? pw.Divider()
                        : pw.Container(),
                  ],
                );
              },
              itemCount: filteredOrderList.length,
            );
          },
        ),
      ); // Page
    }

    final directory = (await pp.getExternalStorageDirectory()).path;
    final file = File("$directory/orders.pdf");
    await file.writeAsBytes(pdf.save());
    final Email email = Email(
      body: 'Receipt',
      subject: 'Receipt',
      recipients: ['tedjung@ciousya.com'],
      attachmentPaths: ['$directory/orders.pdf'],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }

  exportPurchasesAsPdf() async {
    final pdf = pw.Document();

    if (!didModifyDateInPurchaseList) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.ListView.builder(
              itemBuilder: (context, index) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                        "Purchase Number: ${purchaseList[index].purchaseNo}"),
                    pw.Text(
                        "Order Time: ${purchaseList[index].date.toString().split(" ")[0]} ${purchaseList[index].date.toString().split(" ")[1].split(".")[0]}"),
                    pw.Text("Sold by: Ricardo Vazquez"),
                    pw.Text("Customer: Tobi Lutke, Ottawa, Ontario"),
                    pw.Text("Item List : "),
                    purchaseList[index].itemNames.length != 0 &&
                            purchaseList[index].prices.length != 0 &&
                            purchaseList[index].itemCounts.length != 0
                        ? pw.ListView.builder(
                            itemBuilder: (context, _index) {
                              return pw.Column(children: [
                                pw.Text(
                                    "${purchaseList[index].itemNames[_index]} (\$${oCcy.format(purchaseList[index].prices[_index])} * ${purchaseList[index].itemCounts[_index]}) : \$${oCcy.format(purchaseList[index].totalPrice)} "),
                              ]);
                            },
                            itemCount: purchaseList[index].itemNames.length,
                          )
                        : pw.Text("null"),
                    index != purchaseList.length - 1
                        ? pw.Divider()
                        : pw.Container(),
                  ],
                );
              },
              itemCount: purchaseList.length,
            );
          },
        ),
      ); // Page
    } else {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.ListView.builder(
              itemBuilder: (context, index) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                        "Purchase Number: ${filteredPurchaseList[index].purchaseNo}"),
                    pw.Text(
                        "Order Time: ${filteredPurchaseList[index].date.toString().split(" ")[0]} ${filteredPurchaseList[index].date.toString().split(" ")[1].split(".")[0]}"),
                    pw.Text("Sold by: Ricardo Vazquez"),
                    pw.Text("Customer: Tobi Lutke, Ottawa, Ontario"),
                    pw.Text("Item List : "),
                    filteredPurchaseList[index].itemNames.length != 0 &&
                            filteredPurchaseList[index].prices.length != 0 &&
                            filteredPurchaseList[index].itemCounts.length != 0
                        ? pw.ListView.builder(
                            itemBuilder: (context, _index) {
                              return pw.Column(children: [
                                pw.Text(
                                    "${filteredPurchaseList[index].itemNames[_index]} (\$${oCcy.format(filteredPurchaseList[index].prices[_index])} * ${filteredPurchaseList[index].itemCounts[_index]}) : \$${oCcy.format(filteredPurchaseList[index].totalPrice)} "),
                              ]);
                            },
                            itemCount:
                                filteredPurchaseList[index].itemNames.length,
                          )
                        : pw.Text("null"),
                    index != filteredPurchaseList.length - 1
                        ? pw.Divider()
                        : pw.Container(),
                  ],
                );
              },
              itemCount: filteredPurchaseList.length,
            );
          },
        ),
      ); // Page
    }

    final directory = (await pp.getExternalStorageDirectory()).path;
    final file = File("$directory/orders.pdf");
    await file.writeAsBytes(pdf.save());
    final Email email = Email(
      body: 'Receipt',
      subject: 'Receipt',
      recipients: ['tedjung@ciousya.com'],
      attachmentPaths: ['$directory/orders.pdf'],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }

  saveBalance() async {
    final directory = await pp.getApplicationDocumentsDirectory();
    final file = File('${directory.path}/balance.json');
    await file.writeAsString(
        '{"initialBalance":"$initialBalance","orderBalance":"$orderBalance","purchaseBalance":"$purchaseBalance","finalBalance":"$balance"}');
  }

  loadBalance() async {
    final file = File(
        '${(await pp.getApplicationDocumentsDirectory()).path}/balance.json');
    if (!file.existsSync()) return;
    String data = await file.readAsString();
    if (data == "{}") {
      initialBalance = 0.0;
      balance = 0.0;
      orderBalance = 0.0;
      purchaseBalance = 0.0;
    } else {
      final balanceData = Map.from(json.decode(data));
      initialBalance = double.parse(balanceData['initialBalance']);
      balance = double.parse(balanceData['finalBalance']);
      orderBalance = double.parse(balanceData['orderBalance']);
      purchaseBalance = double.parse(balanceData['finalBalance']);
    }
    notifyListeners();
  }

  initBalance(_bal) {
    initialBalance = double.parse(_bal);
    balance = double.parse(_bal);
    orderBalance = 0.0;
    purchaseBalance = 0.0;
    saveBalance();
    notifyListeners();
  }

  modifyBalance(_bal, add) async {
    if (add) {
      balance += _bal;
      orderBalance += _bal;
    } else {
      balance -= _bal;
      purchaseBalance += _bal;
    }
    saveBalance();
    notifyListeners();
  }

  modifyPurchaseTotal(price, add) {
    if (add) {
      purchaseTotalPrice += price;
    } else {
      purchaseTotalPrice -= price;
    }
    notifyListeners();
  }

  clearPurchaseTotal() {
    purchaseTotalPrice = 0.0;
    purchaseBasket.clear();
    notifyListeners();
  }

  removePurchaseItem(idx) {
    purchaseBasket.removeAt(idx);
    notifyListeners();
  }

  addPurchaseItem(purchase) {
    purchaseBasket.add(purchase);
    notifyListeners();
  }

  addPurchase(purchase) {
    purchaseList.add(purchase);
    purchaseNo++;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [GlobalMaterialLocalizations.delegate],
      supportedLocales: [Locale('en'), Locale('kr')],
      initialRoute: MainPage.id,
      routes: {
        StartingPage.id: (context) => StartingPage(),
        MainPage.id: (context) => MainPage(),
      },
    );
  }
}
