import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_digipass/photo_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

// Future<void> initializeFlutterFire() async {
//   await Firebase.initializeApp();
//   NotificationSettings settings = await messaging.requestPermission();
//   analytics = FirebaseAnalytics();
//   FirebasePerformance performance = FirebasePerformance.instance;
//   await FirebaseCrashlytics.instance
//       .setCrashlyticsCollectionEnabled(!kDebugMode);
//   Function? originalOnError = FlutterError.onError;
//   FlutterError.onError = (FlutterErrorDetails errorDetails) async {
//     await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
//     // Forward to original handler.
//     originalOnError!(errorDetails);
//   };
// }

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp],
    );
    return FutureBuilder(
        future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CupertinoApp(
              debugShowCheckedModeBanner: false,
              theme: CupertinoThemeData(),
              title: 'Flutter Demo',
              home: MyHomePage(title: 'Flutter Demo Home Page'),
            );
          }
          return CupertinoApp(home: Container(color: Colors.black));
        });
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.
  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Set default `_initialized` and `_error` state to false
  bool _initialized = false;
  bool _error = false;
  int eagleCardNumber = 0;
  String nameText = "";
  String emailText = "";
  bool shouldShowSignInButton = true;

  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      FirebaseAuth auth = FirebaseAuth.instance;
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission();
      FirebasePerformance performance = FirebasePerformance.instance;
      FirebaseAnalytics analytics = FirebaseAnalytics.instance;

      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
      Function? originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails errorDetails) async {
        await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);

        originalOnError!(errorDetails);
      };
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      print(e);
      setState(() {
        _error = true;
      });
    }
  }

  void getEagleCardNumber() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('ids')
        .where("email", isEqualTo: emailText)
        .get()
        .then((QuerySnapshot querySnapshot) {
      // print(querySnapshot);
      querySnapshot.docs.forEach((doc) {
        //    print("Document: " + doc.data().toString());
        setState(() {
          //      print("Eagle Card Number");
          eagleCardNumber = doc["eagleCardNum"];
        });
      });
    });
  }

  @override
  initState() {
    initializeFlutterFire();
    ScreenBrightness _screenBrightness = ScreenBrightness();
    if (!kIsWeb) {
      _screenBrightness.setScreenBrightness(1.0);
    }
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) {
      emailText = firebaseUser?.email ?? "";
      nameText = firebaseUser?.displayName ?? "";
      if (firebaseUser?.email != null) {
        print("Getting Eagle Card Number");
        getEagleCardNumber();
        setState(() {
          shouldShowSignInButton = true;
        });
      } else {
        setState(() {
          shouldShowSignInButton = false;
        });
      }
      shouldShowSignInButton = FirebaseAuth.instance.currentUser == null;
    });

    // if (!kDebugMode) {
    //   loadScan();
    // }
    super.initState();
  }

  // loadScan() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     _scanned = (prefs.getString('scan') ?? "");
  //   });

  //   // if (usingFirebase) {
  //   //   await analytics.logEvent(name: 'loadedCard');
  //   // }
  // }

  GoogleSignInAccount? googleUser;
  GoogleSignInAuthentication? googleAuth;
  Future<void> signInWithGoogle() async {
    googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser!.authentication;
    setState(() {
      emailText = googleUser!.email;
      nameText = googleUser!.displayName!;
    });
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth!.accessToken,
      idToken: googleAuth.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  void signOutWithGoogle() async {
    googleSignIn.signOut();
    FirebaseAuth.instance.signOut();
    setState(() {
      emailText = '';
      nameText = '';
    });
  }

  // Future barcodeScanning() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   // if (usingFirebase) {
  //   //   await analytics.logEvent(name: 'push_scan_button');
  //   // }
  //   if (kReleaseMode) {
  //     try {
  //       String barcode = await FlutterBarcodeScanner.scanBarcode(
  //           "ff6666", "Cancel", false, ScanMode.BARCODE);
  //       setState(() {
  //         if (barcode != "-1") {
  //           if (barcode.startsWith('00', 0)) {
  //             barcode = barcode.substring(2);
  //           }
  //           _scanned = '$barcode';
  //           prefs.setString('scan', barcode);
  //           print(barcode);
  //         }
  //       });
  //     } on PlatformException catch (e) {
  //       print(e);
  //       setState(() {
  //         _scanned = "There was an error scanning your card.";
  //       });
  //     }
  //   } else {
  //     String barcode = "0016466";
  //     setState(() {
  //       if (barcode.startsWith('00', 0)) {
  //         barcode = barcode.substring(2);
  //       }
  //       _scanned = '$barcode';
  //       prefs.setString('scan', '$barcode');
  //     });
  //   }
  // }

  String? userName = '';
  String? photoURL = '';
  String? email = '';
  Widget _signInButton() {
    return CupertinoButton(
      onPressed: () async {
        await signInWithGoogle();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(
                    image: AssetImage("assets/google_logo.png"), height: 35.0),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    'Sign in with Google',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[700],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _signOutButton() {
    return CupertinoButton(
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(
                    image: AssetImage("assets/google_logo.png"), height: 35.0),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    'Sign out',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[700],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      onPressed: () {
        signOutWithGoogle();
        setState(() {
          userName = "";
          email = "";
          photoURL = "";
        });
      },
    );
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
                  // heroTag: 'bar',
                  transitionBetweenRoutes: true,
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
                          child: emailText != ''
                              ? Container()
                              : Text(
                                  'Login to get started.',
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
                          height: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Visibility(
                            visible: (eagleCardNumber != 0),
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
                                                      cacheHeight: 300,
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
                                                        bottom: 15.0,
                                                        top: 10.0,
                                                      ),
                                                      child: BarcodeWidget(
                                                        data:
                                                            '$eagleCardNumber',
                                                        barcode:
                                                            Barcode.code39(),
                                                        height: 65,
                                                        drawText: false,
                                                        textPadding: 10,
                                                      )
                                                      /*Text(
                                                      '*$eagleCardNumber*',
                                                      style: TextStyle(
                                                        inherit: false,
                                                        fontFamily: 'Barcode39',
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.black,
                                                        fontSize: 80,
                                                      ),
                                                    ), */
                                                      ),
                                                ),
                                              ),
                                            ),

                                            Text(
                                              'Student ID: $eagleCardNumber',
                                              style: TextStyle(
                                                fontFamily: 'SFUI-Medium',
                                                color: Colors.black,
                                                fontSize: 20,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            //),
                                            Text(nameText,
                                                style: TextStyle(
                                                    fontFamily: 'SFUI-Medium',
                                                    fontSize: 20,
                                                    color: Colors.black)),
                                            Text(emailText,
                                                style: TextStyle(
                                                    fontFamily: 'SFUI-Medium',
                                                    fontSize: 20,
                                                    color: Colors.black)),
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
                        /* Padding(
                          
                          padding: const EdgeInsets.all(10.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            child: GestureDetector(
                              child: Hero(
                                  tag: 'Schedule',
                                  child:
                                      "https://github.com/jawshoeadan/flutter_digipass/raw/master/assets/Schedule.png"
                                              .isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl:
                                                  "https://github.com/jawshoeadan/flutter_digipass/raw/master/assets/Schedule.png",
                                              progressIndicatorBuilder: (context,
                                                      url, downloadProgress) =>
                                                  CupertinoActivityIndicator(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            )
                                          : Text(
                                              "Unable to connect to network")),
                              //   child: Image.network(
                              //      'https://github.com/jawshoeadan/flutter_digipass/raw/master/assets/Schedule.png')),
                              onTap: () {
                                Navigator.push(context, CupertinoPageRoute(
                                  builder: (_) {
                                    return ScheduleView();
                                  },
                                ));
                              },
                            ),
                          ),
                        ), */

                        shouldShowSignInButton
                            ? _signInButton()
                            : _signOutButton(),
                        CupertinoButton(
                          onPressed: () {
                            FlutterWebBrowser.openWebPage(
                                url: 'http://www.eaglecash.info');
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            child: Container(
                              color: Color.fromRGBO(9, 89, 172, 1.0),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text(
                                  'Add/Check Funds',
                                  style: TextStyle(
                                    fontFamily: 'SFUI-Medium',
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 15.0, right: 15.0),
                          child: Text(
                            "Made by Josh Daneshrad and Eitan Prins-Trachtenberg '22",
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'SFUI-Medium',
                              color:
                                  MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        // Container(
        //   padding: EdgeInsets.all(20.0),
        //   alignment: Alignment.bottomRight,
        //   child: ClipPath(
        //     clipper: ShapeBorderClipper(shape: CircleBorder()),
        //     child: Container(
        //       color: Colors.blue.shade700,
        //       child: CupertinoButton(
        //         onPressed: () {
        //           barcodeScanning();
        //         },
        //         child: Padding(
        //           padding: const EdgeInsets.all(3.0),
        //           child: Icon(SFSymbols.plus_rectangle_fill_on_rectangle_fill,
        //               color: MediaQuery.of(context).platformBrightness ==
        //                       Brightness.light
        //                   ? Colors.white
        //                   : Colors.black,
        //               size: 30),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
