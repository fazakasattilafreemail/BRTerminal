import 'dart:async';
import 'dart:convert';
import 'dart:developer';
// import 'dart:html' as html;
import 'dart:io';
import 'package:fullscreen/fullscreen.dart';
import 'dart:ui' as ui;
import 'package:Leuke/src/helpers/shared_pref.dart';
import 'package:Leuke/src/models/elems.dart';
import 'package:Leuke/src/models/my_models.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:flutter_range_slider/flutter_range_slider.dart' as frs;
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:pedantic/pedantic.dart';
import 'package:share/share.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:fullscreen/fullscreen.dart';

import '../controllers/dashboard_controller.dart';
import '../helpers/helper.dart';
import '../models/sound_model.dart';
import '../models/videos_model.dart';
import '../repositories/sound_repository.dart' as soundRepo;
import '../repositories/user_repository.dart' as userRepo;
import '../repositories/user_repository.dart';
import '../repositories/video_repository.dart' as videoRepo;
import '../repositories/video_repository.dart';
import '../views/login_view.dart';
import '../widgets/VideoPlayer.dart';

class DashboardWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  // final DashboardController con;
  DashboardWidget({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _DashboardWidgetState createState() => _DashboardWidgetState();
}
class _DashboardWidgetState extends StateMVC<DashboardWidget> with SingleTickerProviderStateMixin, RouteAware {
  DashboardController _con;
  double hgt = 0;
  AnimationController musicAnimationController;
  String filter1;
  bool isOpenedFilterWindow = false;
  List<String> filterableMatches = new List();
  Map<String, dynamic> videoMapFromDbForRead = new Map<String, dynamic>();
  Map<String, dynamic> playersMapFromDbForRead = new Map<String, dynamic>();
  Map<String, dynamic> teamsMapFromDbForRead = new Map<String, dynamic>();
  Map<String,MyPlayerElem> myPlayers;
  Map<String,String> myTeams;
String mSelectedProfile;
  Map<String, dynamic> videoMapFromHistory;
  bool isFullScreen = false;
  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final newValue = bottomInset > 0.0;
    if (newValue != videoRepo.homeCon.value.textFieldMoveToUp) {
      setState(() {
        videoRepo.homeCon.value.textFieldMoveToUp = newValue;
      });
    }
  }

  void updateHistory(String id) {
    String key = id.toString();
    SharedPreferencesHelper.getVideoMap().then((videoMapFromSh) {
      setState(() {
        videoMapFromHistory = videoMapFromSh;
        if (videoMapFromHistory!=null) {
          print('kkkkkkkkkkkkkkkkkk'+key);
          dynamic value = null;
          if (videoMapFromHistory.containsKey(key)) {
            print('kkkkkkkkkkkkkkkkkk1');
            value = videoMapFromHistory[key];
            HistoryElem historyElem = new HistoryElem(views: value['views'],
                lastview_date: value['lastview_date'],
                likes: value['likes'],
                loadings: value['loadings'],
                seeks: value['seeks']);

            historyElem.views = historyElem.views + 1;
            print('HHHHHHHHHHHHHHqqqH:' + historyElem.views.toString());
            // history.update(key, (value) => historyElem);
            videoMapFromHistory.update(key, (value) => historyElem.toJson());
          } else {
            HistoryElem historyElem = new HistoryElem(views: 0,
                lastview_date: "",
                likes: 0,
                loadings: 0,
                seeks: 0);

            historyElem.views = historyElem.views + 1;
            print('HHHHHHHHHHHHHHH:' + historyElem.views.toString());
            // history.putIfAbsent(key, () => historyElem);
            videoMapFromHistory.putIfAbsent(key, () => historyElem.toJson());
          }

          SharedPreferencesHelper.setVideoMap(videoMapFromHistory).then((value) {

          });
        }
      });
    });



  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    print(' dashboard view initState');
    Wakelock.enable();

    // print ('MEMORIA ADATOK::::::');
    // print(SysInfo.getTotalPhysicalMemory());
    // print(SysInfo.getFreePhysicalMemory());
    // print(SysInfo.getTotalVirtualMemory());
    // print(SysInfo.getFreeVirtualMemory());
    // print(SysInfo.getVirtualMemorySize());
    _con = videoRepo.homeCon.value;
    _con.swipeController = new SwiperController();
    print('iniiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiit dashboard view');
     // updateDB();
    _con.scaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: "_dashboardPage");
    musicAnimationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 10),
    );
    musicAnimationController.repeat();
    // print(userRepo.currentUser.value);
    // print(userRepo.currentUser.value.email);
    if (userRepo.currentUser.value.email != null) {
      Timer(Duration(milliseconds: 300), () {
        _con.checkEulaAgreement();
      });
    }

    SharedPreferencesHelper.getFilterMatches().then((value) {

      filterMatches= value;
      editedname=filterMatches!=null&& filterMatches.length>0?filterMatches[0]:"Válogatás";
      editednameController.text = editedname;
    });
    print('ppp filterids dashboard view  GET '+filteredIds.length.toString());
    SharedPreferencesHelper.getFilteredIds().then((value) {
      print('ppp filterids dashboard view  GETTED 2 '+value.toString());

      filteredIds= value;
      oldRatings = List.filled(filteredIds.length, "");
      mergeSelects = List.filled(filteredIds.length, true);
    });

    SharedPreferencesHelper.getFilterNames().then((value) {

      filterNames= value;

    });

    SharedPreferencesHelper.getFilterTeams().then((value) {

      filterTeams= value;

    });
    SharedPreferencesHelper.getFilterTypes().then((value) {

      filterTipusok= value;

    });
    SharedPreferencesHelper.getShowMergeDialog().then((value) {

      showMergeDialog= value;

    });
    SharedPreferencesHelper.getQuality().then((value) {

      quality= value;

    });
    SharedPreferencesHelper.getRangeStart().then((value) {

      if (value =='last') {
        DateFormat dateFormat = DateFormat("yyyy-MM-dd");
        DateTime dateTime7 = new DateTime.now().subtract(Duration(days: 30));
        _rangeStart = dateFormat.format(dateTime7);
      } else {
        _rangeStart = value;
      }


    });
    SharedPreferencesHelper.getRangeEnd().then((value) {

      if (value =='last') {
        DateFormat dateFormat = DateFormat("yyyy-MM-dd");
        DateTime dateTime = new DateTime.now();
        _rangeEnd = dateFormat.format(dateTime);
      } else {
        _rangeEnd = value;
      }

    });
    SharedPreferencesHelper.getFilterRating().then((value) {

      filterStarsStates= value;

    });

    SharedPreferencesHelper.getSelectedProfile().then((profilString) {
      setState(() {
        mSelectedProfile = profilString;
      });
      String playersTableName = 'players_profil'+profilString;
      // String playersTableName = 'playersszereda';
      String teamsTableName = 'teams_profil'+profilString;
      if (profilString=='playersszereda'){
        playersTableName = 'playersszereda';
      }
      if (playersTableName == 'playersszereda') {
        myTeams = new Map<String, String>();

        myTeams.putIfAbsent(
            '5', () => 'Nyaradszereda2009');
        myTeams.putIfAbsent(
            '3', () => 'Nyaradszereda2011');
        myTeams.putIfAbsent(
            '4', () => 'Nyaradszereda2013');


        myTeams.putIfAbsent(
            '2', () => 'FKCS2008');
        myTeams.putIfAbsent(
            '6', () => 'FKCS2009');
        myTeams.putIfAbsent(
            '9', () => 'FKCS2010');
        myTeams.putIfAbsent(
            '7', () => 'FKCS2011');
        myTeams.putIfAbsent(
            '8', () => 'FKCS2013');
        // myTeams.putIfAbsent(
        //     '3', () => 'Cluj2011');
      }

      if (playersTableName != 'playersszereda') {
        FirebaseFirestore.instance.collection(teamsTableName).get().then((
            QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((element) {
            setState(() {
              myTeams = new Map<String, String>();
              teamsMapFromDbForRead = element['teams'] as Map;
              teamsMapFromDbForRead.forEach((key, value) {
                myTeams.putIfAbsent(
                    teamsMapFromDbForRead[key]['id'], () => teamsMapFromDbForRead[key]['name']);

              });
            });

            // SharedPreferencesHelper.setVideoMapForRead(videoMapFromDb);

          });
        });
      }

      FirebaseFirestore.instance.collection(playersTableName).get().then((QuerySnapshot querySnapshot) {


        querySnapshot.docs.forEach((element) {


          setState(() {
            myPlayers = new Map<String, MyPlayerElem>();
            playersMapFromDbForRead = element['players'] as Map;
            myPlayers = new Map<String, MyPlayerElem>();
            playersMapFromDbForRead.forEach((key, value) {

              if (playersTableName == 'playersszereda') {
                if (!key.startsWith("1")) {
                  myPlayers.putIfAbsent(
                      key, () =>
                      MyPlayerElem(playersMapFromDbForRead[key]['id'],
                          playersMapFromDbForRead[key]['name'],
                          key.substring(0, 1)));
                }
              } else {
                myPlayers.putIfAbsent(
                    key, () =>
                    MyPlayerElem(playersMapFromDbForRead[key]['id'],
                        playersMapFromDbForRead[key]['name'],
                        playersMapFromDbForRead[key]['team_id']));
              }

            });

          });

          // SharedPreferencesHelper.setVideoMapForRead(videoMapFromDb);

        });
      });
    });


    super.initState();
  }
  waitForSometime() {
    print("waitForSometime");
    Future.delayed(Duration(seconds: 2));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state.toString() == "AppLifecycleState.paused" ||
        state.toString() == "AppLifecycleState.inactive" ||
        state.toString() == "AppLifecycleState.detached" ||
        state.toString() == "AppLifecycleState.suspending ") {
      if (!videoRepo.homeCon.value.showFollowingPage.value) {
        videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
      } else {
        videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
      }
      print("Print minimized");
    } else {
      print("Print maximized");
      if (!videoRepo.homeCon.value.showFollowingPage.value) {
        videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.play();
      } else {
        videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.play();
      }
    }
  }
  @override
  dispose() async {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    if (!videoRepo.homeCon.value.showFollowingPage.value) {
      videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
    } else {
      videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
    }
    if (!videoRepo.firstLoad.value) {
      int count = 0;
      if (videoRepo.homeCon.value.videoControllers.length > 0) {
        videoRepo.homeCon.value.videoControllers.forEach((key, value) async {
          if (value!=null)
            print('DISPOSE 1');
          await value.dispose();
          print('DISPOSE 1<');
          videoRepo.homeCon.value.videoControllers.remove(videoRepo.videosData.value.videos.elementAt(count).url);
          videoRepo.homeCon.value.initializeVideoPlayerFutures.remove(videoRepo.videosData.value.videos.elementAt(count).url);
          videoRepo.homeCon.notifyListeners();
          count++;
        });
      }
      int count1 = 0;
      if (videoRepo.homeCon.value.videoControllers2.length > 0) {
        videoRepo.homeCon.value.videoControllers2.forEach((key, value) async {
          if (value!=null)
            print('DISPOSE 2');
          await value.dispose();
          print('DISPOSE 2<');
          videoRepo.homeCon.value.videoControllers2.remove(videoRepo.followingUsersVideoData.value.videos.elementAt(count1));
          videoRepo.homeCon.value.initializeVideoPlayerFutures2.remove(videoRepo.followingUsersVideoData.value.videos.elementAt(count1));
          count1++;
        });
      }
    } else {
      videoRepo.firstLoad.value = false;
      videoRepo.firstLoad.notifyListeners();
      videoRepo.homeCon.value.playController(0);
    }
    print('DISPOSE 3');
    musicAnimationController.dispose(); // you need this
    print('DISPOSE 3<');
    super.dispose();
  }

  validateForm(Video videoObj, context) {
    if (videoRepo.homeCon.value.formKey.currentState.validate()) {
      videoRepo.homeCon.value.formKey.currentState.save();
      videoRepo.homeCon.value.submitReport(videoObj, context);
    }
  }

  reportLayout(context, Video videoObj) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ValueListenableBuilder(
            valueListenable: videoRepo.homeCon.value.showReportMsg,
            builder: (context, showMsg, _) {
              return AlertDialog(
                title: showMsg
                    ? Text("REPORT SUBMITTED!",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ))
                    : Text("REPORT",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        )),
                insetPadding: EdgeInsets.zero,
                content: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: videoRepo.homeCon.value.formKey,
                  child: !showMsg
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  canvasColor: Color(0xff000000),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButtonFormField(
                                    isExpanded: true,
                                    // hint: new Text("Select Type", textAlign: TextAlign.center),
                                    iconEnabledColor: Colors.black,
                                    style: new TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.0,
                                    ),
                                    value: videoRepo.homeCon.value.selectedType,
                                    onChanged: (newValue) {
                                      setState(() {
                                        videoRepo.homeCon.value.selectedType = newValue;
                                      });
                                    },
                                    validator: (value) => value == null ? 'This field is required!' : null,
                                    items: videoRepo.homeCon.value.reportType.map((String val) {
                                      return new DropdownMenuItem(
                                        value: val,
                                        child: new Text(
                                          val,
                                          style: new TextStyle(color: Colors.black),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                            TextFormField(
                              maxLines: 4,
                              decoration: InputDecoration(
                                labelText: 'Description',
                              ),
                              onChanged: (String val) {
                                _con.description = val;
                              },
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  // onTap: () {
                                  //   try {
                                  //     if (WidgetsBinding!=null)
                                  //     WidgetsBinding.instance
                                  //         ?.addPostFrameCallback((_) async {
                                  //       setState(() {
                                  //         if (!videoRepo.homeCon.value
                                  //             .showReportLoader.value) {
                                  //           validateForm(videoObj, context);
                                  //         }
                                  //       });
                                  //     });
                                  //   }catch(e){
                                  //
                                  //   }
                                  // },
                                  child: Container(
                                    height: 30,
                                    width: 60,
                                    decoration: BoxDecoration(gradient: Gradients.blush),
                                    child: ValueListenableBuilder(
                                        valueListenable: videoRepo.homeCon.value.showReportLoader,
                                        builder: (context, reportLoader, _) {
                                          return Center(
                                            child: (!reportLoader)
                                                ? Text(
                                                    "Submit",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 11,
                                                      fontFamily: 'RockWellStd',
                                                    ),
                                                  )
                                                : Helper.showLoaderSpinner(Colors.white),
                                          );
                                        }),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (!videoRepo.homeCon.value.showFollowingPage.value) {
                                      _con.videoController(videoRepo.homeCon.value.swiperIndex).play();
                                    } else {
                                      _con.videoController2(videoRepo.homeCon.value.swiperIndex2).play();
                                    }
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 60,
                                    decoration: BoxDecoration(gradient: Gradients.blush),
                                    child: Center(
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          fontFamily: 'RockWellStd',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width - 100,
                              child: Center(
                                child: Text(
                                  "Thanks for reporting.If we find this content to be in violation of our Guidelines, we will remove it.",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                ),
              );
            });
      },
    );
  }

  bool visiblePlus5sec = false;
  bool visibleMinus5sec = false;
  Future<void> seekTo(VideoPlayerController vc) async {
//    if (_isDisposed) {
//      return;
//    }
//    VideoPlayerController vc = video.controller;//(controllersRules[_tabControllerIndex] == 0?_videoController:controllersRules[_tabControllerIndex] == 1 ? _videoController1:_videoController2);
    if ((vc.value.position+new Duration(milliseconds: 5000)) > vc.value.duration) {
      await vc.seekTo(Duration(seconds: 0, minutes: 0, hours: 0));
      await Future.delayed(Duration(seconds: 1)).whenComplete(()  {
        setState(() {
          visiblePlus5sec = false;
        });
      });
    } else if (vc.value.position < const Duration()) {
      await vc.seekTo(Duration(seconds: 0, minutes: 0, hours: 0));
      await Future.delayed(Duration(seconds: 1)).whenComplete(()  {
        setState(() {
          visiblePlus5sec = false;
        });
      });
    } else {
      await vc.seekTo(vc.value.position+new Duration(milliseconds: 5000));
      await Future.delayed(Duration(seconds: 1)).whenComplete(()  {
        setState(() {
          visiblePlus5sec = false;
        });
      });
    }

  }
  Future<void> seekToBackward(VideoPlayerController vc) async {
//    if (_isDisposed) {
//      return;
//    }
//    VideoPlayerController vc = (controllersRules[_tabControllerIndex] == 0?_videoController:controllersRules[_tabControllerIndex] == 1 ? _videoController1:_videoController2);

    print("backward");
    if ((vc.value.position) > vc.value.duration) {

      await vc.seekTo(Duration(seconds: 0, minutes: 0, hours: 0));
      await Future.delayed(Duration(seconds: 1)).whenComplete(()  {
        setState(() {

          visibleMinus5sec = false;
        });
      });
    } else if (vc.value.position-new Duration(milliseconds: 5000) < const Duration()) {
      await vc.seekTo(Duration(seconds: 0, minutes: 0, hours: 0));
      await Future.delayed(Duration(seconds: 1)).whenComplete(()  {
        setState(() {

          visibleMinus5sec = false;
        });
      });
    } else {
      await vc.seekTo(vc.value.position-new Duration(milliseconds: 5000));
      await Future.delayed(Duration(seconds: 1)).whenComplete(()  {
        setState(() {

          visibleMinus5sec = false;
        });
      });
    }

  }
  Widget build(BuildContext context) {
    print("BottomPAD");
    final viewInsets = EdgeInsets.fromWindowPadding(WidgetsBinding.instance.window.viewInsets, WidgetsBinding.instance.window.devicePixelRatio);
    if (viewInsets.bottom == 0.0) {
      if (_con.bannerShowOn.indexOf("1") > -1) {
        _con.paddingBottom = Platform.isAndroid ? 50.0 : 80.0;
      } else {
        _con.paddingBottom = 0;
      }
    } else {
      _con.paddingBottom = 0;
    }
    return Material(
      child: Scaffold(
        // key: _con.scaffoldKey,
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                // if (!videoRepo.homeCon.value.showFollowingPage.value) {
                //   videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                // } else {
                //   videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
                // }
                // _con.getVideosByFilter(filter1, myPlayers, (){
                //   SharedPreferencesHelper.getFilteredIds().then((value) {
                //     setState(() {
                //       print('ppp filterids callback utan2 '+value.toString());
                //       filteredIds= value;
                //       oldRatings = List.filled(filteredIds.length, "");
                //       mergeSelects = List.filled(filteredIds.length, true);
                //     });
                //
                //   });
                // }, mSelectedProfile);
                // Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                await FullScreen.enterFullScreen(FullScreenMode.EMERSIVE_STICKY);

                return;
              },
              child: Container(
                padding: new EdgeInsets.only(bottom: videoRepo.homeCon.value.paddingBottom),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    homeWidget(),
                    (!videoRepo.homeCon.value.hideBottomBar)
                        ? Positioned(
                            bottom: 0,
                            width: MediaQuery.of(context).size.width,
                            child: bottomToolbarWidget(
                              videoRepo.homeCon.value.index,
                              videoRepo.homeCon.value.pc3,
                              videoRepo.homeCon.value.pc2,
                            ),
                          )
                        : SizedBox(
                            height: 0,
                          ),

                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child:
              Container(
                margin:EdgeInsets.only(top: 40, right: 15),
                height: 65.0,
                width: 65.0,
                child:InkWell(
                  child: Container(
                    height: 65.0,
                    width: 65.0,
                    child: Stack(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: Colors.white,
                          size: 50,
                        ),
                        Positioned(bottom:10,right:4,child: Text(
                          (videoRepo.homeCon.value.swiperIndex+1).toString()+"/"+filteredIds.length.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                            fontSize: 12
                          ),
                        ))
                      ],
                    ),
                  ),

                    //
                    // onLongPress: () async {
                    //   setState(() {
                    //     showAdminDialog = true;
                    //     showMergeDialog = false;
                    //   });
                    //   await SharedPreferencesHelper.setShowMerge(false);
                    // },
                    onTap: () async {
                      // SharedPreferencesHelper.getNeedPIN().then((value) async {
                      //   if (value) {
                      //     _displayTextInputDialog(context).whenComplete(() async {
                      //       if (valuePIN == '1010') {
                      //         searchStart();
                      //       }
                      //
                      //     });
                      //   } else {
                      //     searchStart();
                      //   }
                      // });
                      searchStart();//gernyeszeghez


                    }
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child:
              Container(
                margin:EdgeInsets.only(top: 35, right: 80),
                height: 48.0,
                child: Text(
                  /*"More videos: "*/"",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14
                  ),
                ),
              ),
            ),
            // Positioned(
            //   bottom: actualVideo !=null?0:60,
            //   child: videoRepo.videosData.value.videos!=null && videoRepo.homeCon.value !=null && videoRepo.homeCon.value.swiperIndex!=null&&
            //   videoRepo.videosData.value.videos.length>videoRepo.homeCon.value.swiperIndex?actualVideo !=null?new VideoDescription(
            //       actualVideo !=null?actualVideo:videoRepo.videosData.value.videos.elementAt(videoRepo.homeCon.value.swiperIndex),
            //       videoRepo.homeCon.value.pc3,(editableTag) {
            //     // print("callbackrekatt videoRepo.homeCon.value.swiperIndex" +videoRepo.homeCon.value.swiperIndex.t);
            //     // print("callbackrekatt main." +editableTag);
            //     setState(() {
            //       // video.videos.elementAt(index).username = "hhh";
            //       actualVideoElemIdx = videoRepo.homeCon.value.swiperIndex;
            //     });
            //
            //     VideoItemElem vie = videoRepo.videosData.value.videos.elementAt(videoRepo.homeCon.value.swiperIndex).videoElem;
            //     initDialog(vie!=null?vie.name:"");
            //     editPlayerAndType(vie, editableTag);
            //   }
            //   ):new VideoDescription(
            //       actualVideo !=null?actualVideo:videoRepo.videosData.value.videos.elementAt(videoRepo.homeCon.value.swiperIndex),
            //       videoRepo.homeCon.value.pc3,(editableTag) {
            //     // print("callbackrekatt videoRepo.homeCon.value.swiperIndex" +videoRepo.homeCon.value.swiperIndex.t);
            //     // print("callbackrekatt main." +editableTag);
            //     setState(() {
            //       // video.videos.elementAt(index).username = "hhh";
            //       actualVideoElemIdx = videoRepo.homeCon.value.swiperIndex;
            //     });
            //
            //     VideoItemElem vie = videoRepo.videosData.value.videos.elementAt(videoRepo.homeCon.value.swiperIndex).videoElem;
            //     initDialog(vie!=null?vie.name:"");
            //     editPlayerAndType(vie, editableTag);
            //   }
            //   ):Container(),
            // ),
            showMergeDialog?buildMergeDialog():Container(),
            showMergeDialog?buildMergeCheck():Container(),
            showAdminDialog?buildAdminDialog():Container(),
            // buildArrowNavigation(true),//web buildhez
            buildAdminMenuButton(),
            // buildFullScreenButton(),
      Positioned(
        bottom: 0,
        child:
            videoRepo.videosData.value.videos!=null && videoRepo.homeCon.value !=null && videoRepo.homeCon.value.swiperIndex!=null&&
                videoRepo.videosData.value.videos.length>videoRepo.homeCon.value.swiperIndex?false/*actualVideo !=null*/?
            buildDescriptionPart(actualVideo.username, actualVideo.description, (editableTag) {
              setState(() {
                // video.videos.elementAt(index).username = "hhh";
                actualVideoElemIdx = videoRepo.homeCon.value.swiperIndex;
              });

              VideoItemElem vie = actualVideo.videoElem;
              initDialog(vie!=null?vie.name:"");
              print('vieeeeeee actualVideo:'+vie.name);
              editPlayerAndType(vie, editableTag);
            })
                :buildDescriptionPart(videoRepo.videosData.value.videos.elementAt(videoRepo.homeCon.value.swiperIndex).username,videoRepo.videosData.value.videos.elementAt(videoRepo.homeCon.value.swiperIndex).description, (editableTag) {
              setState(() {
                // video.videos.elementAt(index).username = "hhh";
                actualVideoElemIdx = videoRepo.homeCon.value.swiperIndex;
              });

              VideoItemElem vie = videoRepo.videosData.value.videos.elementAt(videoRepo.homeCon.value.swiperIndex).videoElem;

              print('vieeeeeee:'+vie.name);
              if (videoRepo.homeCon.value.swiperIndex >= actualVideoElemName.length) {
                actualVideoElemName.add("");
              }
              // if (videoRepo.homeCon.value.swiperIndex >= oldRatings.length) {
              //   oldRatings.add("0");
              // }

              if(actualVideoElemName[actualVideoElemIdx]!="") {
                print('actualVideoElem.name:' + actualVideoElemName[actualVideoElemIdx]);
                videoRepo.videosData.value.videos.elementAt(videoRepo.homeCon.value.swiperIndex).videoElem.name = actualVideoElemName[actualVideoElemIdx];
                initDialog(actualVideoElemName[actualVideoElemIdx]);
              } else {
                initDialog(vie!=null?vie.name:"");
              }
              editPlayerAndType(vie, editableTag);
            })
                :Container()),
            isOpenedFilterWindow?filterProgressVisibility?
            Stack(
              children: [
                infoAblak(),
                Container(height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                  color: Colors.black45,
                  child: Center(
                    child: Container(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                )
              ],
            )



                :infoAblak():Container(),
            // showTypesDialog?InkWell(
            //   onTap: () {
            //     setState(() {
            //       showTypesDialog = false;
            //     });
            //   },
            //   child: Container(
            //     color:Colors.black.withOpacity(0.25),
            //     height: MediaQuery.of(context).size.height,
            //     width: MediaQuery.of(context).size.width,
            //   ),
            // ):Container(),
             showTypesDialog?typesDialog('type',actualVideoElem.id, actualVideoElemName[actualVideoElemIdx]!=""?actualVideoElemName[actualVideoElemIdx]:actualVideoElem.name, () {

              setState(() {showTypesDialog = false;});

             }):Container(),
             showRatingDialog?typesDialog('rating',actualVideoElem.id, actualVideoElemName[actualVideoElemIdx]!=""?actualVideoElemName[actualVideoElemIdx]:actualVideoElem.name, () {

              setState(() {showRatingDialog = false;});

             }):Container(),
            // showNamesDialog?InkWell(
            //   onTap: () {
            //     setState(() {
            //       showNamesDialog = false;
            //     });
            //   },
            //   child: Container(
            //     color:Colors.black.withOpacity(0.25),
            //     height: MediaQuery.of(context).size.height,
            //     width: MediaQuery.of(context).size.width,
            //   ),
            // ):Container(),
            showNamesDialog?typesDialog('name',actualVideoElem.id,  actualVideoElemName[actualVideoElemIdx]!=""?actualVideoElemName[actualVideoElemIdx]:actualVideoElem.name, () {

              setState(() {showNamesDialog = false;});

            }):Container(),
          ],
        ),
      ),
    );
  }

  Future<void> searchStart() async {
    await SharedPreferencesHelper.setLastVideosResponse('');
    await SharedPreferencesHelper.setDeepLinkIds(<String>[]);
    setState(() {
      showAdminDialog = false;
      showMergeDialog = false;
      SharedPreferencesHelper.setShowMerge(false);
      mergeSelects = List.filled(filteredIds.length, true);
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String recentMeccsekString = await prefs.getString("recentMeccsek");
    setState(() {
      if (recentMeccsekString!=null && recentMeccsekString!="") {
        if (recentMeccsekString.contains(";")) {
          List<String> st = recentMeccsekString.split(";");
          for (String s in st) {
            if (!s.contains("U9")&&!s.contains("U13")&&!s.contains("TEST1-TEST2"))
              filterableMatches.add(s);
          }
        } else {
          filterableMatches.add(recentMeccsekString);
        }
      }
//                          filterableMatches = filterableMatches.reversed.toList();
    });

    setState(() { isOpenedFilterWindow = true;});
    print('xxxxxxxxxxxxxxx'+isOpenedFilterWindow.toString());
    if (!videoRepo.homeCon.value.showFollowingPage.value) {
      videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
    } else {
      videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
    }
  }
  Widget buildMergeCheck() {
    return Positioned(
      top:0,
      left: 0,
      child: InkWell(
        onTap: () {
          setState(() {

            bool b = mergeSelects[actualVideoElemIdx];
            mergeSelects[actualVideoElemIdx] = !b;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 5),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(15.0),
              color:  Colors.black87.withOpacity(0.7),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
              child: Row(
                children: [
                  Text(
                    "Legyen benne\nez a jelenet?",
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 10,),
                  Container(
                    width:40,
                    height:40,
                    child: Stack(
                      children: [
                        Center(child: Icon(Icons.check , size: 30.0, color:  mergeSelects[actualVideoElemIdx] ?Colors.green:Colors.grey)),
                        Positioned(bottom:0,right:0,child: Text(
                          mergeSelects.where((element) => element).length.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                          ),
                        )),
                      ]
                    ),
                  )

                ],
              ),
            ),

          ),
        ),
      ),
    );
  }
  Widget buildAdminDialog() {
    return Positioned(
      top:10,
      left: 0,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 30, horizontal: 5),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(15.0),
                color:  Colors.black87.withOpacity(0.7),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  //   Row(
                  //
                  //     children: [
                  //         videoRepo.videosData!=null && videoRepo.videosData.value!=null && videoRepo.videosData.value.videos!=null
                  //             && videoRepo.homeCon!=null && videoRepo.homeCon.value!=null && videoRepo.homeCon.value.swiperIndex!=null&& videoRepo.videosData.value.videos.length>videoRepo.homeCon.value.swiperIndex?
                  //       Text(
                  // filteredIds.length.toString()+" / "+videoRepo.videosData.value.videos.length.toString()+" / "+(videoRepo.homeCon.value.swiperIndex+1).toString()+" / "+videoRepo.videosData.value.videos[videoRepo.homeCon.value.swiperIndex].videoId.toString(),
                  //         style: TextStyle(
                  //           fontWeight: FontWeight.normal,
                  //           color: Colors.white,
                  //         ),
                  //       ):Text(
                  //         "n/a",
                  //         style: TextStyle(
                  //           fontWeight: FontWeight.normal,
                  //           color: Colors.white,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                    SizedBox(height: 10,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              showAdminDialog = false;
                              if (videoRepo.videosData!=null && videoRepo.videosData.value!=null && videoRepo.videosData.value.videos!=null
                                  && videoRepo.homeCon!=null && videoRepo.homeCon.value!=null && videoRepo.homeCon.value.swiperIndex!=null&& videoRepo.videosData.value.videos.length>videoRepo.homeCon.value.swiperIndex){
                                deleteVideo(videoRepo.videosData.value.videos[videoRepo.homeCon.value.swiperIndex].videoId.toString()).then((data1) async {
                                  Fluttertoast.showToast(msg: "Töröltük a jelenetet.\nA legközelebbi kereséskor már nem találod.", toastLength: Toast.LENGTH_LONG );

                                });
                              }

                            });
                          },
                          child:  Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0),
                            child: Row(
                              children: [
                                Text(
                                  "Törlés",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 10,),
                              ],
                            ),
                          ),
                        ),

                        InkWell(
                          onTap: () {
                            SharedPreferencesHelper.setShowMerge(true).whenComplete(() {
                              if (!videoRepo.homeCon.value.showFollowingPage.value) {
                                videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                              } else {
                                videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
                              }
                              _con.getVideosByFilter(filter1, myPlayers, (){
                                SharedPreferencesHelper.getFilteredIds().then((value) {
                                  setState(() {

                                    filteredIds= value;
                                    oldRatings = List.filled(filteredIds.length, "");
                                    mergeSelects = List.filled(filteredIds.length, true);
                                  });

                                });
                              }, mSelectedProfile);
                              Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);

                              return;
                            });
                            setState(() {
                              showAdminDialog = false;
                            });

                          },
                          child:  Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0),
                            child: Row(
                              children: [
                                Text(
                                  "Összefoglaló/Megosztás",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 10,),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              showAdminDialog = false;
                            });
                          },
                          child:  Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0),
                            child: Row(
                              children: [
                                Text(
                                  "Mégsem",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 10,),
                              ],
                            ),
                          ),
                        ),

                        InkWell(
                          onTap: () {
                            setState(() {
                              showAdminDialog = false;
                              if (videoRepo.videosData!=null && videoRepo.videosData.value!=null && videoRepo.videosData.value.videos!=null
                                  && videoRepo.homeCon!=null && videoRepo.homeCon.value!=null && videoRepo.homeCon.value.swiperIndex!=null&& videoRepo.videosData.value.videos.length>videoRepo.homeCon.value.swiperIndex){
                                deleteVideo(videoRepo.videosData.value.videos[videoRepo.homeCon.value.swiperIndex].videoId.toString()).then((data1) async {
                                  Fluttertoast.showToast(msg: "Töröltük a jelenetet.\nA legközelebbi kereséskor már nem találod.", toastLength: Toast.LENGTH_LONG );

                                });
                              }

                            });
                          },
                          child:  Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0),
                            child: Row(
                              children: [
                                Text(
                                  videoRepo.videosData!=null && videoRepo.videosData.value!=null && videoRepo.videosData.value.videos!=null
                            && videoRepo.homeCon!=null && videoRepo.homeCon.value!=null && videoRepo.homeCon.value.swiperIndex!=null&& videoRepo.videosData.value.videos.length>videoRepo.homeCon.value.swiperIndex?videoRepo.videosData.value.videos[videoRepo.homeCon.value.swiperIndex].videoId.toString():""
                          ,style:TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 10,),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),

            ),
          ),

        ],
      ),
    );
  }
 /* void exitFullScreen() {
    html.document.exitFullscreen();
  }
  void goFullScreen() {
    html.document.documentElement.requestFullscreen();
  }*/
  Widget buildArrowNavigation(bool next) {
    return Positioned(
      left:0,
      right:0,
      bottom: 0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Container(
            child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(15.0),
                  color:  Colors.black87.withOpacity(0.7),
                ),
                child: InkWell(
                    onTap:() {
                      if (videoRepo.homeCon.value.swiperIndex>0) {
                      videoRepo.homeCon.value.swipeController.previous(
                          animation: true);
                      }
                    },
                    child:  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
                      child: Row(
                        children: [
                          // Text(
                          //   "Előző",
                          //   style: TextStyle(
                          //     fontWeight: FontWeiwght.normal,
                          //     color: Colors.white,
                          //   ),
                          // ),
                          Icon(Icons.arrow_circle_down_outlined , size: 50.0, color: Colors.white)
                        ],
                      ),
                    )
                )

            ),
          ),

          SizedBox(width: 20,),
          Container(
            child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(15.0),
                  color:  Colors.black87.withOpacity(0.7),
                ),
                child: InkWell(
                    onTap:() {
                      if (videoRepo.homeCon.value.swiperIndex<(filteredIds.length-1)) {
                        videoRepo.homeCon.value.swipeController.next(
                            animation: true);
                      }
                    },
                    child:  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
                      child: Row(
                        children: [
                          // Text(
                          //   "Következő",
                          //   style: TextStyle(
                          //     fontWeight: FontWeight.normal,
                          //     color: Colors.white,
                          //   ),
                          // ),
                          Icon(Icons.arrow_circle_up_outlined , size: 50.0, color: Colors.white)

                        ],
                      ),
                    )
                )

            ),
          ),

        ],
      ),
    );
  }

  TextEditingController _textFieldController = new TextEditingController();
  String valuePIN = "";
  String valuePINtmp = "";
  Future<void> _displayTextInputDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Adminisztrátor PIN szükséges'),
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


  Widget buildAdminMenuButton() {
    return Positioned(
      top:10,
      left: 0,
      child: InkWell(
        onTap: () async {
          SharedPreferencesHelper.getNeedPIN().then((value) async {
            if (value) {
              _displayTextInputDialog(context).whenComplete(() async {
                if (valuePIN == '1010') {
                  setState(() {

                    showAdminDialog = true;
                    showMergeDialog = false;
                  });
                  await SharedPreferencesHelper.setShowMerge(false);
                }

              });
            } else {
              setState(() {

                showAdminDialog = true;
                showMergeDialog = false;
              });
              await SharedPreferencesHelper.setShowMerge(false);
            }
          });


        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(Icons.more_vert_rounded,  size: 20.0, color: Colors.white),
        ),
      )
    );
  }
  /*Widget buildFullScreenButton() {
    return Positioned(
      top:10,
      right: 0,
      child: InkWell(
        onTap: () async {
          if (!isFullScreen) {
            setState(() {isFullScreen = true;});
            goFullScreen();
          } else {
            exitFullScreen();
            setState(() {isFullScreen = false;});
          }
        },
        child: Row(
          children: [
            isFullScreen?Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.fullscreen_exit,  size: 20.0, color: Colors.white),
            ):Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.fullscreen,  size: 20.0, color: Colors.white),
            )
          ],
        ),
      )
    );
  }*/



  Future<bool> deleteVideo(String deletableId, [String defaultFilter])  async {

    try {
      log('200 mSelectedProfile1 ' +mSelectedProfile);
      var headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImV4cCI6MTY5MDUzMjg1OSwiaWF0IjoxNjU4OTk2ODU5fQ.LiAvXxwjHI3sZfCJS5MBDoaG9MBzq6E4bErPLF8Jd80'

      };
      if (mSelectedProfile!=null && (mSelectedProfile.contains("FKCS2008")||mSelectedProfile=='playersszereda')){
        headers = {
          'Accept': 'application/json',
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImV4cCI6MTY5Mjc2OTAwMiwiaWF0IjoxNjYxMjMzMDAyfQ.5PCJFMXlCnZRvJnNkEpxEI_1Cks2kRDGbiR5KCdEOXc'

        };
      }
      var url =
          "https://api.backrec.eu"+"/video/"+deletableId.toString();
      var response = await http.delete(url, headers: headers)
          .timeout(const Duration(seconds: 30));
      print('111111 http.delete ' + url);
      if (response.statusCode == 200) {

        return true;
      } else {
        print('333333 BR videos ' + response.statusCode.toString());
        throw Exception(response.statusCode.toString()+'<statuscode');
      }
    } on TimeoutException catch (_) {
      print('Timeout??? ');
      throw Exception('Timeout');
      // A timeout occurred.
    } on Exception catch (_) {
      print('Exception?????'+_.toString());
      throw Exception(_.toString());
      // A timeout occurred.
    } catch (exception){
      print('SEVERHIBAAA');
      print('SEVERHIBAAA:'+exception.toString());
      throw Exception(exception.toString());
    }


    return false;


  }
  List encondeToJson(List<String> list) {
    List jsonList = List();
    list.map((item) => jsonList.add(item)).toList();
    return jsonList;
  }
  Future<bool> mergeVideo(String mergeNev, [String defaultFilter])  async {

    if (filteredIds.length ==0 || !mergeSelects.contains(true)) {
      return false;
    }
    try {

      List<dynamic  > idsA = <dynamic>[];
      String ids = "";
      for (int i =0; i< filteredIds.length;i++){
        if (mergeSelects[i]){
          if (ids!=""){
            ids+=",";
          }
          ids+=filteredIds[i];
          idsA.add(filteredIds[i]);
        }
      }
      ids+="";
      log('200 mSelectedProfile3 ' +mSelectedProfile);

      var headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImV4cCI6MTY5MDUzMjg1OSwiaWF0IjoxNjU4OTk2ODU5fQ.LiAvXxwjHI3sZfCJS5MBDoaG9MBzq6E4bErPLF8Jd80'

      };
      if (mSelectedProfile!=null  && (mSelectedProfile.contains("FKCS2008")||mSelectedProfile=='playersszereda')){
        headers = {
          'Accept': 'application/json',
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImV4cCI6MTY5Mjc2OTAwMiwiaWF0IjoxNjYxMjMzMDAyfQ.5PCJFMXlCnZRvJnNkEpxEI_1Cks2kRDGbiR5KCdEOXc'

        };
      }
      // var jsonB = {
      // 'ids': encondeToJson(idsA),
      // 'name': 'highlight'
      // };
      String name =  DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())+"m";
      name = name.replaceAll(":", "h ");
      // name = name.replaceAll(" - ", " ");
      name = mergeNev+"  " +name;
      log('merge ids:'+ids);
      var body =  {
        'ids': ids,
        'name': name
      };

      // MergeBodyElem mergeBodyElem = new MergeBodyElem(ids: idsA, name: 'valogatott');
      // var body = jsonEncode({
      //   'ids': json.encode(ids),
      //   'name': 'highlight'
      //
      // });
      // String sbody = "{'ids':"+ids+",'name' : 'Válogatás'}";
      // var body = json.encode( sbody);
      // // var body = "{\"ids\":"+ids+",\"name\" : \"Válogatás\"}";
      print('body :::'+body.toString());
      var url =
          "https://api.backrec.eu"+"/video/merge";
      var response = await http.post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 30));
      print('111111 http.merge ' + response.statusCode.toString());
      if (response.statusCode == 200) {

        return true;
      } else {
        print('333333 BR videos ' + response.statusCode.toString());
        throw Exception(response.statusCode.toString()+'<statuscode');
      }
    } on TimeoutException catch (_) {
      print('Timeout??? ');
      throw Exception('Timeout');
      // A timeout occurred.
    } on Exception catch (_) {
      print('Exception?????'+_.toString());
      throw Exception(_.toString());
      // A timeout occurred.
    } catch (exception){
      print('SEVERHIBAAA');
      print('SEVERHIBAAA:'+exception.toString());
      throw Exception(exception.toString());
    }


    return false;


  }
  Future<String> linkVideos()  async {

    String p = await SharedPreferencesHelper.getSelectedProfile();
    String starter = "?v=";
    if (p=="1"){
      starter = "?v1=";
    }
    String ids = starter;
    if (filteredIds.length ==0 || !mergeSelects.contains(true)) {
      return "";
    }
    try {

      for (int i =0; i< filteredIds.length;i++){
        if (mergeSelects[i]){
          if (ids!=starter){
            ids+=",";
          }
          ids+=filteredIds[i];
        }
      }
      ids+="";

    }  catch (_) {

    }
    return ids;


  }


  Widget buildMergeDialog() {
    return Positioned(
      top:0,
      right: 0,
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.black87.withOpacity(0.7),
              ),
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    InkWell(
                      onTap: () {

                      },
                      child: Container(
                        padding: EdgeInsets.only(bottom: 15),
                        child: Row(
                          children: [
                            Container(
                              width: 200,
                              child: TextFormField( controller: editednameController,

                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width:5),
                            Icon(Icons.edit,  size: 15.0, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      "Megoszthatod a kiválasztott listát.\nVagy készíthetsz összefoglalót belőle.",
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () async {
                            String lin = await linkVideos();
                            Clipboard.setData(ClipboardData(text: "https://app.backrec.eu/"+lin));

                            Fluttertoast.showToast(msg: "A kijelölt jelenetek linkjét a vágólapra helyeztük.", toastLength: Toast.LENGTH_LONG );


                          },
                          child: Text(
                            "Link",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 60,),
                        InkWell(
                          onTap: () async {
                            String lin = await linkVideos();
                            String path = await createQrPicture("https://app.backrec.eu/"+lin);
                            try {
                              await Share.shareFiles(
                                  [path],
                                  mimeTypes: ["image/png"],
                                  subject: 'My QR code',
                                  text: 'Please scan me'
                              );
                            }catch(e) {
                              print('eeee:'+e.toString());
                            }



                          },
                          child: Text(
                            "QR",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 60,),
                        InkWell(
                          onTap: () {
                            Fluttertoast.showToast(msg: "Válogatás videó készítése folyamatban...", toastLength: Toast.LENGTH_LONG );

                            String mergenev = "Válogatás";
                            try{
                              if (editednameController!=null && editednameController.text!=null && editednameController.text!=""){
                                mergenev = editednameController.text;
                              }else {
                                mergenev = "Válogatás";
                              }
                            } catch (e){

                            }
                            mergeVideo(mergenev).then((value) {
                              Fluttertoast.showToast(msg: "Hamarosan megtalálod a Vimeo-n.", toastLength: Toast.LENGTH_LONG );
                              setState(() { showMergeDialog = false;
                              SharedPreferencesHelper.setShowMerge(false);
                              mergeSelects = List.filled(filteredIds.length, true); });

                            });
                          },
                          child: Text(
                            "Összefoglaló",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),

                      ],
                    )

                  ],
                ),
              ),
            ),
          ),
          Positioned(
              top:17,
              right: 7,
              child:
              InkWell(
                onTap: () {
                  setState(() {
                    showMergeDialog = false;
                    SharedPreferencesHelper.setShowMerge(false);
                    mergeSelects = List.filled(filteredIds.length, true);
                  });
                },
                child: Icon(Icons.cancel_rounded , size: 25.0, color: Colors.white),
              ))
        ],
      ),
    );
  }
  Future<String> createQrPicture(String qr) async {
    print('xxxxxxx');
    final qrValidationResult = QrValidator.validate(
      data: qr,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );
    print('xxxxxxx 11');
    final qrCode = qrValidationResult.qrCode;
    final painter = QrPainter.withQr(
      qr: qrCode,
      color: const Color(0xFF000000),
      gapless: true,
      embeddedImageStyle: null,
      embeddedImage: null,
    );
    print('xxxxxxx 2222');
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    final ts = DateTime.now().millisecondsSinceEpoch.toString();
    String path = '$tempPath/$ts.png';
    print('xxxxxxx 3333');
    final picData = await painter.toImageData(2048, format: ui.ImageByteFormat.png);
    await writeToFile(picData, path);
    print('xxxxxxx 4444'+path);
    return path;
  }
  Future<void> writeToFile(ByteData data, String path) async {
    final buffer = data.buffer;
    await File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes)
    );
  }


  Widget buildDescriptionPart(String username, String description, Function(String) editClicked) {
    return Container(
      height: 120.0,
      padding: EdgeInsets.only(left: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[

              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [

                      InkWell(
                        onTap: () async {
                          await videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                          await videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
                          SharedPreferencesHelper.getNeedPIN().then((value) async {
                            if (value) {
                              _displayTextInputDialog(context).whenComplete(() async {
                                if (valuePIN == '1010') {
                                  editClicked('rating');
                                }
                              });

                            } else {
                              editClicked('rating');
                            }
                          });

                        },
                        child: (oldRatings.length>actualVideoElemIdx&& oldRatings[actualVideoElemIdx]!="")||(!description.contains("    ")||description.split("    ").length!=2)?Container(
                          padding: EdgeInsets.only(top: 20,right: 20, bottom: 10),
                          child: oldRatings.length==0||oldRatings[actualVideoElemIdx]=="" ||int.parse(oldRatings[actualVideoElemIdx]) == 0?Icon(
                            Icons.star_border_outlined,
                            color: Colors.white,
                            size: 20,
                          ):Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              oldRatings[actualVideoElemIdx]!="" &&int.parse(oldRatings[actualVideoElemIdx]) > 0?Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 20,
                              ):Container(),
                              oldRatings[actualVideoElemIdx]!="" &&int.parse(oldRatings[actualVideoElemIdx]) >1?Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 20,
                              ):Container(),
                              oldRatings[actualVideoElemIdx]!="" &&int.parse(oldRatings[actualVideoElemIdx]) > 2?Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 20,
                              ):Container(),
                              oldRatings[actualVideoElemIdx]!="" &&int.parse(oldRatings[actualVideoElemIdx]) > 3?Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 20,
                              ):Container(),/*
                              int.parse(oldRatings[actualVideoElemIdx]) > 4?Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 20,
                              ):Container(),*/
                            ],
                          ),
                        ):Container(
                          padding: EdgeInsets.only(top: 20,right: 20, bottom: 10),
                          child: int.parse(description.split("    ")[1]) == 0?Icon(
                            Icons.star_border_outlined,
                            color: Colors.white,
                            size: 20,
                          ):Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              int.parse(description.split("    ")[1]) > 0?Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 20,
                              ):Container(),
                              int.parse(description.split("    ")[1]) >1?Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 20,
                              ):Container(),
                              int.parse(description.split("    ")[1])> 2?Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 20,
                              ):Container(),
                              int.parse(description.split("    ")[1]) > 3?Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 20,
                              ):Container(),/*
                              int.parse(oldRatings[actualVideoElemIdx]) > 4?Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 20,
                              ):Container(),*/
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  username != ''
                      ? Row(
                    children: [
                      InkWell(
                        onTap: () async {
                          await videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                          await videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
                          print('velt egesz '+username);
                          editClicked('type');
                        },
                        child: Text(
                          username!=null && username.contains("    ") && username.split("    ").length>0?username.split("    ")[0]+"  ":username,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          await videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                          await videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
                          print('velt egesz');
                          editClicked('name');
                        },
                        child: Text(
                          username!=null && username.contains("    ")&& username.split("    ").length>1?"  "+username.split("    ")[1]+"  ":"",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                    ],
                  )
                      : Container(),

                ],
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),Container(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[

                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    username != ''
                        ? Row(
                      children: [
                        Text(
                          description!=null?description.contains("    ")&&description.split("   ").length>0?description.split("   ")[0]:description:"#",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                      ],
                    )
                        : Container()
                  ],
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Video actualVideo;
  Future updateDB() async {

    FirebaseFirestore.instance.collection('history').get().then((QuerySnapshot querySnapshot) {

/*
      querySnapshot.docs.forEach((element) {


        Map<String, dynamic> videoMapFromDb = new Map<String, dynamic>();
        for (MapEntry<String, Object> o in element.data().entries) {
          String key = o.key.trim();
          Object value = o.value;
          if (key == 'videos') {
            videoMapFromDb = value as Map;
          }

        }

        SharedPreferencesHelper.getVideoMap().then((videoMapFromSh) {

          videoMapFromSh.forEach((key, valueFromSh) {
            if (videoMapFromDb.containsKey(key)) {
              int oldViews = videoMapFromDb[key]['views'];
              HistoryElem historyElem = new HistoryElem(  views: oldViews+valueFromSh['views'], lastview_date:valueFromSh['lastview_date'], likes: valueFromSh['likes'], loadings: valueFromSh['loadings'], seeks:valueFromSh['seeks']);

              videoMapFromDb.update(key, (value) => historyElem.toJson());
            } else {
              HistoryElem historyElem = new HistoryElem(  views: valueFromSh['views'], lastview_date:"", likes: 0, loadings: 0, seeks:0);

              videoMapFromDb.putIfAbsent(key, () => historyElem.toJson());
            }
          });

          //felrakni a dbbe az ujjat + nullazni a sharedet
          CollectionReference historyTable =
          FirebaseFirestore.instance.collection('history');


          historyTable.get().then((QuerySnapshot querySnapshot) {
            querySnapshot.docs.forEach((element) {
              historyTable.doc(element.id).get().then((documentSnapshot) {
                documentSnapshot.reference.update({'videos': videoMapFromDb}).then((value) {

                  SharedPreferencesHelper.setVideoMap(new Map<String, dynamic>()).then((value) {


                  });
                });
              });

            });
          });


        });



      });*/
      // SharedPreferencesHelper.setClinics(clinics);
    });




  }

  Widget bottomToolbarWidget(index, PanelController pc3, PanelController pc2) {
    {
      return Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [/*Colors.black12.withOpacity(0.1)*/Colors.transparent, Colors.transparent],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom:6, left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(),//TODO visszatenni a me gombot, ha kell
                      /*ValueListenableBuilder(
                        valueListenable: videoRepo.homeCon.value.showHomeLoader,
                        builder: (context, homeLoader, _) {
                          return IconButton(
                            alignment: Alignment.bottomCenter,
                            padding: EdgeInsets.all(0),
                            icon: Image.asset(
                              homeLoader ? 'assets/icons/reloading.gif' : 'assets/icons/me.png',
                              width: 25.0,
                            ),
                            onPressed: () async {
                              print('DISPOSE 4');
                              await _con.bannerAd.dispose();
                              print('DISPOSE 4<');
                              _con.bannerAd = null;
                              if (!homeLoader) {
                                if (!videoRepo.homeCon.value.showFollowingPage.value) {
                                  videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                                } else {
                                  videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
                                }
                                videoRepo.homeCon.value.userVideoObj.value['userId'] = 0;
                                videoRepo.homeCon.value.userVideoObj.value['videoId'] = 0;
                                videoRepo.homeCon.value.userVideoObj.value['name'] = "";
                                videoRepo.homeCon.value.userVideoObj.notifyListeners();
                                videoRepo.homeCon.value.showHomeLoader.value = true;
                                videoRepo.homeCon.value.showHomeLoader.notifyListeners();
                                await Future.delayed(
                                  Duration(seconds: 2),
                                );

                                Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                                _con.getVideos(myPlayers:myPlayers);
                              }
                            },
                          );
                        },
                      ),*/
                    ],
                  ),
                  Container(
                    child: IconButton(
                      padding: EdgeInsets.all(0),
                      icon:  Icon(
                        Icons.search_rounded,
                        color: Colors.green,
                        size: 0,
                      ),
                      onPressed: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String recentMeccsekString = await prefs.getString("recentMeccsek");
                        setState(() {
                          if (recentMeccsekString!=null && recentMeccsekString!="") {
                            if (recentMeccsekString.contains(";")) {
                              List<String> st = recentMeccsekString.split(";");
                              for (String s in st) {
                                if (!s.contains("U9")&&!s.contains("U13")&&!s.contains("TEST1-TEST2"))
                                filterableMatches.add(s);
                              }
                            } else {
                              filterableMatches.add(recentMeccsekString);
                            }
                          }
//                          filterableMatches = filterableMatches.reversed.toList();
                        });

                        setState(() { isOpenedFilterWindow = true;});
print('xxxxxxxxxxxxxxx'+isOpenedFilterWindow.toString());
                        if (!videoRepo.homeCon.value.showFollowingPage.value) {
                          videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                        } else {
                          videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
                        }

                      },
                    ),
                  ),
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     mainAxisSize: MainAxisSize.min,
//                     children: <Widget>[
//                       IconButton(
//                         alignment: Alignment.bottomCenter,
//                         padding: EdgeInsets.all(0),
//                         icon: Image.asset(
//                           'assets/icons/me.png',
//                           width: 0.0,
//                         ),
//                         onPressed: () async {
// //                          await _con.bannerAd.dispose();
// //                          _con.bannerAd = null;
// //                          if (!_con.showFollowingPage.value) {
// //                            _con.videoController(_con.swiperIndex)?.pause();
// //                          } else {
// //                            _con.videoController2(_con.swiperIndex2)?.pause();
// //                          }
// //                          setState(() {
// //                            videoRepo.homeCon.value.bannerAd?.dispose();
// //                            videoRepo.homeCon.value.bannerAd = null;
// //                            videoRepo.homeCon.value.paddingBottom = 0.0;
// //                          });
// //                          if (!videoRepo.homeCon.value.showFollowingPage.value) {
// //                            videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
// //                          } else {
// //                            videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
// //                          }
// //                          if (currentUser.value.token != null) {
// //                            Navigator.pushReplacementNamed(
// //                              context,
// //                              "/my-profile",
// //                            );
// //                          } else {
// //                            Navigator.pushReplacement(
// //                              context,
// //                              MaterialPageRoute(
// //                                builder: (context) => LoginPageView(userId: 0),
// //                              ),
// //                            );
// //                          }
//
//                         },
//                       ),
//                     ],
//                   ),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }





  List<int> listScene = [0, 0, 0, 0, 0, 0];
  List<String> filterNames = <String>[];
  List<String> filterTeams = <String>[];
  List<String> filterTipusok = <String>[];
   String  quality = 'HD_720p';
   String  _rangeStart = '';
   String  _rangeEnd = '';
   String  editedname = 'Válogatás';
  final editednameController = TextEditingController();
   bool  lockMentes = false;
   bool  filterProgressVisibility = false;
  List<String> filterMatches = <String>[];
  List<String> filteredIds = <String>[];
  List<String> filterStarsStates = ['1','1','1','1','1'];
  List<int> filterTeamsStates = [0, 0];
  double kFontSizeInfoTartalom = 17.0;
  int infoOpenedState = 10;
  double _lowerValueFormatter = 20.0;
  double _upperValueFormatter = 90.0;
  RangeLabels labels =RangeLabels('1', "700");
  RangeValues values = RangeValues(1, 700);
  double _lowerValue = 50;
  double _upperValue = 180;
  int actVidIndex = 0;
  Widget infoAblak() {
    return
      AnimatedOpacity(
        opacity: infoOpenedState == 10 ? 1.0 : 0.0,
        duration: Duration(milliseconds: 1300),
        child:
        Container(

            padding: EdgeInsets.only(left: 20, top: 4, bottom: 0),
            height: MediaQuery
                .of(context)
                .size
                .height,
            width: MediaQuery
                .of(context)
                .size
                .width,
            color: infoOpenedState == 10 ? Colors.white.withOpacity(0.87) : Colors.black.withOpacity(0.92),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
               /* Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      padding: EdgeInsets.only(left: 0, top: 40, bottom: 0),
                      child:
                      FlutterSlider(
                        values: [1000, 15000],
                        rangeSlider: true,

//rtl: true,
//                        ignoreSteps: [
//                          FlutterSliderIgnoreSteps(from: 8000, to: 12000),
//                          FlutterSliderIgnoreSteps(from: 18000, to: 22000),
//                        ],
                        max: 25000,
                        min: 0,
                        step: FlutterSliderStep(step: 100),

                        jump: true,

                        trackBar: FlutterSliderTrackBar(
                          activeTrackBarHeight: 2,
                          activeTrackBar: BoxDecoration(color: Colors.brown),
                        ),
                        tooltip: FlutterSliderTooltip(
                          textStyle: TextStyle(fontSize: 17, color: Colors.red),
                        ),
                        handler: FlutterSliderHandler(
                          decoration: BoxDecoration(),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.brown,
                                borderRadius: BorderRadius.circular(25)),
                            padding: EdgeInsets.all(10),
                            child: Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25)),
                            ),
                          ),
                        ),
                        rightHandler: FlutterSliderHandler(
                          decoration: BoxDecoration(),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.brown,
                                borderRadius: BorderRadius.circular(25)),
                            padding: EdgeInsets.all(10),
                            child: Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25)),
                            ),
                          ),
                        ),
                        disabled: false,

                        onDragging: (handlerIndex, lowerValue, upperValue) {
                          _lowerValue = lowerValue;
                          _upperValue = upperValue;
                          setState(() {});
                        },
                      )
                      *//*Text(
                        infoOpenedState == 10 ? "Állítsd kedved szerint a feltételeket, hogy csak azokat a videókat lásd, amikre kiváncsi vagy!" : infoOpenedState == 1
                            ? "Válaszd ki a jelenetben szereplő játékosokat!"
                            : infoOpenedState == 3 ? "Melyik csapathoz tartozik leginkább ez a jelenet?" : "Válaszd ki a jelenet típusát és értékeld is!",
                        style: TextStyle(
                            color: infoOpenedState == 10 ? Colors.black.withOpacity(1.0) : Colors.white.withOpacity(0.76),
                            fontSize: 15, fontWeight: FontWeight.bold
                        ),
                      )*//*,)
                )
                ,*/

                infoTartalom(),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex:1,
                        child: Container(

                          margin: EdgeInsets.only(left: 0, right: 10, top: 6, bottom: 0 ),
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            height: 35,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(4.0),
                              color:  !isEmptyRange()?Colors.black87:Colors.white,
                            ),
                            child: Container(
                              // margin: EdgeInsets.only(left: 0, right: 0, top: 6, bottom: 6 ),
                                padding: EdgeInsets.only(left: 10, right: 10, top: 3, bottom: 3 ),
                                child:Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        _showDatePicker();

                                      },
                                      child: Text(
                                          !isEmptyRange()?_rangeStart+" - "+_rangeEnd:"2021-06-31 - 2022-12-31",
                                          style: TextStyle(
                                              color: !isEmptyRange()?Colors.amber:Colors.black87,
                                              fontSize: 12,fontWeight: FontWeight.normal
                                          )),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        setState(()  {
                                          _selectedDateRange = null;
                                          _rangeStart = '';
                                          _rangeEnd = '';
                                        });

                                        await SharedPreferencesHelper.setRangeStart('');
                                        await SharedPreferencesHelper.setRangeEnd('');
                                        reFilterMatchesAfterRangeSelect();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(left:8.0),
                                        child: Icon(isEmptyRange()?Icons.edit:Icons.close,  size: 15.0, color: !isEmptyRange()?Colors.white:Colors.black87,),
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        ),
                      ),
                      Container(
                          height: infoOpenedState > 0 ? 65 : 0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              InkWell(
                                onTap: () async {
                                  if (!lockMentes) {
//                              setState(() {
//                                isOpenedFilterWindow = false;
//                              });

                                    await SharedPreferencesHelper.setLastVideosResponse('');
                                    log('SET lastVideosResponse11: ');

                                    if (!videoRepo.homeCon.value.showFollowingPage
                                        .value) {
                                      videoRepo.homeCon.value.videoController(
                                          videoRepo.homeCon.value.swiperIndex)
                                          ?.pause();
                                    } else {
                                      videoRepo.homeCon.value.videoController2(
                                          videoRepo.homeCon.value.swiperIndex2)
                                          ?.pause();
                                    }
//                  setState(() {
                                    /*if (videoRepo.homeCon.value.myfilter == null){
                              List<String> jatekosok = new List<String>();
                              jatekosok.add("tamas");
                              List<String> helyzettipusok = new List<String>();
                              helyzettipusok.add("GOAL");
                              videoRepo.homeCon.value.myfilter = new FilterElem(jatekosok: jatekosok);
                            } else {
                              videoRepo.homeCon.value.myfilter = null;
                            }*/
                                    print('filterStarsStates '+filterStarsStates.toString());
                                    if ((filterNames != null &&
                                        filterNames.length > 0) ||
                                        (filterTipusok != null &&
                                            filterTipusok.length > 0) ||
                                        (filterMatches != null &&
                                            filterMatches.length > 0) ||
                                        (filterTeams!=null && filterTeams.length > 0) ||
                                        ( !isEmptyRange()) ||
                                        (filterStarsStates.contains('0'))) {
                                      List<String> jatekosok = null;
                                      List<String> tipusok = null;
                                      List<String> meccsek = null;
                                      if (filterMatches != null &&
                                          filterMatches.length > 0) {
                                        meccsek = <String>[];
                                        for (String f in filterMatches) {
                                          meccsek.add(f);
                                        }
                                      } else {
                                        if (filterTeams!=null && filterTeams.length > 0){
                                          meccsek = <String>[];
                                          filterTeams.forEach((element) {
                                            meccsek.add(myTeams[element]);
                                            print('csapat szures::'+myTeams[element]);
                                          });
                                        }
                                      }
                                      if (filterNames != null &&
                                          filterNames.length > 0) {
                                        jatekosok = <String>[];
                                        for (String f in filterNames) {
                                          jatekosok.add(f);
                                        }
                                      }

                                      if (filterTipusok != null &&
                                          filterTipusok.length > 0) {
                                        for (String f in filterTipusok) {
                                          if (tipusok == null) {
                                            tipusok = <String>[];
                                          }
                                          tipusok.add(f);
                                        }
                                      }


//                                List<String> helyzettipusok = new List<String>();
//                                helyzettipusok.add("GOAL");
                                      log("_rangeStart:::"+_rangeStart);
                                      log("_rangeEnd:::"+_rangeEnd);
                                      videoRepo.homeCon.value.myfilter =
                                      new FilterElem(jatekosok: jatekosok,
                                          csapatok: meccsek,
                                          helyzettipusok: tipusok,
                                          rating: filterStarsStates, start_date: !isEmptyRange()?_rangeStart:null, end_date: !isEmptyRange()?_rangeEnd:null);
                                    } else {
                                      videoRepo.homeCon.value.myfilter = null;
                                    }
//                  });
                                    setState(() {
                                      filterProgressVisibility = true;
                                    });
                                    _con.getVideosByFilter(filter1, myPlayers, (){
                                      setState(() {
                                        filterProgressVisibility = false;
                                      });
                                      SharedPreferencesHelper.getFilteredIds().then((value) async {
                                        // setState(() {
                                        //   print('ppp filterids callback utan 4 '+value.toString());
                                        //   filteredIds= value;
                                        //   oldRatings = List.filled(filteredIds.length, "");
                                        //   mergeSelects = List.filled(filteredIds.length, true);
                                        // });


                                        if(value.length > 70) {
                                          Fluttertoast.showToast(msg: value.length.toString()+ " találat. Túl sok, szűkítsd a feltételeket!", toastLength: Toast.LENGTH_LONG );

                                        } else {
                                          Fluttertoast.showToast(msg: value.length.toString()+ " találat."+"\n", toastLength: Toast.LENGTH_LONG );

                                          _con.getVideosByFilter(
                                              filter1, myPlayers, () {}, mSelectedProfile);
                                          Navigator.of(context)
                                              .pushReplacementNamed(
                                              '/redirect-page', arguments: 0);

                                        }
                                      });
                                    }, mSelectedProfile);

                                    return;
                                  }
                                },
                                child: Icon(Icons.check_circle , size: 50.0, color: Colors.black87),
                              )
                            ],
                          )
                      ),
                      Expanded(
                        flex:1,
                        child: Container(

                          margin: EdgeInsets.only(left: 0, right: 10, top: 6, bottom: 0 ),
                          alignment: Alignment.bottomRight,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(4.0),
                              color: Colors.white,
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  lockMentes = true;
                                });
                                setState(() {
                                  //HD_1080p
                                  //HD_720p
                                  //SD_540p
                                  //SD_360p
                                  //SD_240p
                                  if(quality=="SD_540p"){
                                    quality = "HD_720p";
                                  } else if (quality=="HD_720p"){
                                    quality = "HD_1080p";
                                  } else if (quality=="HD_1080p"){
                                    quality = "SD_240p";
                                  } else if (quality=="SD_240p"){
                                    quality = "SD_360p";
                                  } else if (quality=="SD_360p"){
                                    quality = "SD_540p";
                                  }

                                  SharedPreferencesHelper.setQuality(quality).whenComplete(() {
                                    setState(() {
                                      lockMentes = false;
                                    });
                                  });

                                });

                              },
                              child: Container(
                                  // margin: EdgeInsets.only(left: 0, right: 0, top: 6, bottom: 6 ),
                                  padding: EdgeInsets.only(left: 10, right: 10, top: 3, bottom: 3 ),
                                  child:Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                          "videó minőség:",
                                          style: TextStyle(
                                              color:  Colors.black87,
                                              fontSize: 12,fontWeight: FontWeight.normal
                                          )),
                                      Text(
                                          " "+quality+" ",
                                          style: TextStyle(
                                              color:  Colors.black87,
                                              fontSize: 15,fontWeight: FontWeight.bold
                                          )),
                                      Icon(Icons.settings_outlined,  size: 15.0, color: Colors.black87),
                                    ],
                                  )),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),


              ],
            )

        ),
      );
  }
  bool isEmptyRange(){
    if(_rangeStart!=null && _rangeStart!=''&&_rangeEnd!=null && _rangeEnd!=''){
      return false;
    }
    return true;
  }
  DateTime getDateTimeFromString(String s){
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime dateTime = dateFormat.parse(s);
    return dateTime;
  }
  DateTimeRange _selectedDateRange;
  void _showDatePicker() async {
    final DateTimeRange result = await showDateRangePicker(
      context: context,
      initialDateRange:!isEmptyRange()?new DateTimeRange(start: getDateTimeFromString(_rangeStart), end: getDateTimeFromString(_rangeEnd)): null,
      firstDate:  DateTime(2021, 6, 1),
      lastDate: DateTime(2023, 12, 31),
      currentDate: DateTime.now(),
      helpText: 'Addj meg időintervallumot',
      fieldStartHintText: 'Start date',
      fieldEndHintText: 'End date',
      saveText: 'Kész',

        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: Colors.amber.withOpacity(0.7),
                onPrimary: Colors.white,
                surface: Colors.black87.withOpacity(0.7),
                onSurface: Colors.white,
              ),

              // Here I Chaged the overline to my Custom TextStyle.
              textTheme: TextTheme(overline: TextStyle(fontSize: 16)),
              dialogBackgroundColor: Colors.black87.withOpacity(0.7),
            ),
            child: child,
          );
        }
    );

    if (result != null) {
      // Rebuild the UI
      print(result.start.toString());
      setState(() {
        _selectedDateRange = result;
        _rangeStart = result.start.toString().split(" ")[0];
        _rangeEnd = result.end.toString().split(" ")[0];
        SharedPreferencesHelper.setRangeStart(_rangeStart);
        SharedPreferencesHelper.setRangeEnd(_rangeEnd);
        reFilterMatchesAfterRangeSelect();
      });
    }
  }
  Widget infoAblak2(){
    return /*AnimatedOpacity(
      opacity: infoOpenedState == 1 ? 1.0 : 0.0,
      duration: Duration(milliseconds: 1300),
      child: */ Container(

        padding: EdgeInsets.only(left: 20, top: 4, bottom: 0),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color:  Colors.white.withOpacity(0.87),
        child:Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
                alignment: Alignment.topCenter,
                child:  Container(
                  padding: EdgeInsets.only(left: 0, top: 10, bottom: 0),
                  child:Text(
                    "Állítsd kedved szerint a feltételeket, hogy csak azokat a videókat lásd, amikre kiváncsi vagy!",
                    style: TextStyle(
                        color: Colors.black.withOpacity(1.0),
                        fontSize: 15,  fontWeight: FontWeight.bold
                    ),
                  ),)
            )
            ,
            Expanded(
              flex:2,
              child: Container(),
            ),

            infoTartalom(),
            Expanded(
              flex:2,
              child: Container(),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child:  Container(
                  height: 65,
                  child:  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      InkWell(
                        onTap: () {
                          setState(() {
                            isOpenedFilterWindow = false;

                          });

                        },
                        child: Icon(Icons.check_circle_outlined,  size: 50.0, color: Colors.black87),
                      )
                    ],
                  )
              ),
            )

          ],
        )

//      ),
    );
  }

  Widget infoTartalom() {
    return Expanded(
        flex:1,
        child:Container(
            child:ListView(
              // This next line does the trick.
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                ////// time filter
                Container(
                  margin: EdgeInsets.only(left: 0, top: 5, bottom: 0),
                  width: 300.0,
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: filterMatches.length>0? Colors.amber : Colors.transparent,
                            offset: Offset(0, -6.0), //(x,y)
                            blurRadius: 5.0,
                          ),
                        ],
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.black87,
                      ),
                      child:Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            new Expanded(
                              child: new ListView.builder(
                                padding:  EdgeInsets.only(left: 0, top: 15, bottom: 0),

                                itemCount: filterableMatches.length,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                      onTap: () async {
                                        if (filterMatches.contains(meccsNameWithoutTime(filterableMatches[index]))) {
                                          setState(() {
                                            filterMatches.remove(meccsNameWithoutTime(filterableMatches[index]));

                                          });
                                        } else {
                                          setState(() {
                                            filterMatches.add(meccsNameWithoutTime(filterableMatches[index]));
                                          });
                                        }
                                        await SharedPreferencesHelper.setFilterMatches(filterMatches);
                                      },
                                      child: myTeams!=null&&containsOneSelectedTeamAtLeastOrEmptyTeamSelection(meccsNameWithoutTime(filterableMatches[index]))&&isInsideSelectedPeriod(filterableMatches[index]) ?Container(
                                        width: 300.0,
                                        alignment: Alignment.center,
                                        child: Padding(
                                            padding: EdgeInsets.only(
                                                top: 6.0,
                                                bottom: 6.0,
                                                left: 20.0,
                                                right: 20.0),
                                            child: Row(children: [
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    index==0 || hetFromMecchName(filterableMatches[index])!=hetFromMecchName(filterableMatches[index-1])?
                                                    Padding(
                                                      padding: const EdgeInsets.only(bottom: 10.0),
                                                      child: Text(
                                                        '${hetFromMecchName(filterableMatches[index])}',
                                                        // textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                            color:  Colors.green.withOpacity(0.7),
                                                            fontSize: kFontSizeInfoTartalom,fontWeight: FontWeight.w500
                                                        ),
                                                      ),
                                                    ):Container(),
                                                    Text(
                                                      '${meccsNameWithoutTime(filterableMatches[index])}',
                                                      // textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          color:  filterMatches.contains(meccsNameWithoutTime(filterableMatches[index]))?Colors.amber.withOpacity(1.0):Colors.white.withOpacity(0.7),
                                                          fontSize: kFontSizeInfoTartalom,fontWeight: filterMatches.contains(meccsNameWithoutTime(filterableMatches[index]))?FontWeight.w500:FontWeight.normal
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ])),
                                      ):Container()
                                  );
                                },
                              ),
                            ),
                            // Container(height:2, margin:EdgeInsets.only(left:50, right: 50, bottom: 2),color:Colors.amber),
                            /*Container(
                              padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 5),
                              child: Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                                size: 0.0,
                              ),
                            )*/])
                  ),
                ),
                //////tipus filter
                Container(
                    margin: EdgeInsets.only(left: 30, top: 5, bottom: 0),
                    width: 200.0,
                    child: DecoratedBox(

                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: filterTipusok.length>0? Colors.amber : Colors.transparent,
                            offset: Offset(0, -6.0), //(x,y)
                            blurRadius: 5.0,
                          ),
                        ],
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.black87,
                      ),
                      child:Stack(
                        children: [
                          ListView(
                              scrollDirection: Axis.vertical,
                              children: [
                                SizedBox(
                                  height: 15,
                                ),
                                InkWell(
                                    onTap: () {
                                      if (filterTipusok.contains("g")) {
                                        setState(() {
                                          filterTipusok.remove("g");
                                          SharedPreferencesHelper.setFilterTypes(filterTipusok);

                                        });
                                      } else {
                                        setState(() {
                                          filterTipusok.add("g");
                                          SharedPreferencesHelper.setFilterTypes(filterTipusok);
                                        });
                                      }
                                    },
                                    child:Container(
                                        width: 200.0,alignment: Alignment.center,
                                        padding: EdgeInsets.only(left: 0, right: 0, top:6, bottom: 6),
                                        child: Text(

                                          "gól",
                                          style: TextStyle(
                                              color:  filterTipusok.contains("g")?Colors.amber.withOpacity(1.0):Colors.white.withOpacity(0.7),
                                              fontSize: kFontSizeInfoTartalom,fontWeight: filterTipusok.contains("g")?FontWeight.w500:FontWeight.normal
                                          ),
                                        ))
                                ) ,
                                InkWell(
                                  onTap: () {
                                    if (filterTipusok.contains("h")) {
                                      setState(() {
                                        filterTipusok.remove("h");
                                        SharedPreferencesHelper.setFilterTypes(filterTipusok);

                                      });
                                    } else {
                                      setState(() {
                                        filterTipusok.add("h");
                                        SharedPreferencesHelper.setFilterTypes(filterTipusok);

                                      });
                                    }
                                  },
                                  child:Container(
                                      width: 200.0,alignment: Alignment.center,
                                      padding: EdgeInsets.only(left: 0, right: 0, top: 6, bottom: 6),
                                      child: Text(
                                          "gólhelyzet",
                                          style: TextStyle(
                                              color: filterTipusok.contains("h")?Colors.amber.withOpacity(1.0):Colors.white.withOpacity(0.7),
                                              fontSize: kFontSizeInfoTartalom,fontWeight: filterTipusok.contains("h")?FontWeight.w500:FontWeight.normal
                                          )
                                      )),
                                ),
                                InkWell(
                                    onTap: () {
                                      if (filterTipusok.contains("c")) {
                                        setState(() {
                                          filterTipusok.remove("c");
                                          SharedPreferencesHelper.setFilterTypes(filterTipusok);

                                        });
                                      } else {
                                        setState(() {
                                          filterTipusok.add("c");
                                          SharedPreferencesHelper.setFilterTypes(filterTipusok);

                                        });
                                      }
                                    },
                                    child: Container(
                                        width: 200.0,alignment: Alignment.center,
                                        padding: EdgeInsets.only(left: 0, right: 0, top:6, bottom: 6),
                                        child:Text(
                                          "csel/szerelés",
                                          style: TextStyle(
                                              color:  filterTipusok.contains("c")?Colors.amber.withOpacity(1.0):Colors.white.withOpacity(0.7),
                                              fontSize: kFontSizeInfoTartalom,fontWeight: filterTipusok.contains("c")?FontWeight.w500:FontWeight.normal
                                          ),
                                        ))),
                                InkWell(
                                  onTap: () {
                                    if (filterTipusok.contains("v")) {
                                      setState(() {
                                        filterTipusok.remove("v");
                                        SharedPreferencesHelper.setFilterTypes(filterTipusok);

                                      });
                                    } else {
                                      setState(() {
                                        filterTipusok.add("v");
                                        SharedPreferencesHelper.setFilterTypes(filterTipusok);

                                      });
                                    }
                                  },
                                  child: Container(
                                      width: 200.0,alignment: Alignment.center,
                                      padding: EdgeInsets.only(left: 0, right: 0, top: 6, bottom:6),
                                      child:Text(
                                          "védés",
                                          style: TextStyle(
                                              color:  filterTipusok.contains("v")?Colors.amber.withOpacity(1.0):Colors.white.withOpacity(0.7),
                                              fontSize: kFontSizeInfoTartalom,fontWeight: filterTipusok.contains("v")?FontWeight.w500:FontWeight.normal
                                          ))),
                                ),
                                InkWell(
                                  onTap: () {
                                    if (filterTipusok.contains("e")) {
                                      setState(() {
                                        filterTipusok.remove("e");
                                        SharedPreferencesHelper.setFilterTypes(filterTipusok);

                                      });
                                    } else {
                                      setState(() {
                                        filterTipusok.add("e");
                                        SharedPreferencesHelper.setFilterTypes(filterTipusok);

                                      });
                                    }
                                  },
                                  child: Container(
                                      width: 200.0,
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(left: 0, right: 0, top: 6, bottom:6),
                                      child:Text(
                                          "elemzésre",
                                          style: TextStyle(
                                              color:  filterTipusok.contains("e")?Colors.amber.withOpacity(1.0):Colors.white.withOpacity(0.7),
                                              fontSize: kFontSizeInfoTartalom,fontWeight: filterTipusok.contains("e")?FontWeight.w500:FontWeight.normal
                                          ))),
                                ) ,
                                InkWell(
                                  onTap: () {
                                    if (filterTipusok.contains("o")) {
                                      setState(() {
                                        filterTipusok.remove("o");
                                        SharedPreferencesHelper.setFilterTypes(filterTipusok);

                                      });
                                    } else {
                                      setState(() {
                                        filterTipusok.add("o");
                                        SharedPreferencesHelper.setFilterTypes(filterTipusok);

                                      });
                                    }
                                  },
                                  child: Container(
                                      alignment: Alignment.center,
                                      width: 200.0,
                                      padding: EdgeInsets.only(left: 0, right: 0, top: 6, bottom: 6),
                                      child:Text(
                                          "oktatóvideó",
                                          style: TextStyle(
                                              color:  filterTipusok.contains("o")?Colors.amber.withOpacity(1.0):Colors.white.withOpacity(0.7),
                                              fontSize: kFontSizeInfoTartalom,fontWeight: filterTipusok.contains("o")?FontWeight.w500:FontWeight.normal
                                          ))),
                                ), SizedBox(
                                  height: 6,
                                )/*,
                              Container(
                                padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 5),
                                child: Icon(
                                  Icons.search_outlined,
                                  color: Colors.white,
                                  size: 30.0,
                                ),
                              )*/]),
                          Positioned(
                            bottom: 0,
                            child: Container(
                              margin: EdgeInsets.only(bottom: 20, right: 5, left:5),
                              width: 200,
                              height: 40,
                              child: buildRatingFilter(),
                            ),
                          )
                        ],
                      ),
                    )
                ),
                //////csapat filter
                Container(
                  margin: EdgeInsets.only(left: 30, top: 5, bottom:0),
                  width: 200.0,
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: filterTeams.length>0? Colors.amber : Colors.transparent,
                           offset: Offset(0, -6.0), //(x,y)
                            blurRadius: 5.0,
                          ),
                        ],
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.black87,
                      ),
                      child:myTeams!=null?ListView.builder(
                        padding:  EdgeInsets.only(left: 0, top: 15, bottom: 0),
                          itemCount: myTeams==null?0:myTeams.length,
                          itemBuilder: (context, index){
                            return  InkWell(
                                onTap: () async {
                                  if (filterTeams.contains(myTeams.keys.elementAt(index))) {
                                    setState(() {
                                      filterTeams.remove(myTeams.keys.elementAt(index));
                                    });
                                    await SharedPreferencesHelper.setFilterTeams(filterTeams);
                                    setState(() {
                                      reFilterMatchesAfterTeamSelect();
                                      reFilterPlayersAfterTeamSelect();
                                    });
                                  } else {
                                    setState(() {
                                      filterTeams.add(myTeams.keys.elementAt(index));
                                    });
                                    await SharedPreferencesHelper.setFilterTeams(filterTeams);
                                    setState(() {
                                      reFilterMatchesAfterTeamSelect();
                                      reFilterPlayersAfterTeamSelect();
                                    });

                                  }

                                },
                                child: Container(
                                    width: 200.0,alignment: Alignment.center,
                                    padding: EdgeInsets.only(left: 0, right: 0, top: 6, bottom: 6),
                                    child:Text(
                                      myTeams[myTeams.keys.elementAt(index)],
                                      style: TextStyle(
                                          color:  filterTeams.contains(myTeams.keys.elementAt(index))?Colors.amber.withOpacity(1.0):Colors.white.withOpacity(0.7),
                                          fontSize: kFontSizeInfoTartalom,fontWeight: filterTeams.contains(myTeams.keys.elementAt(index))?FontWeight.w500:FontWeight.normal
                                      ),
                                    ))
                            );
                          }

                      ):Container()
                  ),
                ),
                //////jatekos filter
                Container(
                  margin: EdgeInsets.only(left: 30, top: 5, bottom:0),
                  width: 200.0,
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: filterNames.length>0? Colors.amber : Colors.transparent,
                           offset: Offset(0, -6.0), //(x,y)
                            blurRadius: 5.0,
                          ),
                        ],
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.black87,
                      ),
                      child:ListView.builder(
                        padding:  EdgeInsets.only(left: 0, top: 15, bottom: 0),
                          itemCount: myPlayers.length,
                          itemBuilder: (context, index){
                            return  InkWell(
                                onTap: () {
                                  if (filterNames.contains(myPlayers.keys.elementAt(index))) {
                                    setState(() {
                                      filterNames.remove(myPlayers.keys.elementAt(index));
                                      SharedPreferencesHelper.setFilterNames(filterNames);
                                    });
                                  } else {
                                    setState(() {
                                      filterNames.add(myPlayers.keys.elementAt(index));
                                      SharedPreferencesHelper.setFilterNames(filterNames);

                                    });
                                  }
                                },
                                child: partOfOneSelectedTeamAtLeast(myPlayers.keys.elementAt(index))?Container(
                                    width: 200.0,alignment: Alignment.center,
                                    padding: EdgeInsets.only(left: 0, right: 0, top: 6, bottom: 6),
                                    child:Text(
                                      myPlayers[myPlayers.keys.elementAt(index)].name,
                                      style: TextStyle(
                                          color:  filterNames.contains(myPlayers.keys.elementAt(index))?Colors.amber.withOpacity(1.0):Colors.white.withOpacity(0.7),
                                          fontSize: kFontSizeInfoTartalom,fontWeight: filterNames.contains(myPlayers.keys.elementAt(index))?FontWeight.w500:FontWeight.normal
                                      ),
                                    )):Container()
                            );
                          }

                      )
                  ),
                ),
                //////csapat filter
                Container(
                  width: 20.0,
                ),
                Container(
                    width: 1.0,
                    margin: EdgeInsets.only(left: 0, top: 15, bottom: 30),

                    color: Colors.white.withOpacity(0.5)
                ),

              ],
            )
        )
    );
  }

  bool containsOneSelectedTeamAtLeastOrEmptyTeamSelection(String m){
    if (filterTeams==null || filterTeams.length == 0){
      return true;
    }
    bool kem = false;
    for(int i = 0; i< filterTeams.length;i++ ){
      if (m.contains('Nyaradszereda2019')) {
        print('filterTeams[i]:' + myTeams[filterTeams[i]].toString());
      }
      if (m.contains(myTeams[filterTeams[i]])){
        kem = true;
        break;
      }
    }
    return kem;
  }
  bool containsOneSelectedTeamAtLeast(String m){
    if (filterTeams==null || filterTeams.length == 0){
      return false;
    }
    bool kem = false;
    for(int i = 0; i< filterTeams.length;i++ ){
      print('filterTeams[i]:'+myTeams[filterTeams[i]].toString());
      if (m.contains(myTeams[filterTeams[i]])){
        kem = true;
        break;
      }
    }
    return kem;
  }
  bool isInsideSelectedPeriod(String m){
    if (isEmptyRange()){
      return true;
    }
    bool kem = false;
    try {
      print("mmmmmmmm:" + m);

      String startS = _rangeStart.replaceAll("-", "");
      String endS = _rangeEnd.replaceAll("-", "");
      String mS = m.split("_")[0];
      if (mS.compareTo(startS) >=0 && mS.compareTo(endS) <=0){
        kem = true;
      }
    } catch(e){

    }
    return kem;
  }
  String meccsNameWithoutTime(String m){
    try {
      String s = m.split("_")[1];

      return s;
    } catch(e){

    }
    return m;
  }
  String hetFromMecchName(String m){
    try {
      String s = m.split("_")[0];
      // DateTime tempDate = new DateFormat("yyyyMMdd").parse(s);
      DateFormat format = new DateFormat("MMMM dd, yyyy");
      // String date = format.format(tempDate);
      s = format.format(DateTime.parse(s)).split(" ")[0];
      return s;
    } catch(e){

    }
    return m;
  }
  bool partOfOneSelectedTeamAtLeast(String pId){
    if (filterTeams==null || filterTeams.length == 0){
      return true;
    }
    bool kem = false;
    for(int i = 0; i< filterTeams.length;i++ ){
      if (myPlayers[pId].teamId== filterTeams[i]){
        kem = true;
        break;
      }
    }
    return kem;
  }
  bool partOfOneMatchTeamAtLeast(String pId){
    bool kem = false;
    try {
      String desc = videoRepo.videosData.value.videos
          .elementAt(videoRepo.homeCon.value.swiperIndex)
          .description;
      if (desc == null || desc == "") {
        return false;
      }

      myTeams.forEach((key, value) {
        if (desc.contains(value)) {
          if (myPlayers[pId].teamId== key) {
            kem = true;
          }
        }
      });

    } catch(e){

    }
    return kem;
  }

  void reFilterMatchesAfterTeamSelect(){
    filterMatches.removeWhere((element) => !containsOneSelectedTeamAtLeast(element));
  }
  void reFilterMatchesAfterRangeSelect(){
    filterMatches.removeWhere((element) => !isInsideSelectedPeriod(element));
  }
  void reFilterPlayersAfterTeamSelect(){
    filterNames.removeWhere((element) => !partOfOneSelectedTeamAtLeast(element));
  }


  Widget editTartalom() {
    return Container(
        child:Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            //////tipus filter
            Container(
                margin: EdgeInsets.only(left: 0, top: 5, bottom: 5),
                width: 200.0,
                child: ListView(
                    scrollDirection: Axis.vertical,
                    children: [
                      InkWell(
                          onTap: () {
                            if (filterTipusok.contains("g")) {
                              setState(() {
                                filterTipusok.remove("g");
                                SharedPreferencesHelper.setFilterTypes(filterTipusok);

                              });
                            } else {
                              setState(() {
                                filterTipusok.add("g");
                                SharedPreferencesHelper.setFilterTypes(filterTipusok);
                              });
                            }
                          },
                          child:Container(
                              width: 200.0,alignment: Alignment.center,
                              padding: EdgeInsets.only(left: 0, right: 0, top:6, bottom: 6),
                              child: Text(

                                "gól",
                                style: TextStyle(
                                    color:  filterTipusok.contains("g")?Colors.amber.withOpacity(1.0):Colors.white.withOpacity(1.0),
                                    fontSize: kFontSizeInfoTartalom,fontWeight: filterTipusok.contains("g")?FontWeight.w500:FontWeight.normal
                                ),
                              ))
                      ) ,
                      InkWell(
                        onTap: () {
                          if (filterTipusok.contains("h")) {
                            setState(() {
                              filterTipusok.remove("h");
                              SharedPreferencesHelper.setFilterTypes(filterTipusok);

                            });
                          } else {
                            setState(() {
                              filterTipusok.add("h");
                              SharedPreferencesHelper.setFilterTypes(filterTipusok);

                            });
                          }
                        },
                        child:Container(
                            width: 200.0,alignment: Alignment.center,
                            padding: EdgeInsets.only(left: 0, right: 0, top: 6, bottom: 6),
                            child: Text(
                                "gólhelyzet",
                                style: TextStyle(
                                    color: filterTipusok.contains("h")?Colors.amber.withOpacity(1.0):Colors.white.withOpacity(1.0),
                                    fontSize: kFontSizeInfoTartalom,fontWeight: filterTipusok.contains("h")?FontWeight.w500:FontWeight.normal
                                )
                            )),
                      ),
                      InkWell(
                          onTap: () {
                            if (filterTipusok.contains("c")) {
                              setState(() {
                                filterTipusok.remove("c");
                                SharedPreferencesHelper.setFilterTypes(filterTipusok);

                              });
                            } else {
                              setState(() {
                                filterTipusok.add("c");
                                SharedPreferencesHelper.setFilterTypes(filterTipusok);

                              });
                            }
                          },
                          child: Container(
                              width: 200.0,alignment: Alignment.center,
                              padding: EdgeInsets.only(left: 0, right: 0, top:6, bottom: 6),
                              child:Text(
                                "csel/szerelés",
                                style: TextStyle(
                                    color:  filterTipusok.contains("c")?Colors.amber.withOpacity(1.0):Colors.white.withOpacity(1.0),
                                    fontSize: kFontSizeInfoTartalom,fontWeight: filterTipusok.contains("c")?FontWeight.w500:FontWeight.normal
                                ),
                              ))),
                      InkWell(
                        onTap: () {
                          if (filterTipusok.contains("v")) {
                            setState(() {
                              filterTipusok.remove("v");
                              SharedPreferencesHelper.setFilterTypes(filterTipusok);

                            });
                          } else {
                            setState(() {
                              filterTipusok.add("v");
                              SharedPreferencesHelper.setFilterTypes(filterTipusok);

                            });
                          }
                        },
                        child: Container(
                            width: 200.0,alignment: Alignment.center,
                            padding: EdgeInsets.only(left: 0, right: 0, top: 6, bottom:6),
                            child:Text(
                                "védés",
                                style: TextStyle(
                                    color:  filterTipusok.contains("v")?Colors.amber.withOpacity(1.0):Colors.white.withOpacity(1.0),
                                    fontSize: kFontSizeInfoTartalom,fontWeight: filterTipusok.contains("v")?FontWeight.w500:FontWeight.normal
                                ))),
                      ),
                      InkWell(
                        onTap: () {
                          if (filterTipusok.contains("e")) {
                            setState(() {
                              filterTipusok.remove("e");
                              SharedPreferencesHelper.setFilterTypes(filterTipusok);

                            });
                          } else {
                            setState(() {
                              filterTipusok.add("e");
                              SharedPreferencesHelper.setFilterTypes(filterTipusok);

                            });
                          }
                        },
                        child: Container(
                            width: 200.0,
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(left: 0, right: 0, top: 6, bottom:6),
                            child:Text(
                                "elemzésre",
                                style: TextStyle(
                                    color:  filterTipusok.contains("e")?Colors.amber.withOpacity(1.0):Colors.white.withOpacity(1.0),
                                    fontSize: kFontSizeInfoTartalom,fontWeight: filterTipusok.contains("e")?FontWeight.w500:FontWeight.normal
                                ))),
                      ) ,
                      InkWell(
                        onTap: () {
                          if (filterTipusok.contains("o")) {
                            setState(() {
                              filterTipusok.remove("o");
                              SharedPreferencesHelper.setFilterTypes(filterTipusok);

                            });
                          } else {
                            setState(() {
                              filterTipusok.add("o");
                              SharedPreferencesHelper.setFilterTypes(filterTipusok);

                            });
                          }
                        },
                        child: Container(
                            alignment: Alignment.center,
                            width: 200.0,
                            padding: EdgeInsets.only(left: 0, right: 0, top: 6, bottom: 6),
                            child:Text(
                                "oktatóvideó",
                                style: TextStyle(
                                    color:  filterTipusok.contains("o")?Colors.amber.withOpacity(1.0):Colors.white.withOpacity(1.0),
                                    fontSize: kFontSizeInfoTartalom,fontWeight: filterTipusok.contains("o")?FontWeight.w500:FontWeight.normal
                                ))),
                      ), SizedBox(
                        height: 6,
                      )/*,
                    Container(
                      padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 5),
                      child: Icon(
                        Icons.search_outlined,
                        color: Colors.white,
                        size: 30.0,
                      ),
                    )*/])
            ),
            //////jatekos filter
            Container(
              margin: EdgeInsets.only(left: 0, top: 5, bottom: 5),
              width: 200.0,
              child: ListView.builder(
                padding:  EdgeInsets.only(left: 0, top: 15, bottom: 0),
                  itemCount: myPlayers.length,
                  itemBuilder: (context, index){
                    return  InkWell(
                        onTap: () {
                          if (filterNames.contains(myPlayers.keys.elementAt(index))) {
                            setState(() {
                              filterNames.remove(myPlayers.keys.elementAt(index));
                              SharedPreferencesHelper.setFilterNames(filterNames);
                            });
                          } else {
                            setState(() {
                              filterNames.add(myPlayers.keys.elementAt(index));
                              SharedPreferencesHelper.setFilterNames(filterNames);

                            });
                          }
                        },
                        child: Container(
                            width: 200.0,alignment: Alignment.center,
                            padding: EdgeInsets.only(left: 0, right: 0, top: 6, bottom: 6),
                            child:Text(
                              myPlayers[myPlayers.keys.elementAt(index)].name,
                              style: TextStyle(
                                  color:  filterNames.contains(myPlayers.keys.elementAt(index))?Colors.amber.withOpacity(1.0):Colors.white.withOpacity(1.0),
                                  fontSize: kFontSizeInfoTartalom,fontWeight: filterNames.contains(myPlayers.keys.elementAt(index))?FontWeight.w500:FontWeight.normal
                              ),
                            ))
                    );
                  }

              ),
            )

          ],
        )
    );
  }
/*
  Widget infoTartalom2() {
    return Expanded(
        flex:3,
        child:Container(
            child:*//*ListView*//*Row(
              // This next line does the trick.
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//              scrollDirection: Axis.horizontal,
              children: <Widget>[
                Container(
                  width: 100.0,
                ),
                Container(
                  margin: EdgeInsets.only(left: 0, top: 40, bottom: 0),
                  width: 450.0,
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.black87,
                      ),
                      child:Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 8,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 18,
                                ),
                                InkWell(
                                    onTap: () {
                                      if (filterNames.contains("Nyaradszereda-Erdoszentgyorgy")) {
                                        setState(() {
                                          filterNames.remove("Nyaradszereda-Erdoszentgyorgy");
                                        });
                                      } else {
                                        setState(() {
                                          filterNames.add("Nyaradszereda-Erdoszentgyorgy");
                                        });
                                      }
                                    },
                                    child: Text(
                                      "Nyaradszereda-Erdoszentgyorgy",
                                      style: TextStyle(
                                          color:  filterNames.contains("Nyaradszereda-Erdoszentgyorgy")?Colors.amber.withOpacity(1.0):Colors.white.withOpacity(0.7),
                                          fontSize: kFontSizeInfoTartalom,fontWeight: filterNames.contains("Nyaradszereda-Erdoszentgyorgy")?FontWeight.w500:FontWeight.normal
                                      ),
                                    )
                                ) ,
                                SizedBox(
                                  height: 8,
                                ),
                                InkWell(
                                  onTap: () {
                                    if (filterNames.contains("Nyaradszereda-Dribli")) {
                                      setState(() {
                                        filterNames.remove("Nyaradszereda-Dribli");
                                      });
                                    } else {
                                      setState(() {
                                        filterNames.add("Nyaradszereda-Dribli");
                                      });
                                    }
                                  },
                                  child: Text(
                                      "Nyaradszereda-Dribli",
                                      style: TextStyle(
                                          color: filterNames.contains("Nyaradszereda-Dribli")?Colors.amber.withOpacity(1.0):Colors.white.withOpacity(0.7),
                                          fontSize: kFontSizeInfoTartalom,fontWeight: filterNames.contains("Nyaradszereda-Dribli")?FontWeight.w500:FontWeight.normal
                                      )
                                  ),
                                ), SizedBox(
                                  height: 8,
                                ),
                                InkWell(
                                    onTap: () {
                                      if (filterNames.contains("Nyaradszereda-Szovata")) {
                                        setState(() {
                                          filterNames.remove("Nyaradszereda-Szovata");
                                        });
                                      } else {
                                        setState(() {
                                          filterNames.add("Nyaradszereda-Szovata");
                                        });
                                      }
                                    },
                                    child: Text(
                                      "Nyaradszereda-Szovata",
                                      style: TextStyle(
                                          color:  filterNames.contains("Nyaradszereda-Szovata")?Colors.amber.withOpacity(1.0):Colors.white.withOpacity(0.7),
                                          fontSize: kFontSizeInfoTartalom,fontWeight: filterNames.contains("Nyaradszereda-Szovata")?FontWeight.w500:FontWeight.normal
                                      ),
                                    )),
                                SizedBox(
                                  height: 8,
                                ),
                                InkWell(
                                  onTap: () {
                                    if (filterNames.contains("Nyaradszereda-Szekelyudvarhely")) {
                                      setState(() {
                                        filterNames.remove("Nyaradszereda-Szekelyudvarhely");
                                      });
                                    } else {
                                      setState(() {
                                        filterNames.add("Nyaradszereda-Szekelyudvarhely");
                                      });
                                    }
                                  },
                                  child: Text(
                                      "Nyaradszereda-Szekelyudvarhely",
                                      style: TextStyle(
                                          color:  filterNames.contains("Nyaradszereda-Szekelyudvarhely")?Colors.amber.withOpacity(1.0):Colors.white.withOpacity(0.7),
                                          fontSize: kFontSizeInfoTartalom,fontWeight: filterNames.contains("Nyaradszereda-Szekelyudvarhely")?FontWeight.w500:FontWeight.normal
                                      )),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                InkWell(
                                  onTap: () {
                                    if (filterNames.contains("Nyaradszereda-Csikszereda")) {
                                      setState(() {
                                        filterNames.remove("Nyaradszereda-Csikszereda");
                                      });
                                    } else {
                                      setState(() {
                                        filterNames.add("Nyaradszereda-Csikszereda");
                                      });
                                    }
                                  },
                                  child: Text(
                                      "Nyaradszereda-Csikszereda",
                                      style: TextStyle(
                                          color:  filterNames.contains("Nyaradszereda-Csikszereda")?Colors.amber.withOpacity(1.0):Colors.white.withOpacity(0.7),
                                          fontSize: kFontSizeInfoTartalom,fontWeight: filterNames.contains("Nyaradszereda-Csikszereda")?FontWeight.w500:FontWeight.normal
                                      )),
                                ), SizedBox(
                                  height: 8,
                                ),


                              ],
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 5),
                              child: Icon(
                                Icons.search_outlined,
                                color: Colors.white,
                                size: 30.0,
                              ),
                            )])
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(left: 30, top: 40, bottom: 0),
                    width: 200.0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.black87,
                      ),
                      child:Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "gól",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: kFontSizeInfoTartalom,*//*fontWeight: FontWeight.w500*//*
                            ),
                          ),

                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            "gólhelyzet",
                            style: TextStyle(
                                color: Colors.amber.withOpacity(1.0),
                                fontSize: kFontSizeInfoTartalom,fontWeight: FontWeight.w500
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            "csel",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: kFontSizeInfoTartalom,*//*fontWeight: FontWeight.w500*//*
                            ),
                          ), SizedBox(
                            height: 8,
                          ),
                          Text(
                            "vicces",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: kFontSizeInfoTartalom,*//*fontWeight: FontWeight.w500*//*
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            "elemzésre",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: kFontSizeInfoTartalom,*//*fontWeight: FontWeight.w500*//*
                            ),
                          ), SizedBox(
                            height: 8,
                          ),

                        ],
                      ),
                    )
                ),
                Container(
                    margin: EdgeInsets.only(left: 30, top: 40, bottom: 0),
                    width: 70.0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.black87,
                      ),
                      child:Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                filterStarsStates[4] =='0'?filterStarsStates[4] ='1':filterStarsStates[4] ='0';

                              });
                            },
                            child:
                            Stack(
                              children: [
                                Icon(Icons.star, size: 40.0, color: filterStarsStates[4] =='1'?Colors.amber: Colors.white.withOpacity(0.5),),
                                Container(
                                    padding: EdgeInsets.only(left: 0, top: 3, bottom: 0),
                                    height: 40.0,
                                    width: 40.0,
                                    child:
                                    Align(
                                        alignment: Alignment.center,
                                        child: Text("5", style: TextStyle(fontSize:10, color: Colors.black,fontWeight: FontWeight.bold))
                                    ))

                              ],
                            ),
                          ),

                          SizedBox(
                            height: 8,
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                filterStarsStates[3] =='0'?filterStarsStates[3] ='1':filterStarsStates[3] ='0';

                              });
                            },
                            child:
                            Stack(
                              children: [
                                Icon(Icons.star, size: 40.0, color: filterStarsStates[3] =='1'?Colors.amber: Colors.white.withOpacity(0.5),),
                                Container(
                                    padding: EdgeInsets.only(left: 0, top: 3, bottom: 0),
                                    height: 40.0,
                                    width: 40.0,
                                    child:
                                    Align(
                                        alignment: Alignment.center,
                                        child: Text("4", style: TextStyle(fontSize:10, color: Colors.black,fontWeight: FontWeight.bold))
                                    ))

                              ],
                            ),
                          ),

                          SizedBox(
                            height: 8,
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                filterStarsStates[2] =='0'?filterStarsStates[2] ='1':filterStarsStates[2] ='0';

                              });
                            },
                            child:
                            Stack(
                              children: [
                                Icon(Icons.star, size: 40.0, color: filterStarsStates[2] =='1'?Colors.amber: Colors.white.withOpacity(0.5),),
                                Container(
                                    padding: EdgeInsets.only(left: 0, top: 3, bottom: 0),
                                    height: 40.0,
                                    width: 40.0,
                                    child:
                                    Align(
                                        alignment: Alignment.center,
                                        child: Text("3", style: TextStyle(fontSize:10, color: Colors.black,fontWeight: FontWeight.bold))
                                    ))

                              ],
                            ),
                          ),

                          SizedBox(
                            height: 8,
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                filterStarsStates[1] =='0'?filterStarsStates[1] ='1':filterStarsStates[1] ='0';

                              });
                            },
                            child:
                            Stack(
                              children: [
                                Icon(Icons.star, size: 40.0, color: filterStarsStates[1] =='1'?Colors.amber: Colors.white.withOpacity(0.5),),
                                Container(
                                    padding: EdgeInsets.only(left: 0, top: 3, bottom: 0),
                                    height: 40.0,
                                    width: 40.0,
                                    child:
                                    Align(
                                        alignment: Alignment.center,
                                        child: Text("2", style: TextStyle(fontSize:10, color: Colors.black,fontWeight: FontWeight.bold))
                                    ))

                              ],
                            ),
                          ),

                          SizedBox(
                            height: 8,
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                filterStarsStates[0] =='0'?filterStarsStates[0] ='1':filterStarsStates[0] ='0';

                              });
                            },
                            child:
                            Stack(
                              children: [
                                Icon(Icons.star, size: 40.0, color: filterStarsStates[0] =='1'?Colors.amber: Colors.white.withOpacity(0.5),),
                                Container(
                                    padding: EdgeInsets.only(left: 0, top: 3, bottom: 0),
                                    height: 40.0,
                                    width: 40.0,
                                    child:
                                    Align(
                                        alignment: Alignment.center,
                                        child: Text("1", style: TextStyle(fontSize:10, color: Colors.black,fontWeight: FontWeight.bold))
                                    ))

                              ],
                            ),
                          ),


                        ],
                      ),
                    )
                ),
                Container(
                  margin: EdgeInsets.only(left: 30, top: 40, bottom: 0),
                  width: 200.0,
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.black87,
                      ),
                      child:Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 8,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 18,
                                ),
                                Text(
                                  "last day",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: kFontSizeInfoTartalom,
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  "last 10 days",
                                  style: TextStyle(
                                      color: Colors.amber.withOpacity(1.0),
                                      fontSize: kFontSizeInfoTartalom,fontWeight: FontWeight.w500
                                  ),
                                ), SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  "last 3 month",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: kFontSizeInfoTartalom,*//*fontWeight: FontWeight.w500*//*
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  "2020.12.13 - 2020.12.30",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: kFontSizeInfoTartalom,*//*fontWeight: FontWeight.w500*//*
                                  ),
                                ), SizedBox(
                                  height: 8,
                                ),


                              ],
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 5),
                              child: Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                                size: 30.0,
                              ),
                            )])
                  ),
                ),
                Container(
                  width: 100.0,
                )
                *//* Container(
                    width: 1.0,
                    margin: EdgeInsets.only(left: 0, top: 60, bottom: 30),

                    color: Colors.white.withOpacity(0.5)
                ),
                Container(
                  width: 200.0,
                ),*//*
              ],
            )
        )
    );
  }*/

  Widget buildRatingFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [


        InkWell(
          onTap: () {
            setState(() {
              filterStarsStates[0] =='0'?filterStarsStates[0] ='1':filterStarsStates[0] ='0';
              SharedPreferencesHelper.setFilterRating(filterStarsStates);
            });
          },
          child:
          Stack(
            children: [
              filterStarsStates[0] =='1'?Icon(Icons.star, size: 38.0, color: Colors.amber.withOpacity(0.7)):
              Icon(Icons.star_outline, size: 38.0, color: Colors.white.withOpacity(0.5),),
              // Container(
              //     padding: EdgeInsets.only(left: 0, top: 3, bottom: 0),
              //     height: 40.0,
              //     width: 40.0,
              //     child:
              //     Align(
              //         alignment: Alignment.center,
              //         child: Text("1", style: TextStyle(fontSize:10, color: Colors.black,fontWeight: FontWeight.bold))
              //     ))

            ],
          ),
        ),
        SizedBox(
          height: 8,
        ),

        InkWell(
          onTap: () {
            setState(() {
              filterStarsStates[1] =='0'?filterStarsStates[1] ='1':filterStarsStates[1] ='0';
              SharedPreferencesHelper.setFilterRating(filterStarsStates);
            });
          },
          child:
          Stack(
            children: [
              Icon(Icons.star, size: 38.0, color: filterStarsStates[1] =='1'?Colors.amber: Colors.white.withOpacity(0.5),),
              // Container(
              //     padding: EdgeInsets.only(left: 0, top: 3, bottom: 0),
              //     height: 40.0,
              //     width: 40.0,
              //     child:
              //     Align(
              //         alignment: Alignment.center,
              //         child: Text("2", style: TextStyle(fontSize:10, color: Colors.black,fontWeight: FontWeight.bold))
              //     ))

            ],
          ),
        ),
        SizedBox(
          height: 8,
        ),

        InkWell(
          onTap: () {
            setState(() {
              filterStarsStates[2] =='0'?filterStarsStates[2] ='1':filterStarsStates[2] ='0';
              SharedPreferencesHelper.setFilterRating(filterStarsStates);
            });
          },
          child:
          Stack(
            children: [
              Icon(Icons.star, size: 38.0, color: filterStarsStates[2] =='1'?Colors.amber: Colors.white.withOpacity(0.5),),
              // Container(
              //     padding: EdgeInsets.only(left: 0, top: 3, bottom: 0),
              //     height: 40.0,
              //     width: 40.0,
              //     child:
              //     Align(
              //         alignment: Alignment.center,
              //         child: Text("3", style: TextStyle(fontSize:10, color: Colors.black,fontWeight: FontWeight.bold))
              //     ))

            ],
          ),
        ),
        SizedBox(
          height: 8,
        ),
        InkWell(
          onTap: () {
            setState(() {
              filterStarsStates[3] =='0'?filterStarsStates[3] ='1':filterStarsStates[3] ='0';
              SharedPreferencesHelper.setFilterRating(filterStarsStates);
            });
          },
          child:
          Stack(
            children: [
              Icon(Icons.star, size: 38.0, color: filterStarsStates[3] =='1'?Colors.amber: Colors.white.withOpacity(0.5),),
              // Container(
              //     padding: EdgeInsets.only(left: 0, top: 3, bottom: 0),
              //     height: 40.0,
              //     width: 40.0,
              //     child:
              //     Align(
              //         alignment: Alignment.center,
              //         child: Text("4", style: TextStyle(fontSize:10, color: Colors.black,fontWeight: FontWeight.bold))
              //     ))

            ],
          ),
        ),
        SizedBox(
          height: 8,
        ),
        InkWell(
          onTap: () {
            setState(() {
              filterStarsStates[4] =='0'?filterStarsStates[4] ='1':filterStarsStates[4] ='0';
              SharedPreferencesHelper.setFilterRating(filterStarsStates);
            });
          },
          child:
          Stack(
            children: [
              Icon(Icons.star, size: 38.0, color: filterStarsStates[4] =='1'?Colors.amber: Colors.white.withOpacity(0.5),),
              // Container(
              //     padding: EdgeInsets.only(left: 0, top: 3, bottom: 0),
              //     height: 40.0,
              //     width: 40.0,
              //     child:
              //     Align(
              //         alignment: Alignment.center,
              //         child: Text("4", style: TextStyle(fontSize:10, color: Colors.black,fontWeight: FontWeight.bold))
              //     ))

            ],
          ),
        ),


      ],
    );
  }

  Widget homeWidget() {
    {
      videoRepo.dataLoaded.addListener(() async {
        if (videoRepo.dataLoaded.value) {
          if (mounted) setState(() {});
          // _con.refresh();
          // if (mounted) _con.setState(() {});
        }
      });

      videoRepo.homeCon.value.loadMoreUpdateView.addListener(() {
        if (videoRepo.homeCon.value.loadMoreUpdateView.value) {
          if (mounted) setState(() {});
        }
      });

      Video videoObj;
      if (!videoRepo.homeCon.value.showFollowingPage.value) {
        videoObj = (videosData.value.videos.length > 0) ? videosData.value.videos.elementAt(videoRepo.homeCon.value.videoIndex) : null;
      } else {
        videoObj = (followingUsersVideoData.value.videos.length > 0)
            ? followingUsersVideoData.value.videos.elementAt(videoRepo.homeCon.value.videoIndex)
            : videoObj;

        if (videoObj == null) {
          videoObj = (videosData.value.videos.length > 0) ? videosData.value.videos.elementAt(videoRepo.homeCon.value.videoIndex) : null;
        }
      }
      final commentField = TextFormField(
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
        obscureText: false,
        keyboardType: TextInputType.text,
        controller: TextEditingController()..text = videoRepo.homeCon.value.commentValue,
        onSaved: (String val) {
          videoRepo.homeCon.value.commentValue = val;
        },
        onChanged: (String val) {
          videoRepo.homeCon.value.commentValue = val;
        },
        onTap: () {
          setState(() {
            if (_con.bannerShowOn.indexOf("1") > -1) {
              _con.paddingBottom = 0;
            }
            videoRepo.homeCon.value.textFieldMoveToUp = true;
            videoRepo.homeCon.value.loadMoreUpdateView.value = true;
            videoRepo.homeCon.value.loadMoreUpdateView.notifyListeners();
            Timer(
                Duration(milliseconds: 200),
                () => setState(() {
                      hgt = EdgeInsets.fromWindowPadding(WidgetsBinding.instance.window.viewInsets, WidgetsBinding.instance.window.devicePixelRatio)
                          .bottom;
                    }));
          });
        },
        decoration: new InputDecoration(
            contentPadding: EdgeInsets.only(left: 10, top: 0),
            errorStyle: TextStyle(
              color: Color(0xFF210ed5),
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              wordSpacing: 2.0,
            ),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: "Say something nice...",
            hintStyle: TextStyle(color: Colors.white, fontSize: 14)),
      );

      return (videoObj != null)
          ? SlidingUpPanel(
              controller: videoRepo.homeCon.value.pc,
              minHeight: 0,
              backdropEnabled: true,
              color: Colors.black,
              backdropColor: Colors.red,
              padding: EdgeInsets.only(top: 20, bottom: 0),
              header: Column(
                children: [
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 20,
                      child: Text(
                        "Comments (" /*+ Helper.formatter(videoObj.totalComments.toString()) + ")"*/,
                        // textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 50,
                    height: 0.2,
                    color: Colors.white,
                  )
                ],
              ),
              onPanelOpened: () async {
                setState(() {
                  if (_con.bannerShowOn.indexOf("1") > -1) {
                    //_con.paddingBottom = 0;
                  }
                });
              },
              onPanelClosed: () {
                setState(() {
                  if (_con.bannerShowOn.indexOf("1") > -1) {
                    _con.paddingBottom = Platform.isAndroid ? 50.0 : 80.0;
                  }
                });
                videoRepo.homeCon.value.textFieldMoveToUp = false;
                FocusScope.of(context).unfocus();
                setState(() {
                  videoRepo.homeCon.value.hideBottomBar = true;//false;
                  videoRepo.homeCon.value.comments = [];
                });
                videoRepo.homeCon.value.loadMoreUpdateView.value = false;
                videoRepo.homeCon.value.loadMoreUpdateView.notifyListeners();
              },
              borderRadius: BorderRadius.only(topRight: Radius.circular(50), topLeft: Radius.circular(50)),
              panel: Stack(
                fit: StackFit.loose,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  ),
                  Positioned(
                    top: 40,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 2,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.only(topRight: Radius.circular(50), topLeft: Radius.circular(50)),
                      ),
                      child: (videoRepo.homeCon.value.comments.length > 0)
                          ? Padding(
                              padding: /*videoRepo.homeCon.value.comments.length > 5
                                  ? currentUser.value.token != null
                                      ? EdgeInsets.only(bottom: 85)
                                      : EdgeInsets.zero
                                  : */EdgeInsets.zero,
                              child: ListView.separated(
                                controller: videoRepo.homeCon.value.scrollController,
                                padding: EdgeInsets.zero,
                                scrollDirection: Axis.vertical,
                                itemCount: videoRepo.homeCon.value.comments.length,
                                itemBuilder: (context, i) {
                                  return Column(
                                    children: [
                                      ListTile(
                                        dense: true,
                                        visualDensity: VisualDensity(horizontal: 0, vertical: -2),
                                        leading: Container(
                                          width: 30.0,
                                          height: 30.0,
                                          decoration: new BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: new DecorationImage(
                                              fit: BoxFit.cover,
                                              image: videoRepo.homeCon.value.comments.elementAt(i).userDp.isNotEmpty
                                                  ? CachedNetworkImageProvider(
                                                      videoRepo.homeCon.value.comments.elementAt(i).userDp,
                                                    )
                                                  : AssetImage(
                                                      "assets/images/video-logo.png",
                                                    ),
                                            ),
                                          ),
                                        ),
                                        title: GestureDetector(
                                          onTap: () {
                                            print('TAPPPPPPPPP');
                                          },
                                          child: Row(
                                            children: [
                                              Text(
                                                videoRepo.homeCon.value.comments.elementAt(i).userName,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 15.0,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              videoRepo.homeCon.value.comments.elementAt(i).isVerified == true
                                                  ? Icon(
                                                      Icons.verified,
                                                      color: Colors.blueAccent,
                                                      size: 16,
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                          child: Text(
                                            videoRepo.homeCon.value.comments.elementAt(i).comment,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ),
                                        trailing: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                          child: Text(
                                            videoRepo.homeCon.value.comments.elementAt(i).time,
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return Divider(
                                    color: Colors.white,
                                    thickness: 0.1,
                                  );
                                },
                              ),
                            )
                          : (videoObj.totalComments!=null && videoObj.totalComments > 0)
                              ? SkeletonLoader(
                                  builder: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 18,
                                        ),
                                        SizedBox(width: 20),
                                        Expanded(
                                          child: Column(
                                            children: <Widget>[
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Container(
                                                  height: 8,
                                                  width: 80,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Container(
                                                width: double.infinity,
                                                height: 8,
                                                color: Colors.white,
                                              ),
                                              SizedBox(height: 4),
                                              Container(
                                                width: double.infinity,
                                                height: 8,
                                                color: Colors.white,
                                              ),
                                              SizedBox(height: 15),
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Container(
                                                  width: 50,
                                                  height: 9,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  items: videoObj.totalComments > 4 ? 4 : videoObj.totalComments,
                                  period: Duration(seconds: 1),
                                  highlightColor: Colors.white60,
                                  direction: SkeletonDirection.ltr,
                                )
                              : Center(
                                  child: Text(
                                    "No comment available",
                                    style: TextStyle(color: Colors.grey, fontSize: 17, fontWeight: FontWeight.w500),
                                  ),
                                ),
                    ),
                  ),
                  currentUser.value.token != null
                      ? Positioned(
                          bottom:
                              /* (videoRepo.homeCon.value.textFieldMoveToUp)
                              ? hgt + 10
                              : */
                              20,
                          child: Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            color: Color(0xff2e2f34),
                            child: Stack(
                              alignment: Alignment.centerRight,
                              //    child: commentField
                              children: [
                                commentField,
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      videoRepo.homeCon.value.textFieldMoveToUp = false;
                                    });
                                    if (videoRepo.homeCon.value.commentValue.trim() != '' && videoRepo.homeCon.value.commentValue != null) {
                                      videoRepo.homeCon.value.addComment(videoObj.videoId, context);
                                    }
                                    FocusScope.of(context).unfocus();
                                    FocusScope.of(context).requestFocus(FocusNode());
                                  },
                                  icon: Container(
                                    height: 25,
                                    width: 25,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: Image.asset("assets/icons/next-b.png"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 0,
                        ),
                  ValueListenableBuilder(
                      valueListenable: videoRepo.homeCon.value.commentsLoader,
                      builder: (context, loader, _) {
                        return loader
                            ? Center(
                                child: showLoaderSpinner(),
                              )
                            : SizedBox(
                                height: 0,
                              );
                      }),
                ],
              ),
              body: ValueListenableBuilder(
                  valueListenable: videoRepo.homeCon.value.showFollowingPage,
                  builder: (context, show, _) {
                    return !show
                        ? ValueListenableBuilder(
                            valueListenable: videosData,
                            builder: (context, VideoModel video, _) {
                              return Stack(
                                children: <Widget>[
                                  Swiper(
                                    controller: videoRepo.homeCon.value.swipeController,
                                    loop: false,
                                    index: videoRepo.homeCon.value.swiperIndex,
                                    control: new SwiperControl(
                                      color: Colors.transparent,
                                    ),
                                    onIndexChanged: (index) {
                                      if (videoRepo.homeCon.value.swiperIndex > index) {
                                        print("Prev Code");
                                        videoRepo.homeCon.value.previousVideo(index);
                                      } else {
                                        print("Next Code");

                                        videoRepo.homeCon.value.nextVideo(index);
                                      }
                                      // updateHistory(video.videos
                                      //     .elementAt(videoRepo.homeCon.value.swiperIndex)
                                      //     .videoId
                                      //     .toString());
                                      setState(() {
                                        actualVideo = null;

                                        if (index >= oldRatings.length) {
                                          // String desc = video.videos
                                          //     .elementAt(index).description;
                                          // if (desc.contains("    ")) {
                                          //   List<String> descL = desc.split("    ");
                                          //   if (descL.length == 2) {
                                          //     oldRatings.add(descL[1]);
                                          //   } else {
                                          //     oldRatings.add("0");
                                          //   }
                                          // } else {
                                          //   oldRatings.add("0");
                                          // }

                                        } else {
                                          if (oldRatings[index]=="") {
                                            oldRatings[index]="0";
                                            String desc = video.videos
                                                .elementAt(index).description;
                                            if (desc.contains("    ")) {
                                              List<String> descL = desc.split("    ");
                                              if (descL.length == 2) {
                                                oldRatings[index]=descL[1];
                                              }
                                            }
                                          }
                                        }
                                        if (index >= actualVideoElemName.length) {
                                          actualVideoElemName.add("");
                                        }else {
                                          // actualVideoElemName[index] =  "";
                                        }

                                      });
                                      videoRepo.homeCon.value.updateSwiperIndex(index);
                                      setState(() {
                                        actVidIndex = index;
                                        actualVideoElemIdx = index;
                                      });

                                      if (video.videos.length - index == 3) {
                                        videoRepo.homeCon.value
                                            .listenForMoreVideos(filter1, myPlayers, mSelectedProfile)
                                            .whenComplete(() {
                                              unawaited(videoRepo.homeCon.value.preCacheVideos());});
                                      }
                                    },
                                    itemBuilder: (BuildContext context, int index) {
                                      print("AAAABCD");
                                      // print(videoRepo.homeCon.value.initializeVideoPlayerFutures[video.videos.elementAt(index).url]);
                                      return GestureDetector(

                                          onLongPress: () {

                                            videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.setPlaybackSpeed(slowSpeed!=-1?0.3:1.0);

                                            setState(() {
                                              if (slowSpeed!=-1){
                                                slowSpeed = -1;
                                              } else {
                                                slowSpeed=0;
                                              }
                                            });
                                          },
                                          onDoubleTap: () {

                                            videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.setPlaybackSpeed(slowSpeed!=1?1.7:1.0);

                                            setState(() {
                                              if (slowSpeed!=1){
                                                slowSpeed = 1;
                                              } else {
                                                slowSpeed=0;
                                              }
                                            });
                                          },
                                          onTap: () {
                                            print("click Played");
                                            setState(() {
                                              _con.onTap = true;
                                              videoRepo.homeCon.notifyListeners();
                                              // If the video is playing, pause it.
                                              if (_con.videoController(_con.swiperIndex).value.isPlaying) {
                                                _con.videoController(_con.swiperIndex).pause();
                                                // setState(() {
                                                //   _con.lights = true;
                                                // });
                                              } else {
                                                // If the video is paused, play it.
                                                _con.videoController(_con.swiperIndex).play();
                                                // setState(() {
                                                //   _con.lights = false;
                                                // });
                                              }
                                            });
                                          },
                                          child: Stack(
                                            fit: StackFit.loose,
                                            children: <Widget>[
                                              Container(
                                                height: MediaQuery.of(context).size.height,
                                                width: MediaQuery.of(context).size.width,
                                                child: Center(
                                                  child: Container(
                                                    color: Colors.black,
//                                                    constraints: BoxConstraints(minWidth: 100, maxWidth: 500),
                                                    child: VideoPlayerWidget(
                                                        videoRepo.homeCon.value.videoController(index),
                                                        video.videos.elementAt(index),
                                                        videoRepo.homeCon.value.initializeVideoPlayerFutures[video.videos.elementAt(index).url]),
                                                  ),
                                                ),
                                              ),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: <Widget>[
                                                  // Top section
                                                  // Middle expanded
                                                  Container(
//                                                    padding: new EdgeInsets.only(bottom: videoRepo.homeCon.value.paddingBottom),
                                                    child: /*Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: <Widget>[
                                                          VideoDescription(
                                                            video.videos.elementAt(index),
                                                            videoRepo.homeCon.value.pc3,(editableTag) {
                                                            print("callbackrekatt main." +editableTag);
                                                            setState(() {
                                                              // video.videos.elementAt(index).username = "hhh";
                                                              actualVideoElemIdx = index;
                                                            });
                                                            initDialog(video.videos.elementAt(index).videoElem.name);
                                                            editPlayerAndType(video.videos.elementAt(index).videoElem!=null?video.videos.elementAt(index).videoElem:null, editableTag);
                                                          }
                                                          ),
                                                          sidebar(index, video)
                                                        ])*/Container(),
                                                  ),
                                                  SizedBox(
                                                    height: videoRepo.homeCon.value.hideBottomBar ?5.0:70.0,
                                                  ),
                                                ],
                                              ),
                                              (videoRepo.homeCon.value.swiperIndex == 0 && !videoRepo.homeCon.value.initializePage)
                                                  ? SafeArea(
                                                      child: Container(
                                                        height: MediaQuery.of(context).size.height / 4,
                                                        width: MediaQuery.of(context).size.width,
                                                        color: Colors.transparent,
                                                      ),
                                                    )
                                                  : Container(),

                                            ],
                                          ));
                                      // }
                                    },
                                    itemCount: video.videos.length,
                                    scrollDirection: Axis.vertical,
                                  ),
                                  ValueListenableBuilder(
                                      valueListenable: videoRepo.homeCon.value.userVideoObj,
                                      builder: (context, Map<String, dynamic> value, _) {
                                        return (value['userId'] == null || value['userId'] == 0) &&
                                                (value['videoId'] == null || value['videoId'] == 0)
                                            ? topSection(video)
                                            : Padding(
                                                padding: const EdgeInsets.only(top: 40.0, bottom: 20),
                                                child: Container(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 0,
                                                        child: IconButton(
                                                          icon: Icon(
                                                            Icons.arrow_back_ios,
                                                            color: Colors.white,
                                                          ),
                                                          onPressed: () async {
                                                            videoRepo.homeCon.value.userVideoObj.value['userId'] = 0;
                                                            videoRepo.homeCon.value.userVideoObj.value['videoId'] = 0;
                                                            videoRepo.homeCon.value.userVideoObj.value['name'] = '';
                                                            videoRepo.homeCon.value.userVideoObj.notifyListeners();
                                                            if (!videoRepo.homeCon.value.showFollowingPage.value) {
                                                              videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                                                            } else {
                                                              videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
                                                            }
                                                            // await videoRepo.homeCon.value.getFollowingUserVideos();
                                                            Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                                                            _con.getVideos(myPlayers: myPlayers);
                                                          },
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Transform.translate(
                                                          offset: Offset(-10, 0),
                                                          child: Text(
                                                            value['name'] != "" && value['name'] != null
                                                                ? value['name'] + " Videos"
                                                                : value['userId'] != 0 && value['userId'] != null
                                                                    ? "My Videos"
                                                                    : "",
                                                            // textAlign: TextAlign.center,
                                                            style: TextStyle(color: Colors.white, fontSize: 16),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                      }),
                                ],
                              );
                            },
                          )
                        : ValueListenableBuilder(
                            valueListenable: followingUsersVideoData,
                            builder: (context, VideoModel video, _) {
                              print("videoRepo.homeCon.value.swiperIndex2");
                              print(videoRepo.homeCon.value.swiperIndex2);
                              return Stack(
                                children: <Widget>[
                                  (video.videos.length > 0)
                                      ? Swiper(
                                          controller: videoRepo.homeCon.value.swipeController2,
                                          loop: false,
                                          index: videoRepo.homeCon.value.swiperIndex2,
                                          control: new SwiperControl(
                                            color: Colors.transparent,
                                          ),
                                          onIndexChanged: (index) {
                                            setState(() {
                                              slowSpeed = 0;
                                            });
                                            if (videoRepo.homeCon.value.swiperIndex2 > index) {
                                              videoRepo.homeCon.value.previousVideo2(index);
                                            } else {
                                              videoRepo.homeCon.value.nextVideo2(index);
                                            }
                                            videoRepo.homeCon.value.updateSwiperIndex2(index);
                                            if (video.videos.length - index == 3) {
                                              videoRepo.homeCon.value.listenForMoreUserFollowingVideos();
                                            }
                                          },
                                          itemBuilder: (BuildContext context, int index) {
                                            return GestureDetector(
                                              onTap: () {
                                                print("click Played");
                                                setState(() {
//                  print("Entered ");

                                                  // If the video is playing, pause it.
                                                  if (_con.videoController2(_con.swiperIndex2).value.isPlaying) {
                                                    _con.videoController2(_con.swiperIndex2).pause();
                                                    // setState(() {
                                                    //   _con.lights = true;
                                                    // });
                                                  } else {
                                                    // If the video is paused, play it.
                                                    _con.videoController2(_con.swiperIndex2).play();
                                                    // setState(() {
                                                    //   _con.lights = false;
                                                    // });
                                                  }
                                                });
                                              },
                                              child: new Stack(
                                                fit: StackFit.loose,
                                                children: <Widget>[
                                                  Center(
                                                    child: Container(
                                                      color: Colors.black,
                                                      constraints: BoxConstraints(minWidth: 100, maxWidth: 500),
                                                      child: VideoPlayerWidget(
                                                          videoRepo.homeCon.value.videoController2(index),
                                                          video.videos.elementAt(index),
                                                          videoRepo.homeCon.value.initializeVideoPlayerFutures2[video.videos.elementAt(index).url]),
                                                    ),
                                                  ),
                                                  Stack(
                                                    children: [
                                                      Column(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: <Widget>[
                                                          // Top section
                                                          // Middle expanded
                                                          Container(
                                                            child: /*Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                                children: <Widget>[
                                                                  VideoDescription(
                                                                    video.videos.elementAt(index),
                                                                    videoRepo.homeCon.value.pc3, (editableTag) {
                                                                    print("callbackrekatt 1." +editableTag);
                                                                    setState(() {
                                                                      video.videos.elementAt(index).username = refreshTags();
                                                                    });
                                                                    initDialog(video.videos.elementAt(index).videoElem.name);
                                                                    editPlayerAndType(video.videos.elementAt(index).videoElem!=null?video.videos.elementAt(index).videoElem:null, editableTag);
                                                                  }
                                                                  ),
                                                                  sidebar(index, video)
                                                                ])*/Container(),
                                                          ),
                                                          SizedBox(
                                                            height: videoRepo.homeCon.value.hideBottomBar ?5.0:70.0,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  (videoRepo.homeCon.value.swiperIndex2 == 0 && !videoRepo.homeCon.value.initializePage)
                                                      ? SafeArea(
                                                          child: Container(
                                                            height: MediaQuery.of(
                                                                  context,
                                                                ).size.height /
                                                                4,
                                                            width: MediaQuery.of(
                                                              context,
                                                            ).size.width,
                                                            color: Colors.transparent,
                                                          ),
                                                        )
                                                      : Container(),
                                                ],
                                              ),
                                            );
                                            // }
                                          },
                                          itemCount: video.videos.length,
                                          scrollDirection: Axis.vertical,
                                        )
                                      : Container(
                                          decoration: BoxDecoration(color: Colors.black87),
                                          height: MediaQuery.of(context).size.height,
                                          width: MediaQuery.of(context).size.width,
                                          child: Center(
                                            child: GestureDetector(
                                              onTap: () async {
                                                if (!videoRepo.homeCon.value.showFollowingPage.value) {
                                                  videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                                                } else {
                                                  videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
                                                }
                                                if (currentUser.value.token != null) {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/users',
                                                  );
                                                } else {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => LoginPageView(userId: 0),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: Container(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Container(
                                                      margin: EdgeInsets.all(10),
                                                      padding: EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(100),
                                                          border: Border.all(width: 2, color: Colors.white)),
                                                      child: Icon(
                                                        Icons.person,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      "This is your feed of user you follow.",
                                                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                                                    ),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    Text(
                                                      "You can follow people or subscribe to hashtags.",
                                                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Icon(Icons.person_add, color: Colors.white, size: 45),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                  topSection(video),
                                ],
                              );
                            },
                          );
                  }),
            )
          : Container(
              decoration: BoxDecoration(color: Colors.black87),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  Container(
                    height: 150,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40.0, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            /*"Following"*/"",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 18.0,
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Container(
                            height: 15,
                            width: 0,
                            color: Colors.amber,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          GestureDetector(
                            child: Text(
                             /* "Featured"*/"",
                              style: TextStyle(
                                color: Colors.white60,
                                fontWeight: FontWeight.w500,
                                fontSize: 18.0,
                              ),
                            ),
                            onTap: () async {
                              if (!videoRepo.homeCon.value.showFollowingPage.value) {
                                videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                              } else {
                                videoRepo.homeCon.value.showFollowingPage.value = false;
                                videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                                videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
                              }

                              Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                              _con.getVideos(myPlayers: myPlayers);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Center(
                      child: showLoaderSpinner(),
                    ),
                  ),
                ],
              ),
            );
    }
  }
  bool showTypesDialog = false;
  bool showRatingDialog = false;
  bool showMergeDialog = false;
  bool showAdminDialog = false;
  int slowSpeed = 0;
  bool showNamesDialog = false;
  VideoItemElem actualVideoElem;
  List<String> actualVideoElemName = <String>[];
  int actualVideoElemIdx = 0;
  String refreshTags() {
    String result = "";
    print('tagTipusok:'+tagTipusok.toString());
    tagTipusok.forEach((element) {
      result+= " #"+(element=='g'?"gól":element=='h'?'helyzet':element=='c'?'csel/szerelés':element=='v'?'védés':element=='e'?'elemzésre':element=='o'?'oktatóvideó':"");
    });
    if (result==""){
      result+='#type';
    }
    print('refreshtags:'+result.trim()+"    ");
    String result2 = "";
    print('tagNames:'+tagNames.toString());
    tagNames.forEach((element) {
      result2+= " #"+(myPlayers.containsKey(element)?myPlayers[element].name:"");
    });
    if (result2==""){
      result2+='#player';
    }
    print('refreshtags:'+result.trim()+"    ");
    return result.trim()+"    "+result2.trim();
  }
  void editPlayerAndType(VideoItemElem videoElem, String editableTag) {
    setState(() {
      actualVideoElem = videoElem;
      if (editableTag == 'type') {
        showTypesDialog = true;
      } else if (editableTag == 'name') {
        showNamesDialog = true;
      } else if (editableTag == 'rating') {
        showRatingDialog = true;
      }
    });
    // _showEditTypeDialog(videoElem);
  }

  Future<String> saveVideoName(String vId, String vName) async {
    setState(() {
      showNamesDialog = false;
    });
      // showTypesDialog = false;
      List<String> jatekosok = null;
      List<String> tipusok = null;
      String resultString = "";
      if ((tagNames != null && tagNames.length > 0) || (tagTipusok != null && tagTipusok.length > 0)) {
        print('tagNames length:'+tagNames.toString());

        if (tagNames != null && tagNames.length > 0) {

          for (String f in tagNames) {
            if (jatekosok == null) {
              jatekosok = <String>[];
            }
            jatekosok.add(f);
          }
        }

        if (tagTipusok != null && tagTipusok.length > 0) {
          for (String f in tagTipusok) {
            if (tipusok == null) {
              tipusok = <String>[];
            }
            tipusok.add(f);
          }
        }

//                                List<String> helyzettipusok = new List<String>();
//                                helyzettipusok.add("GOAL");
//                            myfilter = new FilterElem(jatekosok: jatekosok, csapatok:meccsek, helyzettipusok: tipusok);
      } else {}
//                  });
      if (tipusok == null || tipusok.length == 0) {
        resultString += "00";
      } else if (tipusok.length == 1) {
        resultString += tipusok[0];
        resultString += "0";
      } else if (tipusok.length == 2) {
        resultString += tipusok[0];
        resultString += tipusok[1];
      }
      if (jatekosok == null || jatekosok.length == 0) {
        resultString += "000000";
      } else if (jatekosok.length == 1) {
        resultString += jatekosok[0];
        resultString += "000";
      } else if (jatekosok.length == 2) {
        resultString += jatekosok[0];
        resultString += jatekosok[1];
      }
      resultString += oldRatings[actualVideoElemIdx];
      String s = await renameVideo(vName,vId,  resultString);
      return s;

  }

  Future<String> renameVideo(String vName,String renamableId, String newPlayer, [String defaultFilter])  async {
    String resultName = "";
    try {
      log('200 mSelectedProfile2 ' +mSelectedProfile);

      var headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImV4cCI6MTY5MDUzMjg1OSwiaWF0IjoxNjU4OTk2ODU5fQ.LiAvXxwjHI3sZfCJS5MBDoaG9MBzq6E4bErPLF8Jd80'

      };
      if (mSelectedProfile!=null  && (mSelectedProfile.contains("FKCS2008")||mSelectedProfile=='playersszereda')){
        headers = {
          'Accept': 'application/json',
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImV4cCI6MTY5Mjc2OTAwMiwiaWF0IjoxNjYxMjMzMDAyfQ.5PCJFMXlCnZRvJnNkEpxEI_1Cks2kRDGbiR5KCdEOXc'

        };
      }
      print('vname a renamevideoban:'+vName);
      List<String> splitName = vName.split("_");
      String newName = splitName[0]+"_"+splitName[1];
      if (newPlayer!=null && newPlayer!="") {
        newName =newName+"_"+newPlayer;
      }
      if (splitName.length == 4) {
        newName =newName+"_"+splitName[3];
      }
      else  if (splitName.length == 3){
        newName =newName+"_"+splitName[2];
      }
      else  if (splitName.length == 5){
        newName =newName+"_"+splitName[3]+"_"+splitName[4];
      }
      print('1s11111 newName ' + newName );
      print('2s11111 newName ' + newName );
      actualVideoElemName[actualVideoElemIdx] = newName;
      // setState(() {
      //   actualVideoElemName = newName;
      //   // actualVideo.videoElem.name = newName;
      //   // this.callback(newName);//TODO ha kell
      //
      // });
      print('2222 newName ' + newName );
      print('2222 newName ' + newName );
      print('2222 actualVideoElemName ' + actualVideoElemName[actualVideoElemIdx]);
      var body = {
        'name': newName,
      };

      var url =
          "https://api.backrec.eu"+"/video/"+renamableId.toString();
      print('111111 url ' + url);
      var response = await http.put(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 30));
      print('111111 http.rename ' + url);
      if (response.statusCode == 200) {

        return newName;
      } else {
        print('333333 BR videos ' + response.statusCode.toString());
        throw Exception(response.statusCode.toString()+'<statuscode');
      }
    } on TimeoutException catch (_) {
      print('Timeout??? ');
      throw Exception('Timeout');
      // A timeout occurred.
    } on Exception catch (_) {
      print('Exception?????'+_.toString());
      throw Exception(_.toString());
      // A timeout occurred.
    } catch (exception){
      print('SEVERHIBAAA');
      print('SEVERHIBAAA:'+exception.toString());
      throw Exception(exception.toString());
    }


    return actualVideoElemName[actualVideoElemIdx];


  }

  Widget typesDialog(String tagType, String vId, String vName, VoidCallback saveClicked) {
    print('vname a typesDialog elejen '+vName);
    return Align(
      alignment: Alignment.center,
      child: Container(
        alignment: Alignment.center,
        color: Colors.black.withOpacity(0.7),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
//                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Expanded(flex:1,child: Container(height:1)),
            SizedBox(height: 10),
            Expanded(
              flex: 6,
              child: Container(
                padding:EdgeInsets.all(0),
                alignment: Alignment.center,
                child: tagType=="type"?buildTypeListToDialog():tagType=='name'?buildNamesListToDialog():buildRatingListToDialog(),
              ),
            ),

            Container(
              margin: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  saveVideoName(vId, vName).then((value) {
                    print('redresh elott value '+value);
                    actualVideoElemName[actualVideoElemIdx] = value;
                    setState(() {

                      print('redresh elott setstate '+actualVideoElemName[actualVideoElemIdx]);
                      actualVideo = videoRepo.videosData.value.videos.elementAt(actualVideoElemIdx);

                      actualVideo.username = refreshTags();
                      videoRepo.videosData.value.videos.elementAt(actualVideoElemIdx).username = refreshTags();
                    });
                    saveClicked();
                  });
                  // saveClicked();

                },
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outlined,  size: 50.0, color: Colors.white),

                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget namesDialog(String vId, String vName, VoidCallback saveClicked) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        alignment: Alignment.center,
        color: Colors.black.withOpacity(0.7),
        height: MediaQuery.of(context).size.height>600?(MediaQuery.of(context).size.height/3)*2:MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.height>600?(MediaQuery.of(context).size.width/5)*1:MediaQuery.of(context).size.width,
        child: Column(
//                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 10),
            Expanded(
              flex: 6,
              child: Container(
                padding:EdgeInsets.all(40),
                alignment: Alignment.center,
                child: buildNamesListToDialog(),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {

                  saveVideoName(vId, vName).then((value) {
                    print('redresh elott value '+value);
                    actualVideoElemName[actualVideoElemIdx] = value;
                    setState(() {

                      print('redresh elott setstate '+actualVideoElemName[actualVideoElemIdx]);
                      actualVideo = videoRepo.videosData.value.videos.elementAt(actualVideoElemIdx);

                      actualVideo.username = refreshTags();
                      videoRepo.videosData.value.videos.elementAt(actualVideoElemIdx).username = refreshTags();
                    });
                    saveClicked();
                  });


                },
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outlined,  size: 50.0, color: Colors.white),

                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  List<String> tagNames = <String>[];
  List<String> tagTipusok = <String>[];
  String oldVideoName;
  String oldPlayerName = null;
  List<String> oldRatings = List.filled(100, "");
  List<bool> mergeSelects = List.filled(100, true);

  void initDialog(String vName) {

    print('videoRepo.videosData.value.videos.length:'+videoRepo.videosData.value.videos.length.toString());
    print('initdialog oldvideoname:'+vName);
    setState(() {
      oldVideoName = vName;
      tagNames = <String>[];
      tagTipusok = <String>[];
      List<String> splitName = oldVideoName.split("_");
      if (splitName!=null && splitName.length>=4) {
        oldPlayerName = splitName[2];
        if (oldPlayerName.length >= 9){
          if (oldPlayerName.substring(0,1)!='0') {
            tagTipusok.add(oldPlayerName.substring(0, 1));
          }
          if (oldPlayerName.substring(1,2)!='0') {
            tagTipusok.add(oldPlayerName.substring(1, 2));
          }
          if (oldPlayerName.substring(2,5)!='000'){
            String n=oldPlayerName.substring(2,5);
            if (partOfOneMatchTeamAtLeast(n)) {
              tagNames.add(n);
            }
          }
          if (oldPlayerName.substring(5,8)!='000') {
            String n=oldPlayerName.substring(5, 8);
            if (partOfOneMatchTeamAtLeast(n)) {
              tagNames.add(n);
            }
          }
          print('oldrating:1::::::::' + oldRatings.length.toString());

          // if (!(oldRatings.length > actualVideoElemIdx)) {
          //   print('oldrating:4::::::::' + oldRatings.length.toString());
          //
          //   oldRatings.add("0");
          // }
          if (oldRatings.length > actualVideoElemIdx) {
            print('oldrating:3::::::::' + oldRatings.length.toString());

            oldRatings[actualVideoElemIdx] = oldPlayerName.substring(8, 9);
            print('oldrating:::::::::' + oldRatings[actualVideoElemIdx]);
          }
          print('oldrating:4::::::::' + oldRatings.length.toString());

        }
      }

    });
  }

  Widget buildNamesListToDialog( ) {
    return ListView.builder(
        itemCount: myPlayers.length,
        itemBuilder: (context, index){
          return   partOfOneMatchTeamAtLeast(myPlayers.keys.elementAt(index))?InkWell(
              onTap: () {

                if (tagNames.contains(myPlayers.keys.elementAt(index))) {
                  setState(() {
                    tagNames.remove(myPlayers.keys.elementAt(index));
                  });
                } else {
                  setState(() {
                    if (tagNames.length<=1) {
                      tagNames.add(myPlayers.keys.elementAt(index));
                    }

                  });
                }
              },
              child: Container(
                  width: 200.0,alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 0, right: 0, top: 6, bottom: 6),
                  child:Text(
                    myPlayers[myPlayers.keys.elementAt(index)].name,
                    style: TextStyle(
                        color:  tagNames.contains(myPlayers.keys.elementAt(index))?Colors.amber.withOpacity(1.0):Colors.white.withOpacity(0.7),
                        fontSize:  MediaQuery.of(context).size.height>800?kFontSizeInfoTartalom:20,fontWeight: tagNames.contains(myPlayers.keys.elementAt(index))?FontWeight.w500:FontWeight.normal
                    ),
                  ))
          ) :Container();
        }

    );

  }

  Widget buildTypeListToDialog( ) {
    return ListView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: [
          InkWell(
              onTap: () {
                print('tagtipusok 1: '+tagTipusok.toString());
                if (tagTipusok.contains("g")) {
                  setState(() {
                    this.tagTipusok.remove("g");
                  });
                } else {
                  setState(() {
                    if (tagTipusok.length<=1) {
                      tagTipusok.add("g");
                    }
                  });
                }
              },
              child:Container(
                  width: 200.0,alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 0, right: 0, top:6, bottom: 6),
                  child: Text(

                    "gól",
                    style: TextStyle(
                        color:  tagTipusok.contains("g")?Colors.amber.withOpacity(1.0):Colors.white.withOpacity(0.9),
                        fontSize: MediaQuery.of(context).size.height>800?kFontSizeInfoTartalom:20,fontWeight: tagTipusok.contains("g")?FontWeight.w500:FontWeight.normal
                    ),
                  ))
          ) ,
          InkWell(
            onTap: () {
              print('tagtipusok h: '+tagTipusok.toString());
              if (tagTipusok.contains("h")) {
                setState(() {
                  tagTipusok.remove("h");
                });
              } else {
                setState(() {
                  if (tagTipusok.length<=1) {
                    tagTipusok.add("h");
                  }
                });
              }
            },
            child:Container(
                width: 200.0,alignment: Alignment.center,
                padding: EdgeInsets.only(left: 0, right: 0, top: 6, bottom: 6),
                child: Text(
                    "gólhelyzet",
                    style: TextStyle(
                        color: tagTipusok.contains("h")?Colors.amber.withOpacity(1.0):Colors.white.withOpacity(0.9),
                        fontSize: MediaQuery.of(context).size.height>800?kFontSizeInfoTartalom:20,fontWeight: tagTipusok.contains("h")?FontWeight.w500:FontWeight.normal
                    )
                )),
          ),
          InkWell(
              onTap: () {
                print('tagtipusok c: '+tagTipusok.toString());
                if (tagTipusok.contains("c")) {
                  setState(() {
                    tagTipusok.remove("c");
                  });
                } else {
                  setState(() {
                    if (tagTipusok.length<=1) {
                      tagTipusok.add("c");
                    }
                  });
                }
              },
              child: Container(
                  width: 200.0,alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 0, right: 0, top:6, bottom: 6),
                  child:Text(
                    "csel/szerelés",
                    style: TextStyle(
                        color:  tagTipusok.contains("c")?Colors.amber.withOpacity(1.0):Colors.white.withOpacity(0.9),
                        fontSize: MediaQuery.of(context).size.height>800?kFontSizeInfoTartalom:20,fontWeight: tagTipusok.contains("c")?FontWeight.w500:FontWeight.normal
                    ),
                  ))),
          InkWell(
            onTap: () {
              if (tagTipusok.contains("v")) {
                setState(() {
                  tagTipusok.remove("v");
                });
              } else {
                setState(() {
                  print('tagtipusok v: '+tagTipusok.toString());
                  if (tagTipusok.length<=1) {
                    tagTipusok.add("v");
                  }
                });
              }
            },
            child: Container(
                width: 200.0,alignment: Alignment.center,
                padding: EdgeInsets.only(left: 0, right: 0, top: 6, bottom:6),
                child:Text(
                    "védés",
                    style: TextStyle(
                        color:  tagTipusok.contains("v")?Colors.amber.withOpacity(1.0):Colors.white.withOpacity(0.9),
                        fontSize: MediaQuery.of(context).size.height>800?kFontSizeInfoTartalom:20,fontWeight: tagTipusok.contains("v")?FontWeight.w500:FontWeight.normal
                    ))),
          ),
          InkWell(
            onTap: () {
              if (tagTipusok.contains("e")) {
                setState(() {
                  tagTipusok.remove("e");
                });
              } else {
                setState(() {
                  if (tagTipusok.length<=1) {
                    tagTipusok.add("e");
                  }
                });
              }
            },
            child: Container(
                width: 200.0,
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: 0, right: 0, top: 6, bottom:6),
                child:Text(
                    "elemzésre",
                    style: TextStyle(
                        color:  tagTipusok.contains("e")?Colors.amber.withOpacity(1.0):Colors.white.withOpacity(0.9),
                        fontSize: MediaQuery.of(context).size.height>800?kFontSizeInfoTartalom:20,fontWeight: tagTipusok.contains("e")?FontWeight.w500:FontWeight.normal
                    ))),
          ) ,
          InkWell(
            onTap: () {
              if (tagTipusok.contains("o")) {
                setState(() {
                  tagTipusok.remove("o");
                });
              } else {
                setState(() {
                  if (tagTipusok.length<=1) {
                    tagTipusok.add("o");
                  }
                });
              }
            },
            child: Container(
                alignment: Alignment.center,
                width: 200.0,
                padding: EdgeInsets.only(left: 0, right: 0, top: 6, bottom: 6),
                child:Text(
                    "oktatóvideó",
                    style: TextStyle(
                        color:  tagTipusok.contains("o")?Colors.amber.withOpacity(1.0):Colors.white.withOpacity(0.9),
                        fontSize: MediaQuery.of(context).size.height>800?kFontSizeInfoTartalom:20,fontWeight: tagTipusok.contains("o")?FontWeight.w500:FontWeight.normal
                    ))),
          ), SizedBox(
            height: 6,
          )/*,
                          Container(
                            padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 5),
                            child: Icon(
                              Icons.search_outlined,
                              color: Colors.white,
                              size: 30.0,
                            ),
                          )*/]);
  }
  Widget buildRatingListToDialog( ) {
    print('actualVideoElemIdx:::::'+actualVideoElemIdx.toString());
    print('actualVideoElemIdx ooldRatings.length:::::'+oldRatings.length.toString());
    print('actualVideoElemIdx oldRatings[actualVideoElemIdx]:::::'+oldRatings[actualVideoElemIdx].toString());

    return RatingBar.builder(
      initialRating: oldRatings[actualVideoElemIdx]!="" ? int.parse(oldRatings[actualVideoElemIdx])*1.0:0.0,
      minRating: 0,
      direction: Axis.horizontal,
      allowHalfRating: false,
      itemCount: 4,
      unratedColor: Colors.white60,

      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.amber,

      ),
      onRatingUpdate: (rating) {
        setState(() {

          oldRatings[actualVideoElemIdx] = rating.floor().toString();
        });
      },
    );
  }
  Widget topSection(video) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            // Colors.black,
            // Colors.black45,
            Colors.transparent,
            Colors.transparent,
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 5.0, bottom: 20, left: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                child: ValueListenableBuilder(
                    valueListenable: videoRepo.homeCon.value.showFollowingPage,
                    builder: (context, show, _) {
                      return Text(/*"Following"*/ /*"Nyaradszereda-Szovata, 21.jan.2021"*/"",
                          style: TextStyle(
                            color: show ? Colors.white : Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14.0,
                          ));
                    }),
                onTap: ()  {
                  if (!videoRepo.homeCon.value.showFollowingPage.value) {
                    videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                  } else {
                    videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
                  }
//                  setState(() {
                    if (videoRepo.homeCon.value.myfilter == null){
                      List<String> helyzettipusok = <String>[];
                      helyzettipusok.add("GOAL");
                      videoRepo.homeCon.value.myfilter = new FilterElem(helyzettipusok: helyzettipusok, rating: filterStarsStates);
                    } else {
                      videoRepo.homeCon.value.myfilter = null;
                    }
//                  });
                  _con.getVideosByFilter(filter1, myPlayers, (){
                    SharedPreferencesHelper.getFilteredIds().then((value) {
                      setState(() {
                        print('ppp filterids callback utan 3 '+value.toString());
                        filteredIds= value;
                        oldRatings = List.filled(filteredIds.length, "");
                        mergeSelects = List.filled(filteredIds.length, true);
                      });

                    });
                  }, mSelectedProfile);
                  Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                  return;
                },
              ),
              SizedBox(
                width: 8,
              ),
              Container(
                height: 15,
                width: 0,
                color: Colors.white,
              ),
              SizedBox(
                width: 8,
              ),
              GestureDetector(
                child: ValueListenableBuilder(
                    valueListenable: videoRepo.homeCon.value.showFollowingPage,
                    builder: (context, show, _) {
                      return Text(
                       /* "Featured"*/"",
                        style: TextStyle(
                          color: show ? Colors.white60 : Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 18.0,
                        ),
                      );
                    }),
                onTap: () async {
                  if (!videoRepo.homeCon.value.showFollowingPage.value) {
                    videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                  } else {
                    videoRepo.homeCon.value.showFollowingPage.value = false;
                    videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                    videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
                  }
                  Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                  _con.getVideos(myPlayers: myPlayers);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getMusicPlayerAction(index, video) {
    Video videoObj = video.videos.elementAt(index);
    return GestureDetector(
      onTap: () async {
        if (currentUser.value.token != null) {
          if (!videoRepo.homeCon.value.showFollowingPage.value) {
            videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
          } else {
            videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
          }
          // await videoRepo.homeCon.value.disposeVideos();
          videoRepo.homeCon.value.soundShowLoader.value = true;
          videoRepo.homeCon.value.soundShowLoader.notifyListeners();
          SoundData sound = await soundRepo.getSound(videoObj.soundId);
          soundRepo.selectSound(sound).whenComplete(() {
            videoRepo.homeCon.value.soundShowLoader.value = false;
            videoRepo.homeCon.value.soundShowLoader.notifyListeners();
            Navigator.pushReplacementNamed(
              context,
              "/video-recorder",
            );
          });
        } else {
          if (!videoRepo.homeCon.value.showFollowingPage.value) {
            videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
          } else {
            videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPageView(userId: 0),
            ),
          );
        }
      },
      child: RotationTransition(
        turns: Tween(begin: 0.0, end: 1.0).animate(musicAnimationController),
        child: Container(
          margin: EdgeInsets.only(top: 10.0),
          width: 60,
          height: 60,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(8.0),
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  gradient: musicGradient,
                  borderRadius: BorderRadius.circular(50 / 2),
                ),
                child: ValueListenableBuilder(
                    valueListenable: videoRepo.homeCon.value.soundShowLoader,
                    builder: (context, loader, _) {
                      return (!loader)
                          ? Container(
                              height: 45.0,
                              width: 45.0,
                              decoration: BoxDecoration(
                                color: Colors.white30,
                                borderRadius: BorderRadius.circular(50),
                                image: new DecorationImage(
                                  image: new CachedNetworkImageProvider(videoObj.soundImageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Helper.showLoaderSpinner(Colors.white);
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sidebar(index, video) {
    Video videoObj = video.videos.elementAt(index);

    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    videoRepo.homeCon.value.encodedVideoId = stringToBase64.encode(videoRepo.homeCon.value.encKey + videoObj.videoId.toString());
    return Container(
      padding: new EdgeInsets.only(bottom: videoRepo.homeCon.value.paddingBottom),
      width: videoRepo.homeCon.value.hideBottomBar ? 0.0:0.0,//70
      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        Column(
          //mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          //mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            // GestureDetector(
            //   onTap: () async {
            //     setState(() {
            //       videoRepo.homeCon.value.bannerAd?.dispose();
            //       videoRepo.homeCon.value.bannerAd = null;
            //       videoRepo.homeCon.value.paddingBottom = 0.0;
            //     });
            //     /*await videoRepo.homeCon.value
            //         .videoController(videoRepo.homeCon.value.swiperIndex)
            //         ?.pause();
            //     await videoRepo.homeCon.value
            //         .videoController2(videoRepo.homeCon.value.swiperIndex2)
            //         ?.pause();*/
            //     await videoRepo.homeCon.value.disposeVideos();
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) =>
            //             UsersProfileView(userId: videoObj.userId),
            //       ),
            //     );
            //   },
            //   child: Transform.translate(
            //     offset: Offset(-10, 0),
            //     child: Stack(
            //       children: <Widget>[
            //         Container(
            //           height: 45.0,
            //           width: 45.0,
            //           decoration: BoxDecoration(
            //             color: Colors.white30,
            //             borderRadius: BorderRadius.circular(50),
            //             image: new DecorationImage(
            //               image:
            //                   new CachedNetworkImageProvider(videoObj.userDP),
            //               fit: BoxFit.cover,
            //             ),
            //           ),
            //         ),
            //         Positioned(
            //           bottom: 0,
            //           left: 13,
            //           child: GestureDetector(
            //             onTap: () async {
            //               if (currentUser.value.token != null) {
            //                 videoRepo.homeCon.value
            //                     .followUnfollowUser(videoObj);
            //               } else {
            //                 await videoRepo.homeCon.value
            //                     .videoController(
            //                         videoRepo.homeCon.value.swiperIndex)
            //                     ?.pause();
            //                 await videoRepo.homeCon.value
            //                     .videoController2(
            //                         videoRepo.homeCon.value.swiperIndex2)
            //                     ?.pause();
            //                 Navigator.push(
            //                   context,
            //                   MaterialPageRoute(
            //                     builder: (context) => LoginPageView(
            //                       userId: 0,
            //                     ),
            //                   ),
            //                 );
            //               }
            //             },
            //             child: (!videoRepo.homeCon.value.followUnfollowLoader)
            //                 ? (video.videos.elementAt(index).isFollowing == 0)
            //                     ? Transform.translate(
            //                         offset: Offset(-1, 8),
            //                         child: Image.asset(
            //                           'assets/icons/plus-icon.png',
            //                           width: 22,
            //                         ),
            //                       )
            //                     : Transform.translate(
            //                         offset: Offset(-1, 8),
            //                         child: Image.asset(
            //                           'assets/icons/chk-icon.png',
            //                           width: 22,
            //                         ),
            //                       )
            //                 : showLoaderSpinner(),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            Divider(
              color: Colors.transparent,
              height: 10,
            ),
          ],
        ),
        Divider(
          color: Colors.transparent,
          height: 5.0,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
//            Container(
//              height: 40.0,
//              width: 40.0,
//              child: ValueListenableBuilder(
//                  valueListenable: videoRepo.homeCon.value.likeShowLoader,
//                  builder: (context, likeLoader, _) {
//                    return IconButton(
//                      alignment: Alignment.bottomCenter,
//                      padding: EdgeInsets.only(
//                        top: 9,
//                        bottom: 6,
//                        left: 5.0,
//                        right: 5.0,
//                      ),
//                      icon: (videoObj.isLike)
//                          ? (!likeLoader)
//                              ? Image.asset(
//                                  'assets/icons/like.png',
//                                  width: 30.0,
//                                )
//                              : showLoaderSpinner()
//                          : (!likeLoader)
//                              ? Image.asset(
//                                  'assets/icons/unlike.png',
//                                  width: 30.0,
//                                )
//                              : showLoaderSpinner(),
//                      onPressed: () {
//                        if (currentUser.value.token != null) {
//                          setState(() {
//                            videoRepo.homeCon.value.likeVideo(index);
//                          });
//                        } else {
//                          if (!videoRepo.homeCon.value.showFollowingPage.value) {
//                            videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
//                          } else {
//                            videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
//                          }
//                          Navigator.pushReplacement(
//                            context,
//                            MaterialPageRoute(
//                              builder: (context) => LoginPageView(userId: 0),
//                            ),
//                          );
//                        }
//                      },
//                    );
//                  }),
//            ),
            Divider(
              color: Colors.transparent,
              height: 5.0,
            ),
            Text(
              videoObj.totalLikes!=null?Helper.formatter(videoObj.totalLikes.toString()):"",
              style: TextStyle(color: Colors.white.withOpacity(1), fontSize: 12, fontWeight: FontWeight.bold),
            )
          ],
        ),
        Divider(
          color: Colors.transparent,
          height: 5.0,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  height: 40.0,
                  width: 40.0,
                  child: IconButton(
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.only(top: 9, bottom: 6, left: 5.0, right: 5.0),
                    icon: Image.asset(
                      'assets/icons/like_backrec.png',
                      width: 35.0,
                    ),
                    onPressed: () {
                      setState(() {
//                        visiblePlus5sec = true;
                        seekTo( videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex));
                      });
                    },
                  ),
                ),
                Divider(
                  color: Colors.transparent,
                  height: 0.0,
                ),
                Text(
                  videoObj.totalComments!=null?Helper.formatter(videoObj.totalComments.toString()):"11",
                  style: TextStyle(color: Colors.white.withOpacity(1), fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        Divider(
          color: Colors.transparent,
          height: 6.0,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  height: 40.0,
                  width: 40.0,
                  child: IconButton(
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.only(top: 9, bottom: 6, left: 5.0, right: 5.0),
                    icon: Image.asset(
                      'assets/icons/views.png',
                      width: 30.0,
                    ),
                    onPressed: () {
                      setState(() {
//                        visiblePlus5sec = true;
                        seekToBackward( videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex));
                      });
                    },
                  ),
                ),
                Divider(
                  color: Colors.transparent,
                  height: 0.0,
                ),
                Text(
                    videoObj.totalViews!=null? Helper.formatter(videoObj.totalViews.toString()):"34",
                  style: TextStyle(color: Colors.white.withOpacity(1), fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        Divider(
          color: Colors.transparent,
          height: 10.0,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 40.0,
              width:  40.0,
              child:  IconButton(
                alignment: Alignment.topCenter,
                icon: Image.asset(
                  'assets/icons/star.png',
                  width: 40.0,
                ),
                onPressed: () async {
//                  if (currentUser.value.token != null) {
//                    videoRepo.homeCon.value.showReportMsg.value = false;
//                    videoRepo.homeCon.value.showReportMsg.notifyListeners();
//                    reportLayout(context, videoObj);
//                  } else {
//                    if (!videoRepo.homeCon.value.showFollowingPage.value) {
//                      videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
//                    } else {
//                      videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
//                    }
//                    Navigator.pushReplacement(
//                      context,
//                      MaterialPageRoute(
//                        builder: (context) => LoginPageView(userId: 0),
//                      ),
//                    );
//                  }
                },
              )
            ),
            Divider(
              color: Colors.transparent,
              height: 0.0,
            ),
            Text(
              videoObj.totalViews!=null? Helper.formatter(videoObj.totalViews.toString()):"4",
              style: TextStyle(color: Colors.white.withOpacity(1), fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Divider(
          color: Colors.transparent,
          height: 10.0,
        ),
        (videoObj.soundId !=null&& videoObj.soundId > 0)
            ? _getMusicPlayerAction(index, video)
            : SizedBox(
                height: 0,
              ),
        (videoObj.soundId !=null&& videoObj.soundId > 0)
            ? Divider(
                color: Colors.transparent,
                height: 5.0,
              )
            : SizedBox(
                height: 0,
              ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 40.0,
              width: 40.0,
              child:IconButton(
                alignment: Alignment.topCenter,
                icon: Image.asset('assets/icons/share.png',
                  width: 30.0,
                ),
                onPressed: () {
//                  Share.share('${GlobalConfiguration().get('share_text')}');
//                  setState(() {
//                    if (videoRepo.homeCon.value.hideBottomBar ) {
//                      videoRepo.homeCon.value.hideBottomBar = false;
//                    } else {
//                      videoRepo.homeCon.value.hideBottomBar = true;
//                    }
//                  });
                },
              ),
            ),
          ],
        ),
      ]),
    );
  }

  static showLoaderSpinner() {
    return Center(
      child: Container(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Duration duration;
  Duration position;
  LinearGradient get musicGradient => LinearGradient(
      colors: [Colors.grey[800], Colors.grey[900], Colors.grey[900], Colors.grey[800]],
      stops: [0.0, 0.4, 0.6, 1.0],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight);
}