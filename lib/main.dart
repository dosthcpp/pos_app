import 'package:flutter/material.dart';
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
import 'init_page.dart';

final OrderProvider orderProvider = OrderProvider();

void main() async {
  runApp(
    ChangeNotifierProvider<OrderProvider>(
      create: (context) => orderProvider,
      child: MyApp(),
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

  initDate() {
    DateTime now = DateTime.now();
    startDatePicked = DateTime(now.year, now.month, now.day, 0, 0, 0);
    endDatePicked = DateTime(now.year, now.month, now.day, 23, 59, 59);
    didModifyDate = false;
  }

  addList(item, _price) {
    final found = orderProvider.itemList
        .where((_item) => _item.title.toLowerCase().contains(item.title))
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
    print(_price);
    price -= _price;
    notifyListeners();
  }

  addOrder(order) {
    orders.add(order);
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
        InitPage.id: (context) => InitPage(),
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
