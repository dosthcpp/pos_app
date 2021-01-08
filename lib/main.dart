import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:pos_app/main_page.dart';
import 'package:pos_app/startingPage.dart';
import 'package:pos_app/storePage/apps.dart';
import 'package:pos_app/storePage/hardware.dart';
import 'package:pos_app/storePage/location.dart';
import 'package:pos_app/storePage/payment.dart';
import 'package:pos_app/storePage/settings.dart';
import 'package:pos_app/storePage/tips.dart';
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
  // 장바구니
  List<ItemList> itemList = [];

  // 오더리스트
  List<Order> orders = [];
  List<Order> filteredOrder = [];

  double price = 0.0;
  int orderNo = 1001;

  DateTime startDatePicked;
  DateTime endDatePicked;
  bool didModifyDate = false;

  deleteAndReset() async {
    resetDocument();
    loadData(null);
    initDate();
    reset();
  }

  resetDocument() async {
    final directory = await pp.getApplicationDocumentsDirectory();
    final file = File('${directory.path}/orders.json');
    final file2 = File('${directory.path}/product.json');
    await file.delete();
    await file2.delete();
    await file.writeAsString('[{}]');
    await file2.writeAsString('[{}]');
  }

  reset() {
    orders.clear();
    filteredOrder.clear();
    itemList.clear();
    orderNo = 1001;
    notifyListeners();
  }

  initDate() {
    DateTime now = DateTime.now();
    startDatePicked = DateTime(now.year, now.month, now.day, 0, 0, 0);
    endDatePicked = DateTime(now.year, now.month, now.day, 23, 59, 59);
    didModifyDate = false;
  }

  loadData(functionSnapshot) async {
    Future.delayed(Duration.zero, () async{
      final file = File(
          '${(await pp.getApplicationDocumentsDirectory()).path}/orders.json');
      if(!file.existsSync()) return;
      String data = await file.readAsString();
      List<dynamic> jsonResult = json.decode(data);
      if (data == "[{}]" && jsonResult[0].length == 0) {
        orders = [];
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
          orders.add(
            Order(
              functionSnapshot[functionSnapshotIdx++],
              date: DateTime.parse(item['date']),
              totalPrice: item['totalPrice'],
              itemList: _itemList.toList(),
              orderNo: item['orderNo'],
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

  refresh(base64EncodedMap) async {
    String jsonString = "["
        "{";
    if (orders.length == 0) {
      jsonString += "}]";
    } else {
      for (var i = 0; i < orders.length; ++i) {
        jsonString +=
        '"orderNo": "${orders.elementAt(i).orderNo}", "date": "${orders.elementAt(i).date}", "totalPrice": "${orders.elementAt(i).totalPrice}", "cash": "${orders.elementAt(i).cash}", "cashGet": "${orders.elementAt(i).cashGet}", "promotion": "${orders.elementAt(i).promotion}",';
        jsonString += '"itemList": [';
        for (var j = 0; j < orders.elementAt(i).itemList.length; ++j) {
          jsonString +=
          '{"image":"${base64EncodedMap[orders.elementAt(i).itemList[j].title]}", "title":"${orders.elementAt(i).itemList[j].title}", "price":"${orders.elementAt(i).itemList[j].price}", "itemCount":"${orders.elementAt(i).itemList[j].itemCount}"}';
          if (j != orders.elementAt(i).itemList.length - 1) {
            jsonString += ',';
          }
        }
        jsonString += ']}';
        if (i != orders.length - 1) {
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
    orders.add(order);
    // TODO: json 저장
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
          });
    }
    startDatePicked = date;
    didModifyDate = true;
    filteredOrder = orders
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
    filteredOrder = orders
        .where((order) =>
            (order.date.isAfter(startDatePicked) ||
                order.date.isSameDate(startDatePicked)) &&
            (order.date.isBefore(date) || order.date.isSameDate(date)))
        .toList();
    print(date);
    notifyListeners();
  }

  orderUp() {
    orderNo++;
    notifyListeners();
  }

  exportAsPdf() async {
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
                    pw.Text("Order Number: ${orders[index].orderNo}"),
                    pw.Text(
                        "Order Time: ${orders[index].date.toString().split(" ")[0]} ${orders[index].date.toString().split(" ")[1].split(".")[0]}"),
                    orders[0].cash
                        ? pw.Column(children: [
                            pw.Text("Payment method: Cash"),
                            pw.Text("Cash Get: ${orders[index].cashGet}"),
                          ])
                        : pw.Text("Payment method: Card"),
                    pw.Text("Sold by: Ricardo Vazquez"),
                    pw.Text("Customer: Tobi Lutke, Ottawa, Ontario"),
                    pw.Text("Item List : "),
                    orders[index].itemList.length != 0
                        ? pw.Column(
                            children: orders[index].itemList.map((item) {
                              return pw.Row(
                                children: [
                                  // pw.Image.provider(item.image),
                                  pw.Text(
                                      "${item.title} (\$${item.price}0 * ${item.itemCount}) : ${item.price * item.itemCount}0 "),
                                ],
                              );
                            }).toList(),
                          )
                        : pw.Text("null"),
                    index != orders.length - 1 ? pw.Divider() : pw.Container(),
                  ],
                );
              },
              itemCount: orders.length,
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
                    pw.Text("Order Number: ${filteredOrder[index].orderNo}"),
                    pw.Text(
                        "Order Time: ${filteredOrder[index].date.toString().split(" ")[0]} ${filteredOrder[index].date.toString().split(" ")[1].split(".")[0]}"),
                    filteredOrder[0].cash
                        ? pw.Column(children: [
                            pw.Text("Payment method: Cash"),
                            pw.Text(
                                "Cash Get: ${filteredOrder[index].cashGet}"),
                          ])
                        : pw.Text("Payment method: Card"),
                    pw.Text("Sold by: Ricardo Vazquez"),
                    pw.Text("Customer: Tobi Lutke, Ottawa, Ontario"),
                    pw.Text("Item List : "),
                    filteredOrder[index].itemList.length != 0
                        ? pw.Column(
                            children: filteredOrder[index].itemList.map((item) {
                              return pw.Row(
                                children: [
                                  // pw.Image.provider(item.image),
                                  pw.Text(
                                      "${item.title} (\$${item.price}0 * ${item.itemCount}) : ${item.price * item.itemCount}0 "),
                                ],
                              );
                            }).toList(),
                          )
                        : pw.Text("null"),
                    index != filteredOrder.length - 1
                        ? pw.Divider()
                        : pw.Container(),
                  ],
                );
              },
              itemCount: filteredOrder.length,
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
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [GlobalMaterialLocalizations.delegate],
      supportedLocales: [Locale('en'), Locale('kr')],
      initialRoute: StartingPage.id,
      routes: {
        StartingPage.id: (context) => StartingPage(),
        MainPage.id: (context) => MainPage(),
        Hardware.id: (context) => Hardware(),
        ConnectCardReader.id: (context) => ConnectCardReader(),
        ScanCode.id: (context) => ScanCode(),
        DummyPage.id: (context) => DummyPage(),
        Location.id: (context) => Location(),
        Payment.id: (context) => Payment(),
        Apps.id: (context) => Apps(),
        Tips.id: (context) => Tips(),
        Settings.id: (context) => Settings(),
      },
    );
  }
}
