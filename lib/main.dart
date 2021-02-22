import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:async/async.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(),
      title: 'Flutter Demo',
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String scanned = "";

  @override
  initState() {
    super.initState();
  }

  Future barcodeScanning() async {
    try {
      String barcode = await FlutterBarcodeScanner.scanBarcode(
          "ff6666", "Cancel", false, ScanMode.BARCODE);
      setState(() {
        this.scanned = barcode;
        print(barcode);
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        this.scanned = "error of some kind";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Stack(
      children: [
        Container(
          color: MediaQuery.of(context).platformBrightness == Brightness.light
              ? Colors.white
              : Colors.black,
          child: Container(
            child: CustomScrollView(
              slivers: [
                CupertinoSliverNavigationBar(
                  backgroundColor: MediaQuery.of(context).platformBrightness ==
                          Brightness.light
                      ? Colors.grey[100]
                      : Color(0xcc171717),
                  largeTitle: Text(
                    'DigiPass',
                    style: TextStyle(
                        fontFamily: 'SFUI-Semibold',
                        letterSpacing: -.75,
                        color: Colors.deepOrange),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          '$scanned',
                          style: TextStyle(
                              fontFamily: 'SFUI-Medium',
                              fontWeight: FontWeight.normal,
                              color:
                                  MediaQuery.of(context).platformBrightness ==
                                          Brightness.light
                                      ? Colors.black
                                      : Colors.white),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(20.0),
          alignment: Alignment.bottomRight,
          child: ClipPath(
            clipper: ShapeBorderClipper(shape: CircleBorder()),
            child: Container(
              color: Colors.deepOrange,
              child: CupertinoButton(
                onPressed: () {
                  barcodeScanning();
                },
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Icon(SFSymbols.plus_rectangle_fill_on_rectangle_fill,
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.light
                          ? Colors.white
                          : Colors.black,
                      size: 30),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
