import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_digipass/photo_view.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String _scanned = "";

  @override
  initState() {
    loadScan();

    super.initState();
  }

  loadScan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _scanned = (prefs.getString('scan') ?? "");
    });
  }

  Future barcodeScanning() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (kReleaseMode) {
      try {
        String barcode = await FlutterBarcodeScanner.scanBarcode(
            "ff6666", "Cancel", false, ScanMode.BARCODE);
        setState(() {
          if (barcode != "-1") {
            if (barcode.startsWith('00', 0)) {
              barcode = barcode.substring(2);
            }
            _scanned = '$barcode';
            prefs.setString('scan', '$barcode');
            print(barcode);
          }
        });
      } on PlatformException catch (e) {
        print(e);
        setState(() {
          _scanned = "There was an error scanning your card.";
        });
      }
    } else {
      String barcode = "0016466";
      setState(() {
        if (barcode.startsWith('00', 0)) {
          barcode = barcode.substring(2);
        }
        _scanned = '$barcode';
        prefs.setString('scan', '$barcode');
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
                    'My Eagle Card',
                    style: TextStyle(
                        fontFamily: 'SFUI-Semibold',
                        letterSpacing: -.75,
                        color: Colors.blue),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: kDebugMode
                              ? Text(
                                  "When using debug mode, barcode data is simulated.",
                                  style: TextStyle(
                                    fontFamily: 'SFUI-Medium',
                                    color: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.light
                                        ? Colors.black
                                        : Colors.white,
                                  ))
                              : Text(
                                  'Scan a card to get started.',
                                  style: TextStyle(
                                    fontFamily: 'SFUI-Medium',
                                    color: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.light
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Visibility(
                            visible: (_scanned != ""),
                            child: Container(
                              constraints: BoxConstraints(maxWidth: 400),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors
                                        .black, //                   <--- border color
                                    width: 2.0,
                                  ),
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0))),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      child: Container(
                                        color: Colors.white,
                                        child: Column(
                                          children: [
                                            Row(children: [
                                              Spacer(
                                                flex: 2,
                                              ),
                                              Text(
                                                'Brentwood School',
                                                style: TextStyle(
                                                  fontFamily: 'SFUI-Medium',
                                                  fontSize: 20,
                                                ),
                                              ),
                                              Spacer(flex: 5),
                                              ClipRRect(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)),
                                                child: Container(
                                                  color: Color.fromRGBO(
                                                      9, 89, 172, 1.0),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Image.asset(
                                                      'assets/1200px-Brentwood_School_(Los_Angeles)_logo.svg.png',
                                                      width: 50,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ]),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 5),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)),
                                                child: Container(
                                                  color: Colors.white,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      left: 15.0,
                                                      right: 15.0,
                                                      // top: 15.0,
                                                    ),
                                                    child: Text(
                                                      '*$_scanned*',
                                                      style: TextStyle(
                                                        fontFamily: 'Barcode39',
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.black,
                                                        fontSize: 80,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),

                                            Text(
                                              'Student ID: $_scanned',
                                              style: TextStyle(
                                                fontFamily: 'SFUI-Medium',
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black,
                                                fontSize: 20,
                                              ),
                                            ),
                                            //),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            child: GestureDetector(
                              child: Hero(
                                  tag: 'Schedule',
                                  child: Image.asset('assets/Schedule.png')),
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (_) {
                                  return ScheduleView();
                                }));
                              },
                            ),
                          ),
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
              color: Colors.blue.shade700,
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
