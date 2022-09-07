import 'package:Leuke/src/helpers/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:pedantic/pedantic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/splash_screen_controller.dart';
import '../repositories/user_repository.dart' as userRepo;
import '../repositories/video_repository.dart' as videoRepo;

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends StateMVC<SplashScreen> {
  static const platform = const MethodChannel('com.flutter.epic/epic');
  String dataShared = "No Data";
  SplashScreenController _con;
  BuildContext context;
  SplashScreenState() : super(SplashScreenController()) {
    _con = controller;
  }
  bool isDeepLink = true;

  @override
  void initState() {
    super.initState();
//    SystemChrome.setPreferredOrientations([
//      DeviceOrientation.landscapeRight,
//      DeviceOrientation.landscapeLeft,
//    ]);
//     loadData();
  SharedPreferencesHelper.getDeepLinkIds().then((value) {
    if (value!=null && value.length > 0 ){
      loadData("playersszereda");
    } else {
      setState(() {
        isDeepLink = false;
      });
    }
  });
  }

  printHashKeyOnConsoleLog() async {
    try {
      await platform.invokeMethod("printHashKeyOnConsoleLog");
    } catch (e) {
      print(e);
    }
  }

  void loadData(String profilString) async {
    try {
      await SharedPreferencesHelper.setRangeStart('last');
      await SharedPreferencesHelper.setRangeEnd('last');
      await _con.userUniqueId();
      userRepo.getCurrentUser().whenComplete(() {
        _con.initializeVideos(profilString).whenComplete(() {
          videoRepo.dataLoaded.addListener(() async {
            if (videoRepo.dataLoaded.value) {
              if (mounted) {
                if (userRepo.currentUser.value.token != '') {
                  // _con.connectUserSocket();
                }
                unawaited(videoRepo.homeCon.value.preCacheVideos());
                printHashKeyOnConsoleLog();
                SharedPreferencesHelper.setSelectedProfile(profilString).then((value) {
                  Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                });
              }
            }
          });
        }).onError((error, stackTrace) {
          isAlreadyTapped = false;
          Fluttertoast.showToast(msg: "Hupsz..valamiért nem sikerül!");
        });
      });
    } catch (e) {
      print("catch");
      print(e.toString());
      Fluttertoast.showToast(msg: "Hupsz..valami hiba történt!");
    }
  }

  bool isAlreadyTapped = false;
  DateTime currentBackPressTime;

  @override
  Widget build(BuildContext context) {
    setState(() => this.context = context);
    return WillPopScope(
      onWillPop: () {
        DateTime now = DateTime.now();
        // Navigator.pop(context);
        if (currentBackPressTime == null || now.difference(currentBackPressTime) > Duration(seconds: 2)) {
          currentBackPressTime = now;
          Fluttertoast.showToast(msg: "Tap again to exit an app.");
          return Future.value(false);
        }
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return Future.value(true);
      },
      child: isDeepLink?Stack(
        children: <Widget>[
          Container(


            decoration: BoxDecoration(
              color: Colors.transparent,
              image: DecorationImage(
                image: AssetImage(
                  "assets/images/splash.png",
                ),
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
        ],
      ):
      Material(
        child: Container(
          color:Colors.black,
          child: Stack(
            children: <Widget>[
              Container(


                decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                    image: AssetImage(
                      "assets/images/splash.png",
                    ),
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () async {
                        bool b = await SharedPreferencesHelper.getNeedPIN();
                        SharedPreferences preferences = await SharedPreferences.getInstance();
                        await preferences.clear();
                        await SharedPreferencesHelper.setNeedPIN(b);
                        if (!isAlreadyTapped) {
                          loadData('playersszereda');
                        }
                        setState(() {
                          isAlreadyTapped = true;
                        });
                      },
                      child: Container(

                        margin: EdgeInsets.only(left: 80,right: 80, bottom: 20),
                        child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(15.0),
                              color:  Colors.red.withOpacity(0.7),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Gernyeszeg 2022",//FKCS
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )

                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        /*bool b = await SharedPreferencesHelper.getNeedPIN();
                        SharedPreferences preferences = await SharedPreferences.getInstance();
                        await preferences.clear();
                        await SharedPreferencesHelper.setNeedPIN(b);
                        if (!isAlreadyTapped) {
                          loadData('1');
                        }
                        setState(() {
                          isAlreadyTapped = true;
                        });*/
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 80,right: 80, bottom: 20),
                        alignment: Alignment.center,
                        child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(15.0),
                              color:  Colors.red.withOpacity(0.4),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "FKCS",
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )

                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        /*bool b = await SharedPreferencesHelper.getNeedPIN();
                        SharedPreferences preferences = await SharedPreferences.getInstance();
                        await preferences.clear();
                        await SharedPreferencesHelper.setNeedPIN(b);
                        if (!isAlreadyTapped) {
                          loadData('1');
                        }
                        setState(() {
                          isAlreadyTapped = true;
                        });*/
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 80,right: 80, bottom: 20),
                        alignment: Alignment.center,
                        child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(15.0),
                              color:  Colors.red.withOpacity(0.4),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Teszt Profil 1.",
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )

                        ),
                      ),
                    ),

                  ],
                ),
              ),
              isAlreadyTapped?Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(bottom: 50),
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ):Container()
            ],
          ),
        ),
      ),
    );
  }
}
