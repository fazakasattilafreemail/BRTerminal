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
import 'package:cloud_firestore/cloud_firestore.dart';
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

          } else if (_link.contains("?v")) {
            _link = _link.split("?v")[1];
            String pString = _link.substring(0,_link.indexOf("="));
            try {
              _link = _link.substring(_link.indexOf("=") + 1);
            } catch(e){
            }


            SharedPreferencesHelper.setDeepLinkIds(
                _link.split(",")).then((value) {
              SharedPreferencesHelper.setDeepLinkProfile(pString).then((value) {
                setState(() {
                  isDeepLink = 'true';
                deepProfile = pString;});
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

    // getProfilesFromDb();
    getSharedPrefs();
  }

  printHashKeyOnConsoleLog() async {
    try {
      await platform.invokeMethod("printHashKeyOnConsoleLog");
    } catch (e) {
      print(e);
    }
  }

  Map<String, dynamic> profilesMapFromDb  = new Map<String, dynamic>();
  void getProfilesFromDb() async {
    FirebaseFirestore.instance.collection("profiles").get().then((
        QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((element) {
        setState(() {
          profilesMapFromDb = element['profiles_map'] as Map;
          // profilesMapFromDb.forEach((key, value) {
          //   myTeamsStringPrefix=myTeamsStringPrefix+teamsMapFromDbForRead[key]['name']+",";
          //
          // });

        });

        // SharedPreferencesHelper.setVideoMapForRead(videoMapFromDb);

      });

    });
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
          alignment: Alignment.topCenter,

          color: const Color(0xff231f20),
          child: Stack(
            children: <Widget>[
              Align(
               alignment: Alignment.topCenter,
                child: Container(

                  height: 100,
                  alignment: Alignment.topCenter,
                  decoration: BoxDecoration(
                    color: Colors.transparent,

                    image: DecorationImage(
                      image: AssetImage(
                        "assets/images/splashlapos.png",
                      ),
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // InkWell(
                    //   onTap: () async {
                    //     bool b = await SharedPreferencesHelper.getNeedPIN();
                    //     SharedPreferences preferences = await SharedPreferences.getInstance();
                    //     await preferences.clear();
                    //     await SharedPreferencesHelper.setNeedPIN(b);
                    //     if (!isAlreadyTapped) {
                    //       loadData('playersszereda');
                    //     }
                    //     setState(() {
                    //       isAlreadyTapped = true;
                    //     });
                    //   },
                    //   child: Container(
                    //     margin: EdgeInsets.only(left: 40,right: 40, bottom: 20),
                    //     alignment: Alignment.center,
                    //     child: DecoratedBox(
                    //         decoration: BoxDecoration(
                    //           shape: BoxShape.rectangle,
                    //           borderRadius: BorderRadius.circular(15.0),
                    //           color:  Colors.red.withOpacity(0.4),
                    //         ),
                    //         child: Center(
                    //           child: Padding(
                    //             padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
                    //             child: Row(
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               children: [
                    //                 Text(
                    //                   "FK CSíkszereda / Nyárádszereda",
                    //                   style: TextStyle(
                    //                     fontWeight: FontWeight.normal,
                    //                     color: Colors.white,
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         )
                    //
                    //     ),
                    //   ),
                    // ),
                    // InkWell(
                    //   onTap: () async {
                    //     bool b = await SharedPreferencesHelper.getNeedPIN();
                    //     SharedPreferences preferences = await SharedPreferences.getInstance();
                    //     await preferences.clear();
                    //     await SharedPreferencesHelper.setNeedPIN(b);
                    //     if (!isAlreadyTapped) {
                    //       loadData('1');
                    //     }
                    //     setState(() {
                    //       isAlreadyTapped = true;
                    //     });
                    //   },
                    //   child: Container(
                    //     margin: EdgeInsets.only(left: 40,right: 40, bottom: 20),
                    //     alignment: Alignment.center,
                    //     child: DecoratedBox(
                    //         decoration: BoxDecoration(
                    //           shape: BoxShape.rectangle,
                    //           borderRadius: BorderRadius.circular(15.0),
                    //           color:  Colors.red.withOpacity(0.4),
                    //         ),
                    //         child: Center(
                    //           child: Padding(
                    //             padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
                    //             child: Row(
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               children: [
                    //                 Text(
                    //                   "Teszt Profil 1.",
                    //                   style: TextStyle(
                    //                     fontWeight: FontWeight.normal,
                    //                     color: Colors.white,
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         )
                    //
                    //     ),
                    //   ),
                    // ),
                    Container(
                      height: 40,
                      margin: EdgeInsets.only(left: 40,right: 40, bottom: 10),
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
                      margin: EdgeInsets.only(left: 40,right: 40, bottom: 10),
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

                                                } else if (_link.contains("?v")) {

                                                  _link = _link.split("?v")[1];
                                                  String pString = _link.substring(0,_link.indexOf("="));
                                                  try {
                                                    _link = _link.substring(_link.indexOf("=") + 1);
                                                  } catch(e){
                                                  }
                                                  print('deeplink _link_link:'+_link);
                                                  print('deeplink _link_linkpStringpString:'+pString);
                                                  SharedPreferencesHelper.setDeepLinkIds(
                                                      _link.split(",")).then((value) {
                                                    SharedPreferencesHelper.setDeepLinkProfile(pString).then((value) {
                                                      setState(() { isDeepLink = 'true';
                                                      deepProfile = pString;});
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

              Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
                  child: InkWell(
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
                      height: 60,
                      width: 60,
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
                ),
              ),

              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('profiles')
                          .snapshots(),
                      builder:
                          (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
                        switch (snapshot.connectionState) {
                          // case ConnectionState.waiting:
                          //   return new Text('Loading...');
                          default:
                            return snapshot==null||snapshot.data==null?Container():Container(
                              height: 80,

                              color: Colors.transparent,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  reverse: false,
                                  itemCount: snapshot.data.docs.length,
                                  itemBuilder: (context, index) {
                                    // var result = snapshot.data.docs[index]['profiles_map'];
                                    return  Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10, top: 10, bottom: 0),
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            left: 30, right: 30, top: 0, bottom: 0),
                                        height: 50,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.white.withOpacity(0.5),
                                                spreadRadius: 1.5,
                                                blurRadius: 1.5,
                                                //offset: Offset(0, 1), // changes position of shadow
                                              ),
                                            ],
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(
                                                color: Colors.red[200],
                                                width: 0.5,
                                                style: BorderStyle.solid)),
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              // for (var res in result.entries)
                                              InkWell(
                                                onTap: () async {
                                                  bool b = await SharedPreferencesHelper.getNeedPIN();
                                                  bool bLaza = await SharedPreferencesHelper.getNeedLazaPIN();
                                                  bool bLaza2 = await SharedPreferencesHelper.getNeedLaza2PIN();
                                                  SharedPreferences preferences = await SharedPreferences.getInstance();
                                                  await preferences.clear();
                                                  await SharedPreferencesHelper.setNeedPIN(b);
                                                  await SharedPreferencesHelper.setNeedLazaPIN(bLaza);
                                                  await SharedPreferencesHelper.setNeedLaza2PIN(bLaza2);

                                                  bool feltetel = b && bLaza2;
                                                  if (snapshot.data.docs[snapshot.data.docs.length-(index+1)]['id'] == '3') {
                                                    feltetel = b && bLaza;
                                                  }

                                                  if (feltetel) {
                                                    _displayTextInputDialog(context,snapshot.data.docs[snapshot.data.docs.length-(index+1)]['pin'],snapshot.data.docs[snapshot.data.docs.length-(index+1)]['id'] == '3').whenComplete(() async {
                                                      if (valuePIN == '1010' || valuePIN == snapshot.data.docs[snapshot.data.docs.length-(index+1)]['pin']) {
                                                        if (!isAlreadyTapped) {
                                                          loadData(snapshot.data.docs[snapshot.data.docs.length-(index+1)]['id']);
                                                        }
                                                        setState(() {
                                                          isAlreadyTapped = true;
                                                        });
                                                      }
                                                    });

                                                  } else {
                                                    if (!isAlreadyTapped) {
                                                      loadData(snapshot.data.docs[snapshot.data.docs.length-(index+1)]['id']);
                                                    }
                                                    setState(() {
                                                      isAlreadyTapped = true;
                                                    });
                                                  }
                                                }
                                                ,child:  Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(

                                                    snapshot.data.docs[snapshot.data.docs.length-(index+1)]['name'],
                                                    style: TextStyle(
                                                        fontSize: 20, color: Colors.red[500]),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(top: 10),
                                                    child: Text(

                                                      snapshot.data.docs[snapshot.data.docs.length-(index+1)]['description'],
                                                      style: TextStyle(
                                                          fontSize: 14, color: Colors.black45),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              ),

                                            ]),
                                      ),

                                    );
                                  }),
                            );
                        }
                      },
                    ),
                  ],
                ),
              ),
              isAlreadyTapped?InkWell(
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: Container(
                      width: 40,
                      height:40,
                      margin: EdgeInsets.only(bottom: 50),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
              ):Container(),
            ],
          ),
        ),
      ):Material(
        child: Container(
          color:Colors.black,
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Container(

                  height: 100,
                  alignment: Alignment.topCenter,
                  decoration: BoxDecoration(

                    image: DecorationImage(
                      image: AssetImage(
                        "assets/images/splashlapos.png",
                      ),
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
              ),

              isAlreadyTapped?InkWell(
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: Container(
                      width: 40,
                      height:40,
                      margin: EdgeInsets.only(bottom: 50),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
              ):Container(),

            ],
          ),
        ),
      ),
    );
  }
  String valuePIN = "";
  String valuePINtmp = "";
  TextEditingController _textFieldController = new TextEditingController();
  Future<void> _displayTextInputDialog(BuildContext context, String pinLaza, bool egysesLazaTipus) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('PIN szükséges'),
            content: TextField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              onChanged: (value) {
                setState(() {
                  valuePINtmp = value;
                });
              },
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "PIN"),
            ),
            actions: <Widget>[
              Center(
                child: InkWell(
                  child: Icon(Icons.check_circle , size: 50.0, color: Colors.black87),
                  onTap: () {
                    setState(() {
                      if (valuePINtmp == '1010'){
                        valuePIN = valuePINtmp;
                        SharedPreferencesHelper.setNeedPIN(false).then((value) =>
                            Navigator.pop(context));
                      } else if (valuePINtmp == pinLaza){
                        valuePIN = valuePINtmp;
                        if(egysesLazaTipus) {
                          SharedPreferencesHelper.setNeedLazaPIN(false).then((
                              value) =>
                              Navigator.pop(context));
                        } else  {
                          SharedPreferencesHelper.setNeedLaza2PIN(false).then((
                              value) =>
                              Navigator.pop(context));
                        }
                      } else {
                        Navigator.pop(context);
                      }


                    });
                  },
                ),
              ),

            ],
          );
        });
  }
/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('fddf'),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('profiles')
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return new Text('Loading...');
              default:
                return Container(

                  child: ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        // var result = snapshot.data.docs[index]['profiles_map'];
                        return  Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 10, bottom: 0),
                            child: Container(
                              height: 50,
                              width: 300,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.5),
                                      spreadRadius: 1.5,
                                      blurRadius: 1.5,
                                      //offset: Offset(0, 1), // changes position of shadow
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: Colors.red[200],
                                      width: 0.5,
                                      style: BorderStyle.solid)),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    // for (var res in result.entries)
                                      Text(
                                        snapshot.data.docs[index]['name'],
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.red[500]),
                                      ),
                                  ]),
                            ),

                        );
                      }),
                );
            }
          },
    )
    );}*/
}
