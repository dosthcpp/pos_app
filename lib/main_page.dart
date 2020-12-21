import 'dart:io' show File;
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:pos_app/addCustomer.dart';
import 'package:pos_app/addInventory.dart';
import 'package:pos_app/addProduct.dart';
import 'package:pos_app/orderPage.dart';
import 'package:pos_app/paymentPage.dart';
import 'package:pos_app/payment_result.dart';
import 'package:pos_app/quickSale.dart';
import 'package:pos_app/storePage/apps.dart';
import 'package:pos_app/storePage/hardware.dart';
import 'package:pos_app/storePage/location.dart';
import 'package:pos_app/storePage/payment.dart';
import 'package:pos_app/storePage/settings.dart';
import 'package:pos_app/storePage/support.dart';
import 'package:pos_app/storePage/tips.dart';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tutorial_coach_mark/animated_focus_light.dart';
import 'package:tutorial_coach_mark/custom_target_position.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

// RenderRepaintBoundary boundary =
// scr.currentContext
//     .findRenderObject();
// final directory = (await pp.getApplicationDocumentsDirectory()).path;
// var image =
// await boundary.toImage();
// var byteData =
// await image.toByteData(
//     format:
//     ImageByteFormat.png);
// var pngBytes =
// byteData.buffer.asUint8List();
// print(pngBytes);
// File imgFile = File('$directory/screenshot.png');
// print(directory);
// imgFile.writeAsBytes(pngBytes);
// final RenderBox box =
// keys[index].currentContext.findRenderObject();
//
// final position =
// box.getTransformTo(null).getTranslation();
// final topLeft = {position.x, position.y};
// final topRight = {
//   position.x + box.size.width,
//   position.y
// };
// final bottomLeft = {
//   position.x,
//   position.y + box.size.height
// };
// final bottomRight = {
//   position.x + box.size.width,
//   position.y + box.size.height
// };
// print(topLeft);
// print(topRight);
// print(bottomLeft);
// print(bottomRight);

class MainPage extends StatefulWidget {
  static const id = 'main_page';

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  static int index = 0;
  int drawerIndex = 0;
  int cur = 1;
  int mainCur = 1;
  double price = 46.0;
  final itemLength = 20;
  bool searchMode = false;
  bool willShowReceipt = false;
  bool isMainMenu = true;

  List<String> itemNames = [];
  List<String> itemImages = [];
  List<int> hashedIdx = [];
  List<GlobalKey> keys = [];

  final fn = FocusNode();

  // final scr = GlobalKey();

  TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = List();
  final productsGrid = GlobalKey();
  final subTotalButton = GlobalKey();
  final paymentButton = PaymentPage.paymentButton;
  final printReceiptKey = PaymentResult.printReceiptKey;
  final salesPage = _CheckoutPage.salesPage;

  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice _device;
  bool _connected = false;
  bool _pressed = false;
  String pathImage;

  @override
  void initState() {
    for (int i = 0; i < itemLength; ++i) {
      itemNames.add('itemName$i');
    }
    for (int i = 0; i < itemLength; ++i) {
      itemImages.add('assets/product/random$i.png');
    }
    for (int i = 0; i < itemLength; ++i) {
      hashedIdx.add(i);
    }
    for (int i = 0; i < itemLength; ++i) {
      keys.add(GlobalKey());
    }
    initPlatformState();
    initTargets();
  }

  void showTutorial() {
    setState(() {
      index = 0;
      isMainMenu = true;
    });
    tutorialCoachMark = TutorialCoachMark(context,
        targets: targets,
        colorShadow: Colors.red,
        textSkip: "SKIP",
        paddingFocus: 10,
        opacityShadow: 0.8, onFinish: () {
      _printReceipt();
      setState(() {
        index = 0;
        isMainMenu = true;
      });
    }, onClickTarget: (target) {
      if (target.keyTarget == subTotalButton?.currentWidget?.key) {
        setState(() {
          index = 19;
          isMainMenu = false;
        });
      } else if (target.keyTarget == paymentButton?.currentWidget?.key) {
        setState(() {
          index = 20;
        });
      }
    }, onClickSkip: () {
      print("skip");
    })
      ..show();
  }

  void initTargets() {
    Future.delayed(Duration.zero, () {
      double width = MediaQuery.of(context).size.width;
      targets.add(
        TargetFocus(
          identify: "Target 1",
          keyTarget: productsGrid,
          color: Colors.purple,
          contents: [
            ContentTarget(
              align: AlignContent.custom,
              customPosition: CustomTargetPosition(
                bottom: 50,
                left: width / 3 * 2 + 10,
              ),
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Adding products",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "You can add some products by simply clicking these\nproducts.",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
          shape: ShapeLightFocus.RRect,
          radius: 5,
        ),
      );
      targets.add(
        TargetFocus(
          identify: "Target 2",
          keyTarget: salesPage,
          color: Colors.purple,
          contents: [
            ContentTarget(
              align: AlignContent.bottom,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Products list",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "These are products list.",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
          shape: ShapeLightFocus.RRect,
          radius: 5,
        ),
      );
      targets.add(
        TargetFocus(
          identify: "Target 3",
          keyTarget: subTotalButton,
          color: Colors.purple,
          contents: [
            ContentTarget(
              align: AlignContent.custom,
              customPosition: CustomTargetPosition(
                bottom: 0,
                left: 0,
              ),
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Click ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "You can add some products by simply clicking these\nproducts.",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
          shape: ShapeLightFocus.RRect,
          radius: 5,
        ),
      );
      targets.add(
        TargetFocus(
          identify: "Target 4",
          keyTarget: paymentButton,
          color: Colors.purple,
          contents: [
            ContentTarget(
              align: AlignContent.custom,
              customPosition: CustomTargetPosition(
                bottom: 0,
                left: 0,
              ),
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Payment methods",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "These are payments methods. You can ",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
          shape: ShapeLightFocus.RRect,
          radius: 5,
        ),
      );
      targets.add(
        TargetFocus(
          identify: "Target 5",
          keyTarget: printReceiptKey,
          color: Colors.purple,
          contents: [
            ContentTarget(
              align: AlignContent.custom,
              customPosition: CustomTargetPosition(
                bottom: 0,
                left: 0,
              ),
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Payment methods",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "These are payments methods. You can ",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
          shape: ShapeLightFocus.RRect,
          radius: 5,
        ),
      );
    });
  }

  Future<void> initPlatformState() async {
    List<BluetoothDevice> devices = [];

    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      // TODO - Error
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
            _pressed = false;
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
            _pressed = false;
          });
          break;
        default:
          print(state);
          break;
      }
    });

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });
  }

  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  void _connect() {
    if (_device == null) {
      show('No device selected.');
    } else {
      bluetooth.isConnected.then((isConnected) {
        if (!isConnected) {
          bluetooth.connect(_device).catchError((error) {
            setState(() => _pressed = false);
          });
          setState(() => _pressed = true);
        }
      });
    }
  }

  void _disconnect() {
    bluetooth.disconnect();
    setState(() => _pressed = true);
  }

  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(Duration(milliseconds: 100));
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        duration: duration,
      ),
    );
  }

  void _testPrint() async {
    bluetooth.isConnected.then((isConnected) {
      if (isConnected) {
        bluetooth.printCustom("GBAIN INNOVATION", 3, 1);
        bluetooth.printNewLine();
        bluetooth.printCustom("RECEIPT", 3, 1);
        bluetooth.printLeftRight("Address:", "", 0);
        bluetooth.printLeftRight("[POS 01]",
            DateTime.now().toString().split(' ')[1].split('.')[0], 1);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printLeftRight("Item name / PPU /", "# / Total price", 1);
        bluetooth.printLeftRight("A Mug cup \$6.99", "1 \$6.99", 1);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printLeftRight("Subtotal", "\$6.99", 1);
        bluetooth.printLeftRight("Net Amount", "\$6.99", 1);
        bluetooth.printLeftRight("Tax", "\$0.99", 1);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printLeftRight("Total", "\$0.99", 1);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printLeftRight("Promotion", "\$4.99", 1);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printLeftRight("Card", "MasterCard", 1);
        bluetooth.printLeftRight("Membership No. :", "96641334156***", 1);
        bluetooth.printCustom("Card Approval No. :", 1, 0);
        bluetooth.printCustom("20201120112005123", 1, 2);
        bluetooth.printLeftRight("Affiliate No. :", "3230", 1);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printLeftRight("Membership Credit", "\$0.99", 1);
        bluetooth.printLeftRight("Membership Card", "*********6912", 1);
        bluetooth.printCustom("Approval No : 577145", 1, 1);
        bluetooth.printCustom("Balance: \$0.00", 1, 1);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printCustom(
            "Please Charge your card since your balance is \$0.00", 0, 0);
        bluetooth.printCustom("My reward (GB29**)", 0, 0);
        bluetooth.printCustom("My coupon No : 1590230415049", 0, 0);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printLeftRight("Cash :", "\$2.00", 1);
        bluetooth.printLeftRight("Charge due :", "\$0.00", 1);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.paperCut();
      }
    });
  }

  void _printReceipt() async {
    bluetooth.isConnected.then(
      (isConnected) {
        if (isConnected) {
          bluetooth.printCustom("GBAIN INNOVATION", 3, 1);
          bluetooth.printNewLine();
          bluetooth.printCustom("RECEIPT", 3, 1);
          bluetooth.printLeftRight("Address:", "", 0);
          bluetooth.printLeftRight("[POS 01]",
              DateTime.now().toString().split(' ')[1].split('.')[0], 1);
          bluetooth.printCustom("----------------------------", 1, 1);
          bluetooth.printLeftRight("Item name / PPU /", "# / Total price", 1);
          _CheckoutPage.listItem.forEach((el) {
            bluetooth.printLeftRight(
                "${el.title} \$${el.price}", "1 \$${el.price}", 1);
          });
          bluetooth.printCustom("----------------------------", 1, 1);
          bluetooth.printLeftRight("Subtotal", "\$$price", 1);
          bluetooth.printLeftRight("Net Amount", "\$$price", 1);
          bluetooth.printLeftRight("Tax", "\$${price / 10}", 1);
          bluetooth.printCustom("----------------------------", 1, 1);
          bluetooth.printLeftRight("Total", "\$$price", 1);
          bluetooth.printCustom("----------------------------", 1, 1);
          bluetooth.printLeftRight("Promotion", "\$20.0", 1);
          bluetooth.printCustom("----------------------------", 1, 1);
          bluetooth.printLeftRight("Card", "MasterCard", 1);
          bluetooth.printLeftRight("Membership No. :", "96641334156***", 1);
          bluetooth.printCustom("Card Approval No. :", 1, 0);
          bluetooth.printCustom("20201120112005123", 1, 2);
          bluetooth.printLeftRight("Affiliate No. :", "3230", 1);
          bluetooth.printCustom("----------------------------", 1, 1);
          bluetooth.printLeftRight("Membership Credit", "\$$price", 1);
          bluetooth.printLeftRight("Membership Card", "*********6912", 1);
          bluetooth.printCustom("Approval No : 577145", 1, 1);
          bluetooth.printCustom("Balance: \$0.00", 1, 1);
          bluetooth.printCustom("----------------------------", 1, 1);
          bluetooth.printCustom(
              "Please Charge your card since your balance is \$0.00", 0, 0);
          bluetooth.printCustom("My reward (GB29**)", 0, 0);
          bluetooth.printCustom("My coupon No : 755F47HB2B7A98C9", 0, 0);
          bluetooth.printCustom("----------------------------", 1, 1);
          bluetooth.printLeftRight("Cash :", "\$0.00", 1);
          bluetooth.printLeftRight("Charge due :", "\$0.00", 1);
          bluetooth.printNewLine();
          bluetooth.printNewLine();
          bluetooth.paperCut();
        }
      },
    );
  }

  void _printReceiptOnOrderPage() async {
    bluetooth.isConnected.then((isConnected) {
      if (isConnected) {
        bluetooth.printCustom("GBAIN INNOVATION", 3, 1);
        bluetooth.printNewLine();
        bluetooth.printCustom("RECEIPT", 3, 1);
        bluetooth.printLeftRight("Address:", "", 0);
        bluetooth.printLeftRight("[POS 01]",
            DateTime.now().toString().split(' ')[1].split('.')[0], 1);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printLeftRight("Item name / PPU /", "# / Total price", 1);
        bluetooth.printLeftRight("Walnut Planter \$61.6", "3 \$61.60", 1);
        bluetooth.printLeftRight("Mug cup \$24.25", "1 \$24.25", 1);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printLeftRight("Subtotal", "\$209.05", 1);
        bluetooth.printLeftRight("Net Amount", "\$209.05", 1);
        bluetooth.printLeftRight("Tax", "\$20.90", 1);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printLeftRight("Total", "\$209.05", 1);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printLeftRight("Promotion", "\$0.00", 1);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printLeftRight("Card", "MasterCard", 1);
        bluetooth.printLeftRight("Membership No. :", "96641334156***", 1);
        bluetooth.printCustom("Card Approval No. :", 1, 0);
        bluetooth.printCustom("20201120112005123", 1, 2);
        bluetooth.printLeftRight("Affiliate No. :", "3230", 1);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printLeftRight("Membership Credit", "\$209.05", 1);
        bluetooth.printLeftRight("Membership Card", "*********6912", 1);
        bluetooth.printCustom("Approval No : 577145", 1, 1);
        bluetooth.printCustom("Balance: \$0.00", 1, 1);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printCustom(
            "Please Charge your card since your balance is \$0.00", 0, 0);
        bluetooth.printCustom("My reward (GB29**)", 0, 0);
        bluetooth.printCustom("My coupon No : 1590230415049", 0, 0);
        bluetooth.printCustom("----------------------------", 1, 1);
        bluetooth.printLeftRight("Cash :", "\$0.00", 1);
        bluetooth.printLeftRight("Charge due :", "\$0.00", 1);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.paperCut();
      }
    });
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devices.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devices.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }

  String renderTitle() {
    switch (index) {
      case 3:
        return "Stock Existing Inventory";
      case 4:
        return "Add product";
      case 5:
        return "Add customer";
      case 6:
        return "Quick Sale";
      case 7:
        return "Hardware";
      case 8:
        return "Locations";
      case 9:
        return "Payment Types";
      case 10:
        return "Apps";
      case 11:
        return "Tips";
      case 12:
        return "Settings";
      case 13:
        return "Support";
      case 14:
        return "Get Gabin Mobile";
      case 15:
        return "Connect POS printer";
      case 16:
        return "Scan Code";
      case 17:
        return "Purchase pos printer";
      case 18:
        return "Order #1001";
      case 19:
        return "Select Payment";
      case 20:
        return "Order complete";
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Scaffold(
                drawer: Drawer(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      SizedBox(
                        height: 150.0,
                        child: DrawerHeader(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Administrator',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18.0),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  "POS 1",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16.0),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  "Gabin",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16.0),
                                )
                              ],
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple,
                          ),
                        ),
                      ),
                      ListTile(
                        title: MaterialButton(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/shopping-cart.png',
                                  width: 20.0,
                                ),
                                SizedBox(
                                  width: 20.0,
                                ),
                                Text(
                                  "Purchase",
                                ),
                              ],
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              drawerIndex = 0;
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      ListTile(
                        title: MaterialButton(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/receipt.png',
                                  width: 20.0,
                                ),
                                SizedBox(
                                  width: 20.0,
                                ),
                                Text(
                                  "Receipt",
                                ),
                              ],
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              print("asdf");
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      ListTile(
                        title: MaterialButton(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/products.png',
                                  width: 20.0,
                                ),
                                SizedBox(
                                  width: 20.0,
                                ),
                                Text(
                                  "Products",
                                ),
                              ],
                            ),
                          ),
                          onPressed: () {},
                        ),
                      ),
                      ListTile(
                        title: MaterialButton(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/settings.png',
                                  width: 20.0,
                                ),
                                SizedBox(
                                  width: 20.0,
                                ),
                                Text(
                                  "Settings",
                                ),
                              ],
                            ),
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(40.0),
                  child: AppBar(
                    automaticallyImplyLeading: false,
                    title: Container(
                      width: 150.0,
                      child: Text(
                        "All products",
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    // title: Transform(
                    //   transform: Matrix4.translationValues(-30, 0, 0),
                    //   child: Row(
                    //     children: [
                    //       Builder(
                    //         builder: (context) => MaterialButton(
                    //           child: Icon(
                    //             Icons.menu,
                    //           ),
                    //           onPressed: () {
                    //             Scaffold.of(context).openDrawer();
                    //           },
                    //         ),
                    //       ),
                    //       drawerIndex == 0
                    //           ?
                    //           : Container()
                    //     ],
                    //   ),
                    // ),
                    backgroundColor: Colors.white,
                  ),
                ),
                body: CustomScrollView(
                  key: productsGrid,
                  slivers: [
                    Container(
                      child: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          childAspectRatio: 1.0,
                          mainAxisSpacing: 10.0,
                          crossAxisSpacing: 10.0,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return GestureDetector(
                              child: Container(
                                color: Colors.grey[200],
                                width: 80,
                                child: Center(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                      itemImages[index],
                                    ),
                                  ),
                                ),
                              ),
                              onTap: () {
                                var rng = Random();
                                var _price =
                                    50.toDouble() + rng.nextInt(150).toDouble();
                                setState(
                                  () {
                                    _CheckoutPage.listItem.add(
                                      _ListItem(
                                        imageUrl: itemImages[index],
                                        title: itemNames[index],
                                        price: _price,
                                      ),
                                    );
                                    price += _price;

                                    itemNames.removeWhere(
                                      (el) => (int.parse(
                                              el.substring(8, el.length)) ==
                                          hashedIdx[index]),
                                    );
                                    itemImages.removeWhere((el) =>
                                        int.parse(el.split('/')[2].substring(
                                            6, el.split('/')[2].length - 4)) ==
                                        hashedIdx[index]);
                                    hashedIdx.removeWhere((el) => el == index);
                                  },
                                );
                              },
                            );
                          },
                          childCount: itemNames.length,
                        ),
                      ),
                    ),
                  ],
                )
                // bottomNavigationBar: BottomNavigationBar(),
                ),
          ),
          Expanded(
            flex: 1,
            child: Scaffold(
              resizeToAvoidBottomPadding: false,
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(40.0),
                child: AppBar(
                  backgroundColor: Colors.white,
                  elevation: 10.0,
                  automaticallyImplyLeading: false,
                  leading: searchMode
                      ? GestureDetector(
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.deepPurpleAccent,
                          ),
                          onTap: () {
                            setState(() {
                              searchMode = false;
                            });
                          },
                        )
                      : null,
                  actions: searchMode
                      ? null
                      : [
                          index == 0
                              ? SizedBox(
                                  width: 30.0,
                                  height: 40.0,
                                  child: PopupMenuButton(
                                    onSelected: (value) {
                                      switch (value) {
                                        case 1:
                                          setState(() {
                                            index = 3;
                                            isMainMenu = false;
                                          });
                                          break;
                                        case 2:
                                          setState(() {
                                            index = 4;
                                            isMainMenu = false;
                                          });
                                          break;
                                        case 3:
                                          setState(() {
                                            index = 5;
                                            isMainMenu = false;
                                          });
                                          break;
                                        default:
                                          break;
                                      }
                                    },
                                    icon: Icon(
                                      Icons.add,
                                      color: Colors.purpleAccent,
                                    ),
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 0,
                                        child: Text(
                                          "Actions",
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                        enabled: false,
                                      ),
                                      PopupMenuItem(
                                        value: 1,
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              'assets/packages.png',
                                              width: 20.0,
                                            ),
                                            Text("Stock existing inventory"),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 2,
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              'assets/product.png',
                                              width: 20.0,
                                            ),
                                            Text("Add product"),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 3,
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              'assets/user.png',
                                              width: 20.0,
                                            ),
                                            Text("Add customer"),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox(),
                          index == 0
                              ? Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 5.0,
                                        vertical: 15.0,
                                      ),
                                      child: Transform(
                                        transform:
                                            Matrix4.translationValues(3, -7, 0),
                                        child: GestureDetector(
                                          child: FaIcon(
                                            FontAwesomeIcons.barcode,
                                            color: Colors.purpleAccent,
                                          ),
                                          onTap: () async {
                                            await ImagePicker().getImage(
                                              source: ImageSource.camera,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                      ),
                                      child: GestureDetector(
                                        child: Icon(
                                          Icons.search,
                                          color: Colors.purpleAccent,
                                        ),
                                        onTap: () {
                                          setState(() {
                                            searchMode = true;
                                            fn.requestFocus();
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                        ],
                  title: index == 0
                      ? searchMode
                          ? TextField(
                              focusNode: fn,
                              decoration: InputDecoration(
                                hintText: "Search all products",
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                              ),
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 150.0,
                                  child: Container(
                                    width: 150.0,
                                    child: Text(
                                      "All products",
                                      style: TextStyle(
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                      : index == 1
                          ? Transform(
                              transform: Matrix4.translationValues(-20, 0, 0),
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 15.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Orders",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    Text(
                                      "Address not available",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12.0),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : index == 2
                              ? Transform(
                                  transform:
                                      Matrix4.translationValues(-20, 0, 0),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: 15.0,
                                    ),
                                    child: Text(
                                      "Store",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18.0,
                                      ),
                                    ),
                                  ),
                                )
                              : Transform(
                                  transform:
                                      Matrix4.translationValues(-20, 0, 0),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: 15.0,
                                    ),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          child: Icon(
                                            Icons.arrow_back_ios_outlined,
                                            color: Colors.black54,
                                          ),
                                          onTap: () {
                                            setState(() {
                                              isMainMenu = true;
                                              if (index >= 3 && index <= 6 ||
                                                  index == 19) {
                                                index = 0;
                                              } else if (index >= 7 &&
                                                  index <= 14) {
                                                index = 2;
                                              } else if (index >= 15 &&
                                                  index <= 17) {
                                                index = 7;
                                              } else if (index == 18) {
                                                index = 1;
                                              } else if (index == 20) {
                                                index = 19;
                                              }
                                            });
                                          },
                                        ),
                                        SizedBox(
                                          width: 10.0,
                                        ),
                                        Text(
                                          renderTitle(),
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                ),
              ),
              body: searchMode
                  ? null
                  : Stack(
                      children: <Widget>[
                        Offstage(
                          offstage: index != 0,
                          child: TickerMode(
                            enabled: index == 0,
                            child: _CheckoutPage(
                              callback: () {
                                setState(
                                  () {
                                    index = 6;
                                    isMainMenu = false;
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        Offstage(
                          offstage: index != 1,
                          child: TickerMode(
                            enabled: index == 1,
                            child: _OrderList(() {
                              setState(() {
                                index = 18;
                                isMainMenu = false;
                              });
                            }),
                          ),
                        ),
                        Offstage(
                          offstage: index != 2,
                          child: TickerMode(
                            enabled: index == 2,
                            child: _StorePage(callback: (idx) {
                              setState(() {
                                index = idx + 7;
                                isMainMenu = false;
                              });
                            }),
                          ),
                        ),

                        // Checkout Page -> index = 0
                        Offstage(
                          offstage: index != 3,
                          child: TickerMode(
                            enabled: index == 3,
                            child: AddInventory(),
                          ),
                        ),
                        Offstage(
                          offstage: index != 4,
                          child: TickerMode(
                            enabled: index == 4,
                            child: AddProduct(),
                          ),
                        ),
                        Offstage(
                          offstage: index != 5,
                          child: TickerMode(
                            enabled: index == 5,
                            child: AddCustomer(),
                          ),
                        ),
                        Offstage(
                          offstage: index != 6,
                          child: TickerMode(
                            enabled: index == 6,
                            child: QuickSale(),
                          ),
                        ),

                        // SETTINGS -> index = 2
                        Offstage(
                          offstage: index != 7,
                          child: TickerMode(
                            enabled: index == 7,
                            child: Hardware(
                              callback: (idx) {
                                setState(() {
                                  index = idx + 15;
                                  isMainMenu = false;
                                });
                              },
                            ),
                          ),
                        ),
                        Offstage(
                          offstage: index != 8,
                          child: TickerMode(
                            enabled: index == 8,
                            child: Location(),
                          ),
                        ),
                        Offstage(
                          offstage: index != 9,
                          child: TickerMode(
                            enabled: index == 9,
                            child: Payment(),
                          ),
                        ),
                        Offstage(
                          offstage: index != 10,
                          child: TickerMode(
                            enabled: index == 10,
                            child: Apps(),
                          ),
                        ),
                        Offstage(
                          offstage: index != 11,
                          child: TickerMode(
                            enabled: index == 11,
                            child: Tips(),
                          ),
                        ),
                        Offstage(
                          offstage: index != 12,
                          child: TickerMode(
                            enabled: index == 12,
                            child: Settings(),
                          ),
                        ),
                        Offstage(
                          offstage: index != 13,
                          child: TickerMode(
                            enabled: index == 13,
                            child: Support(() async {
                              _connected
                                  ? showTutorial()
                                  : await showDialog(
                                      context: context,
                                      barrierDismissible:
                                          false, // user must tap button!
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                              'POS printer is not connected'),
                                          content: Text(
                                              "You can simply bond your pos printer by visiting hardware page."),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text('OK'),
                                              onPressed: () {
                                                Navigator.pop(context, "OK");
                                              },
                                            ),
                                            FlatButton(
                                              child: Text('Cancel'),
                                              onPressed: () {
                                                Navigator.pop(
                                                    context, "Cancel");
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                            }),
                          ),
                        ),
                        Offstage(
                          offstage: index != 14,
                          child: TickerMode(
                            enabled: index == 14,
                            child: SizedBox(),
                          ),
                        ),

                        // Hardware subpage -> index = 7
                        Offstage(
                          offstage: index != 15,
                          child: TickerMode(
                            enabled: index == 15,
                            child: ConnectCardReader(
                              bluetoothConnection: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  DropdownButton(
                                    items: _getDeviceItems(),
                                    onChanged: (value) =>
                                        setState(() => _device = value),
                                    value: _device,
                                  ),
                                  RaisedButton(
                                    onPressed: _pressed
                                        ? null
                                        : _connected
                                            ? _disconnect
                                            : _connect,
                                    child: Text(
                                        _connected ? 'Disconnect' : 'Connect'),
                                  ),
                                  MaterialButton(
                                    child: Text("Test print"),
                                    onPressed: () => _testPrint(),
                                  ),
                                ],
                              ),
                              isConnected: _connected,
                            ),
                          ),
                        ),
                        Offstage(
                          offstage: index != 16,
                          child: TickerMode(
                            enabled: index == 16,
                            child: ScanCode(),
                          ),
                        ),
                        Offstage(
                          offstage: index != 17,
                          child: TickerMode(
                            enabled: index == 17,
                            child: DummyPage(),
                          ),
                        ),

                        // Order page -> index = 1
                        Offstage(
                          offstage: index != 18,
                          child: TickerMode(
                            enabled: index == 18,
                            child: OrderPage(() {
                              _printReceiptOnOrderPage();
                            }),
                          ),
                        ),

                        // Payment Page
                        Offstage(
                          offstage: index != 19,
                          child: TickerMode(
                            enabled: index == 19,
                            child: PaymentPage(
                              () {
                                setState(() {
                                  index = 20;
                                  isMainMenu = false;
                                });
                              },
                              price: price,
                            ),
                          ),
                        ),
                        Offstage(
                          offstage: index != 20,
                          child: TickerMode(
                            enabled: index == 20,
                            child: PaymentResult(() => _printReceipt(), () {
                              setState(() {
                                index = 0;
                                isMainMenu = true;
                              });
                            }, price),
                          ),
                        )
                      ],
                    ),
              floatingActionButton: index == 0
                  ? Container(
                      key: subTotalButton,
                      height: 50.0,
                      width: 330,
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          setState(() {
                            index = 19;
                            isMainMenu = false;
                          });
                        },
                        backgroundColor: Colors.deepPurpleAccent,
                        label: IntrinsicHeight(
                          child: Row(
                            children: <Widget>[
                              Transform(
                                transform:
                                    Matrix4.translationValues(-10.0, 0, 0),
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      "3",
                                      style: TextStyle(
                                        fontSize: 18.0,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20.0,
                                    ),
                                    Container(
                                      height: 50.0,
                                      child: VerticalDivider(
                                        thickness: 2.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 30.0,
                              ),
                              Center(
                                child: Text(
                                  "SUBTOTAL \$${price}0",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        shape: RoundedRectangleBorder(),
                      ),
                    )
                  : null,
              bottomNavigationBar: Visibility(
                visible: isMainMenu,
                child: BottomNavigationBar(
                  selectedItemColor: Colors.deepPurpleAccent,
                  onTap: (idx) {
                    setState(() {
                      index = idx;
                    });
                  },
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(Icons.shopping_cart),
                      title: Text(
                        'Checkout',
                      ),
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.card_travel),
                      title: Text(
                        'Orders',
                      ),
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.store),
                      title: Text(
                        'Store',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final Function callback;

  _OrderList(this.callback);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: 10.0,
            bottom: 10.0,
            left: 10.0,
          ),
          child: Text("November 3, 2020"),
        ),
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 1.0,
                )
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 10.0,
              ),
              child: Column(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(minHeight: 80.0),
                    child: MaterialButton(
                      padding: EdgeInsets.all(0),
                      onPressed: callback,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("#1001"),
                          Column(
                            children: [
                              Text(
                                "9:24AM",
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                "\$240",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CheckoutPage extends StatelessWidget {
  final Function callback;
  static final salesPage = GlobalKey();

  _CheckoutPage({this.callback});

  static List listItem = [
    _ListItem(
      title: 'Mug Cup',
      imageUrl: 'assets/cup.jpeg',
      price: 6.99,
    ),
    _ListItem(
      title: 'Chair',
      imageUrl: 'assets/chair.jpg',
      price: 21.99,
    ),
    _ListItem(
      title: 'napkin 1 pack',
      imageUrl: 'assets/napkin.jpeg',
      price: 1.99,
    ),
    _ListItem(
      title: 'notebooks',
      imageUrl: 'assets/notebooks.jpg',
      price: 2.99,
    ),
    _ListItem(
      title: 'tumbler cup',
      imageUrl: 'assets/tumbler.jpg',
      price: 4.99,
    ),
    _ListItem(
      title: 'Standard Clock',
      imageUrl: 'assets/clock.jpg',
      price: 6.99,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 13.0),
            child: Container(
              height: 50.0,
              width: MediaQuery.of(context).size.width - 30,
              child: RaisedButton(
                elevation: 5.0,
                color: Colors.white,
                child: Text(
                  "QUICK SALE",
                  style:
                      TextStyle(color: Colors.deepPurpleAccent, fontSize: 15.0),
                ),
                onPressed: callback,
              ),
            ),
          ),
        ),
        Expanded(
          key: salesPage,
          flex: 1,
          child: ListView.builder(
            itemCount: listItem.length,
            itemBuilder: (context, index) {
              return listItem[index];
            },
          ),
        ),
        SizedBox(
          height: 70.0,
        )
      ],
    );
  }
}

class _StorePage extends StatelessWidget {
  final Function callback;

  _StorePage({this.callback});

  List<String> _storeImage = [
    'tools.png',
    'placeholder.png',
    'credit-card-store.png',
    'app.png',
    'chat-store.png',
    'settings.png',
    'support.png',
    'smartphone.png'
  ];
  List<String> _menuTitle = [
    'Hardware',
    'Locations',
    'Payment types',
    'Apps',
    'Tips',
    'Settings',
    'Support',
    'Get Gabin mobile'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
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
            padding: EdgeInsets.only(
              left: 10.0,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return SizedBox(
                  height: 50.0,
                  width: double.infinity,
                  child: MaterialButton(
                    onPressed: () {
                      callback(index);
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Transform(
                            transform: Matrix4.translationValues(-15, 0, 0),
                            child: SizedBox(
                              width: 30.0,
                              child: Image.asset(
                                'assets/${_storeImage[index]}',
                              ),
                            ),
                          ),
                          Text(
                            _menuTitle[index],
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              itemCount: _menuTitle.length,
            ),
          ),
        ),
        SizedBox(
          height: 15.0,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
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
            padding: EdgeInsets.only(
              left: 10.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MaterialButton(
                  onPressed: () {},
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Transform(
                          transform: Matrix4.translationValues(-15, 0, 0),
                          child: Text(
                            "Log out of App",
                            style: TextStyle(
                                fontSize: 16.0, color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class _ListItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double price;

  _ListItem({
    @required this.imageUrl,
    @required this.title,
    @required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
            height: 100,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 80.0,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ExactAssetImage(imageUrl),
                              fit: BoxFit.cover,
                            ),
                            border: Border.all(
                              color: Colors.black12,
                            )),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 10.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              title,
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            Text(
                              "\$$price",
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  ButtonTheme(
                    padding: EdgeInsets.all(0),
                    minWidth: 0,
                    height: 0,
                    child: MaterialButton(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onPressed: () {},
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.deepPurpleAccent,
                              width: 1.2,
                            ),
                            borderRadius: BorderRadius.circular(30.0)),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.5,
                          ),
                          child: Text("i"),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )),
        Divider(),
      ],
    );
  }
}
