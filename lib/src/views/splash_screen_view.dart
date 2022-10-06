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

class SplashScreenMy extends StatefulWidget {
  String deepList = null;
  @override
  State<StatefulWidget> createState() {
    return SplashScreenMyState(this.deepList);
  }
  SplashScreenMy(this.deepList);
}

class SplashScreenMyState extends StateMVC<SplashScreenMy> {

  String deepList = null;
  static const platform = const MethodChannel('com.flutter.epic/epic');
  String dataShared = "No Data";
  SplashScreenController _con;
  BuildContext context;
  SplashScreenMyState(String deepList) : super(SplashScreenController()) {
    _con = controller;
    this.deepList = deepList;
  }
  String isDeepLink = "";
  String deepProfile = 'playersszereda';
  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('deeplink lekerdez splashben start');
    // List<String> l = await prefs.getStringList("deeplinkids") ?? <String>[];
    SharedPreferencesHelper.getDeepLink().then((value) {
      deepList = value;

      print('deeplink lekerdez splashben end'+(deepList!=null?deepList.toString():"null"));

      if (deepList !=null) {
        try {
          linkController.text= deepList;
          String _link = deepList;
          if (_link.contains("?v=")) {
            _link = _link.split("?v=")[1];
            print('deeplink 000 start');
            SharedPreferencesHelper.setDeepLinkIds(
                _link.split(",")).then((value) {
              SharedPreferencesHelper.setDeepLinkProfile('0').then((value) {
                setState(() {
                  isDeepLink = 'true';
                  deepProfile = 'playersszereda';
                });
              });
            });

          } else if (_link.contains("?v1=")) {
            _link = _link.split("?v1=")[1];
            SharedPreferencesHelper.setDeepLinkIds(
                _link.split(",")).then((value) {
              SharedPreferencesHelper.setDeepLinkProfile('1').then((value) {
                setState(() {
                  isDeepLink = 'true';
                deepProfile = '1';});
              });
            });
          } else {
            print('deeplink nullazva start');
            SharedPreferencesHelper.setDeepLinkIds(<String>[]).then((value) {
              setState(() { isDeepLink = 'false';});
            });
            print('deeplink nullazva end');
          }



        }catch(e){
          SharedPreferencesHelper.setDeepLinkIds(<String>[]).then((value) {
            setState(() { isDeepLink = 'false';});
          });
        }

      } else {
        SharedPreferencesHelper.setDeepLinkIds(<String>[]).then((value) {
          setState(() { isDeepLink = 'false';});
        });


      }
    });

  }

  @override
  void initState() {
    super.initState();
//    SystemChrome.setPreferredOrientations([
//      DeviceOrientation.landscapeRight,
//      DeviceOrientation.landscapeLeft,
//    ]);
//     loadData();

    getSharedPrefs();
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
          Fluttertoast.showToast(msg: "Hupsz..valamiért nem sikerült!");
        });
      });
    } catch (e) {
      print("catch");
      print(e.toString());
      Fluttertoast.showToast(msg: "Hupsz..valami hiba történt!");
    }
  }
  final linkController = TextEditingController();
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
      child: isDeepLink!=''?
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
                        margin: EdgeInsets.only(left: 40,right: 40, bottom: 20),
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
                                      "FK CSíkszereda / Nyárádszereda",
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
                        bool b = await SharedPreferencesHelper.getNeedPIN();
                        SharedPreferences preferences = await SharedPreferences.getInstance();
                        await preferences.clear();
                        await SharedPreferencesHelper.setNeedPIN(b);
                        if (!isAlreadyTapped) {
                          loadData('1');
                        }
                        setState(() {
                          isAlreadyTapped = true;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 40,right: 40, bottom: 20),
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
                    Container(
                      height: 40,
                      margin: EdgeInsets.only(left: 40,right: 40, bottom: 20),
                      child: Row(
                        children: [
                        Container(
                          height: 40,
                          width:  MediaQuery.of(context).size.width-80,
                          // margin: EdgeInsets.only(left: 40,right: 40),
                          child: Row(
                            children: [
                              Container(
                                height: 40,
                                child: InkWell(
                                          onTap: () async {

                                            if (isDeepLink=="true") {
                                              if (!isAlreadyTapped) {
                                                loadData(deepProfile);
                                              }
                                              setState(() {
                                                isAlreadyTapped = true;
                                              });
                                            }
                                          },
                                          child: Container(
                                            alignment: Alignment.bottomLeft,
                                            child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.rectangle,
                                                  borderRadius: BorderRadius.circular(15.0),
                                                  color:  Colors.red.withOpacity(0.4),
                                                ),
                                                child: Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 18),
                                                    child: Row(

                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          "Lejátszás a linkről",
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.normal,
                                                            color: isDeepLink!="true"?Colors.white.withOpacity(0.4):Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )

                                            ),
                                          ),
                                        ),
                              ),
                            ],
                          ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 40,
                      margin: EdgeInsets.only(left: 40,right: 40, bottom: 20),
                      child: Row(
                        children: [
                        Container(
                          height: 40,
                          width:  MediaQuery.of(context).size.width-80,
                          // margin: EdgeInsets.only(left: 40,right: 40),
                          child: Row(
                            children: [

                              Container(
                          decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.circular(15.0),
                                          color:  Colors.white,
                                        ),
                                // height: 40,
                                width: MediaQuery.of(context).size.width-80,
                                // color: Colors.white,
                                child:  TextField(
                                          controller: linkController,
                                          style: TextStyle(
                                            fontSize: 13.0,
                                            color: Colors.black,
                                          ),
                                          onTap: () {
                                            //_con.scrollToBottom();
                                          },
                                          onChanged: (value) {
                                            // _con.typing();
                                            // _con.msg = value;
                                            if (value !=null) {
                                              try {
                                                String _link = value;
                                                if (_link.contains("?v=")) {
                                                  _link = _link.split("?v=")[1];
                                                  print('deeplink 000 start');
                                                  SharedPreferencesHelper.setDeepLinkIds(
                                                      _link.split(",")).then((value) {
                                                    SharedPreferencesHelper.setDeepLinkProfile('0').then((value) {
                                                      setState(() {
                                                        isDeepLink = 'true';
                                                        deepProfile = 'playersszereda';
                                                      });
                                                    });
                                                  });

                                                } else if (_link.contains("?v1=")) {
                                                  _link = _link.split("?v1=")[1];
                                                  SharedPreferencesHelper.setDeepLinkIds(
                                                      _link.split(",")).then((value) {
                                                    SharedPreferencesHelper.setDeepLinkProfile('1').then((value) {
                                                      setState(() { isDeepLink = 'true';
                                                      deepProfile = '1';});
                                                    });
                                                  });
                                                } else {
                                                  print('deeplink nullazva start');
                                                  SharedPreferencesHelper.setDeepLinkIds(<String>[]).then((value) {
                                                    setState(() { isDeepLink = 'false';});
                                                  });
                                                  print('deeplink nullazva end');
                                                }



                                              }catch(e){
                                                SharedPreferencesHelper.setDeepLinkIds(<String>[]).then((value) {
                                                  setState(() { isDeepLink = 'false';});
                                                });
                                              }

                                            } else {
                                              SharedPreferencesHelper.setDeepLinkIds(<String>[]).then((value) {
                                                setState(() { isDeepLink = 'false';});
                                              });


                                            }
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'paste your link',
                                            hintStyle: TextStyle(
                                              fontSize: 13.0,
                                              color: Colors.grey,
                                            ),
                                            contentPadding: EdgeInsets.only(
                                              left: 10.0,
                                            ),
                                            border: InputBorder.none,
                                          ),
                                        ),
                              )
                            ],
                          ),
                          )
                        ],
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
      ):Material(
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
