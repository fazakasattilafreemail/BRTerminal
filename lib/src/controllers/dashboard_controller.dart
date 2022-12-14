import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:Leuke/src/models/my_models.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:pedantic/pedantic.dart';
//import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:video_player/video_player.dart';

import '../models/comment_model.dart';
import '../models/videos_model.dart';
import '../repositories/comment_repository.dart' as commentRepo;
import '../repositories/hash_repository.dart' as hashRepo;
import '../repositories/user_repository.dart' as userRepo;
import '../repositories/video_repository.dart' as videoRepo;
import '../services/CacheManager.dart';

class DashboardController extends ControllerMVC {
  int videoId = 0;
  bool completeLoaded = false;
  String commentValue = '';
  bool textFieldMoveToUp = false;
  DateTime currentBackPressTime;
  GlobalKey<ScaffoldState> scaffoldKey;
  PanelController pc = new PanelController();
  PanelController pc2 = new PanelController();
  PanelController pc3 = new PanelController();
  bool hideBottomBar = true;//false
  /*RefreshController refreshController =
      RefreshController(initialRefresh: false);*/
  ValueNotifier<bool> dataLoaded = new ValueNotifier(false);
  ValueNotifier<bool> likeShowLoader = new ValueNotifier(false);
  ValueNotifier<bool> showReportLoader = new ValueNotifier(false);
  ValueNotifier<bool> showReportMsg = new ValueNotifier(false);
  ValueNotifier<bool> loadMoreUpdateView = new ValueNotifier(false);
  ValueNotifier<bool> commentsLoader = new ValueNotifier(false);
  ValueNotifier<bool> soundShowLoader = new ValueNotifier(false);
  ValueNotifier<bool> isFollowedAnyPerson = new ValueNotifier(false);
  ValueNotifier<bool> showFollowingPage = new ValueNotifier(false);
  ValueNotifier<Map<String, dynamic>> userVideoObj = new ValueNotifier(new Map());
  ValueNotifier<bool> showHomeLoader = new ValueNotifier(false);
  ScrollController scrollController;
  ScrollController scrollController1;
  List<CommentData> comments = <CommentData>[];
  CommentData commentObj = new CommentData();
  int commentsPaging = 1;
  bool showLoadMoreComments = true;
  int active = 2;
  Map<dynamic, dynamic> map = {};
  bool showLoader = true;
  bool chkVideos = true;
  bool moreVideos = true;
  bool iFollowedAnyUser = false;
  int page = 1;
  videoRepo.FilterElem myfilter;
  int loginUserId = 0;
  String appToken = '';
  List videoList = [];
  var response;
  int following = 0;
  int isFollowingVideos = 0;
  bool userFollowSuggestion = false;
  bool isLoggedIn = false;
  bool isLiked = false;
  bool videoInitialized = false;
  Map<String, VideoPlayerController> videoControllers = {};
  Map<String, VideoPlayerController> videoControllers2 = {};
  Map<String, Future<void>> initializeVideoPlayerFutures = {};
  Map<String, Future<void>> initializeVideoPlayerFutures2 = {};
  Map<int, VoidCallback> listeners = {};
  int index = 0;
  int videoIndex = 0;
  bool lock = true;
  static const double ActionWidgetSize = 60.0;
  static const double ProfileImageSize = 50.0;
  int soundId = 0;
  int userId = 0;
  String totalComments = '0';
  String userDP = '';
  String soundImageUrl = '';
  int isFollowing = 0;
  double paddingBottom = 0;
  bool followUnfollowLoader = false;
  String encodedVideoId = '';
  String selectedType;
  String encKey = 'yfmtythd84n4h';
  String description = '';
  int chkVideo = 0;
  List<String> reportType = ["It's spam", "It's inappropriate", "I don't like it"];
  bool videoStarted = true;
  int swiperIndex = 0;
  int swiperIndex2 = 0;
  bool initializePage = true;
  SwiperController swipeController;
  SwiperController swipeController2;
  bool showNavigateLoader = false;
  DashboardController() {
    print('iniiiiiiiiiiiiii  dashboard_controller');
    swipeController = new SwiperController();
   swipeController2 = new SwiperController();
    swiperIndex = 0;
    swiperIndex2 = 0;
    userVideoObj.value = {"userId": 0, "videoId": 0};
  }

  BannerAd bannerAd;
  InterstitialAd _interstitialAd;
  String appId = '';
  String bannerUnitId = '';
  String screenUnitId = '';
  String videoUnitId = '';
  String bannerShowOn = '';
  String interstitialShowOn = '';
  String videoShowOn = '';
  GlobalKey<FormState> formKey;
  VideoPlayerController controller;
  bool lights = false;
  Duration duration;
  Duration position;
  bool isEnd = false;
  bool onTap = false;
  Future<void> initializeVideoPlayerFuture;
  @override
  initState() {

    swiperIndex = 0;
    swiperIndex2 = 0;
    print('iniiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiit dashboard_controller');
//    swipeController = new SwiperController();
//    swipeController2 = new SwiperController();
    // this.scaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: "_dashboardPage");
    super.initState();
  }

  @override
  dispose() {
    print("DisposedControl");
    videoControllers.forEach((key, value) async {
      // value.removeListener(() {});
      print('DISPOSE 9');
      // if (value.value.position > Duration( milliseconds: 2500)) {
      //   updateHistory(videoRepo.videosData.value.videos.elementAt(videoIndex).videoId);
      // }
      await value.dispose();
      print('DISPOSE 9<');
    });
    videoControllers2.forEach((key, value) async {
      // value.removeListener(() {});
      // if (value.value.position > Duration( milliseconds: 2500)) {
      //   updateHistory(videoRepo.videosData.value.videos.elementAt(videoIndex).videoId);
      // }
      print('DISPOSE 10');
      await value.dispose();
      print('DISPOSE 10<');
    });
    // updateDB();
    // musicAnimationController.dispose(); // you need this
    super.dispose();
  }


  updateSwiperIndex(int index) {
    swiperIndex = index;
  }

  updateSwiperIndex2(int index) {
    swiperIndex2 = index;
  }

  onVideoChange(String videoId) {
    // updateHistory(videoRepo.videosData.value.videos.elementAt(videoIndex).videoId);


    videoId = videoId;
  }

  // void checkVideo() {
  //   // Implement your calls inside these conditions' bodies :
  //   if (videoController(swiperIndex).value.position > Duration(seconds: 5) &&
  //       chkVideo == 0) {
  //     setState(() {
  //       chkVideo = 1;
  //     });
  //     incVideoViews();
  //   }
  // }

  // Future<void> incVideoViews() async {
  //   videoRepo
  //       .incVideoViews(videoRepo.videosData.value.videos.elementAt(swiperIndex))
  //       .catchError((e) {
  //     scaffoldKey?.currentState?.showSnackBar(SnackBar(
  //       content: Text("There's some issue with the server"),
  //     ));
  //   });
  // }

  Future<void> getAds() {
    setState(() {});
    hashRepo.getAds().then((value) {
      if (value != null) {
        var response = json.decode(value);
        appId = Platform.isAndroid ? response['android_app_id'] : response['ios_app_id'];
        bannerUnitId = Platform.isAndroid ? response['android_banner_app_id'] : response['ios_banner_app_id'];
        screenUnitId = Platform.isAndroid ? response['android_interstitial_app_id'] : response['ios_interstitial_app_id'];
        videoUnitId = Platform.isAndroid ? response['android_video_app_id'] : response['ios_video_app_id'];
        bannerShowOn = response['banner_show_on'];
        interstitialShowOn = response['interstitial_show_on'];
        videoShowOn = response['video_show_on'];

        if (appId != "") {
          FirebaseAdMob.instance.initialize(appId: appId);
          if (bannerShowOn.indexOf("1") > -1) {
            bannerAd ??= createBannerAd(bannerUnitId);
            bannerAd
              ..load()
              ..show();
            paddingBottom = Platform.isAndroid ? 50.0 : 80.0;
          }

          if (interstitialShowOn.indexOf("1") > -1) {
            print('DISPOSE 11');
            _interstitialAd?.dispose();
            print('DISPOSE 11<');
            _interstitialAd = createInterstitialAd(screenUnitId)
              ..load()
              ..show();
          }

          if (videoShowOn.indexOf("1") > -1) {
            rewardedVideoAd(videoUnitId);
            RewardedVideoAd.instance.show();
          }
        }
      }
    });
  }

  BannerAd createBannerAd(bannerUnitId) {
    return BannerAd(
      adUnitId: bannerUnitId,
      size: AdSize.banner,
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
      },
    );
  }

  InterstitialAd createInterstitialAd(screenUnitId) {
    return InterstitialAd(
      adUnitId: screenUnitId,
      listener: (MobileAdEvent event) {
        print("InterstitialAd event $event");
      },
    );
  }

  rewardedVideoAd(videoUnitId) {
    RewardedVideoAd.instance.listener = (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
      if (event == RewardedVideoAdEvent.rewarded) {}
    };
    RewardedVideoAd.instance.load(adUnitId: videoUnitId);
  }

  disposeControls(controls) {
    controls.forEach((key, value2) async {
      print("Control before disposing");
      print(value2);
      print('DISPOSE 6');
      await value2.dispose();
      print('DISPOSE 6<');
      // value2.removeListener(() {});
      // setState(() {});
    });
  }

  Future<void> getVideos({String defaultFilter,Map<String, MyPlayerElem> myPlayers, String selProfile}) async {
    swiperIndex = 0;
    swiperIndex2 = 0;
    videoRepo.videosData.value.videos = [];
    videoRepo.videosData.notifyListeners();
    initializeVideoPlayerFutures = {};
    initializeVideoPlayerFutures2 = {};
    page = 1;
    formKey = GlobalKey();
//    getAds();
    Map obj = {'userId': 0, 'videoId': 0};
    if (userVideoObj != null) {
      if (userVideoObj.value['userId'] > 0) {
        obj['userId'] = userVideoObj.value['userId'];
        obj['videoId'] = userVideoObj.value['videoId'];
      }
    }
    log("getvideossssssssss1 original");
    videoRepo.getVideos(page, myfilter, myPlayers,null, selProfile, "last_match" ).then((data1) async {
      if (data1.videos != null) {
        if (data1.videos.length > 0) {
          initController(0).whenComplete(() {
            videoRepo.dataLoaded.value = true;
            videoRepo.homeCon.value.showHomeLoader.value = false;
            videoRepo.homeCon.value.showHomeLoader.notifyListeners();
            videoRepo.dataLoaded.notifyListeners();
            playController(0);
          });
        } else {
          initializeVideoPlayerFutures = {};
          initializeVideoPlayerFutures2 = {};
        }

        if (data1.videos.length > 1) {
          initController(1).then((value) => completeLoaded = true);
        }
      } else {
        initializeVideoPlayerFutures = {};
        initializeVideoPlayerFutures2 = {};
      }
    });
  }
  Future<void> getVideosByFilter(String filter1, Map<String, MyPlayerElem> myPlayers, VoidCallback callBackForFilteredLength, String selProfile) async {
    swiperIndex = 0;
    swiperIndex2 = 0;
    videoRepo.videosData.value.videos = [];
    videoRepo.videosData.notifyListeners();
    initializeVideoPlayerFutures = {};
    initializeVideoPlayerFutures2 = {};
    page = 1;
    formKey = GlobalKey();
//    getAds();
    Map obj = {'userId': 0, 'videoId': 0};
    if (userVideoObj != null) {
      if (userVideoObj.value['userId'] > 0) {
        obj['userId'] = userVideoObj.value['userId'];
        obj['videoId'] = userVideoObj.value['videoId'];
      }
    }
    log("getvideossssssssss2 getVideosByFilter ");

    videoRepo.getVideos(page, myfilter, myPlayers , callBackForFilteredLength, selProfile).then((data1) async {
      if (data1.videos != null) {
        if (data1.videos.length > 0) {
          initController(0).whenComplete(() {
            videoRepo.dataLoaded.value = true;
            videoRepo.homeCon.value.showHomeLoader.value = false;
            videoRepo.homeCon.value.showHomeLoader.notifyListeners();
            videoRepo.dataLoaded.notifyListeners();
            playController(0);
          });
        } else {
          initializeVideoPlayerFutures = {};
          initializeVideoPlayerFutures2 = {};
        }

        if (data1.videos.length > 1) {
          initController(1).then((value) => completeLoaded = true);
        }
      } else {
        initializeVideoPlayerFutures = {};
        initializeVideoPlayerFutures2 = {};
      }
      return;
    });
  }

  Future<void> getFollowingUserVideos() async {
    initializeVideoPlayerFutures = {};
    initializeVideoPlayerFutures2 = {};
    page = 1;
    formKey = GlobalKey();
    videoRepo.getFollowingUserVideos(page).then((data2) async {
      if (data2.videos != null) {
        if (data2.videos.length > 0) {
          initController2(0).whenComplete(() {
            playController2(0);
            videoRepo.dataLoaded.value = true;
            videoRepo.dataLoaded.notifyListeners();
          });
        } else {
          initializeVideoPlayerFutures = {};
          initializeVideoPlayerFutures2 = {};
        }

        if (data2.videos.length > 1) {
          initController2(1).then((value) => completeLoaded = true);
        }
      } else {
        initializeVideoPlayerFutures = {};
        initializeVideoPlayerFutures2 = {};
      }
    });
  }

  Future<void> listenForMoreVideos(String filter1,Map<String, MyPlayerElem> myPlayers , String selP) async {
    Map obj = {'userId': 0, 'videoId': 0};
    if (userVideoObj != null) {
      if (userVideoObj.value['userId'] > 0) {
        obj['userId'] = userVideoObj.value['userId'];
        obj['videoId'] = userVideoObj.value['videoId'];
      }
    }
    page = page + 1;
    log("getvideossssssssss3 listenForMoreVideos");

    videoRepo.getVideos(page, myfilter, myPlayers, null, selP).whenComplete(() {
      loadMoreUpdateView.value = true;
      loadMoreUpdateView.notifyListeners();
    });
  }

  Future<void> listenForMoreUserFollowingVideos() async {
    page = page + 1;
    videoRepo.getFollowingUserVideos(page).whenComplete(() {
      loadMoreUpdateView.value = true;
      loadMoreUpdateView.notifyListeners();
    });
  }

  Future<void> likeVideo(int index) async {
    likeShowLoader.value = true;
    likeShowLoader.notifyListeners();
    videoRepo.videosData.value.videos.elementAt(index).totalLikes = (!videoRepo.videosData.value.videos.elementAt(index).isLike)
        ? videoRepo.videosData.value.videos.elementAt(index).totalLikes + 1
        : videoRepo.videosData.value.videos.elementAt(index).totalLikes - 1;
    videoRepo.videosData.value.videos.elementAt(index).isLike = (videoRepo.videosData.value.videos.elementAt(index).isLike) ? false : true;

    videoRepo.updateLike(videoRepo.videosData.value.videos.elementAt(index).videoId).whenComplete(() {
      likeShowLoader.value = false;
      likeShowLoader.notifyListeners();
    }).catchError((e) {
      likeShowLoader.value = false;
      likeShowLoader.notifyListeners();
      ScaffoldMessenger.of(lastContext).showSnackBar(SnackBar(
        content: Text("There's some issue with the server"),
      ));

    });
  }

  Future<void> submitReport(Video videoObj, context) async {
    showReportLoader.value = true;
    showReportLoader.notifyListeners();
    videoRepo.submitReport(videoObj, selectedType, description).whenComplete(() {
      showReportLoader.value = false;
      showReportLoader.notifyListeners();
      selectedType = null;
      description = '';
      showReportMsg.value = true;
      showReportMsg.notifyListeners();
      Timer(Duration(seconds: 5), () {
        Navigator.of(context).pop();
      });
    }).catchError((e) {
      ScaffoldMessenger.of(lastContext).showSnackBar(SnackBar(
        content: Text("There's some issue with the server"),
      ));
    });
  }

  Future<void> getComments(Video videoObj) async {
    comments = [];
    showLoadMoreComments = true;
    page = 1;
    scrollController = new ScrollController();
    scrollController1 = new ScrollController();
    final Stream<CommentData> stream = await commentRepo.getComments(videoObj.videoId, page);
    stream.listen((CommentData _comment) {
      comments.add(_comment);
    }, onError: (a) {
      print(a);
    }, onDone: () {
      if (comments.length == videoObj.totalComments) {
        showLoadMoreComments = false;
      }
      scrollController.addListener(() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
          if (comments.length != videoObj.totalComments && showLoadMoreComments) {
            loadMore(videoObj);
          }
        }
      });
      print("Fetched Comments");
    });
  }

  Future<void> loadMore(Video videoObj) async {
    commentsLoader.value = true;
    commentsLoader.notifyListeners();
    page = page + 1;
    final Stream<CommentData> stream = await commentRepo.getComments(videoObj.videoId, page);
    stream.listen((CommentData _comment) {
      comments.add(_comment);
      print(_comment);
    }, onError: (a) {
      print(a);
    }, onDone: () {
      commentsLoader.value = false;
      commentsLoader.notifyListeners();
      if (comments.length == videoObj.totalComments) {
        showLoadMoreComments = false;
      }
      loadMoreUpdateView.value = true;
      loadMoreUpdateView.notifyListeners();
    });
  }

  Future<void> addComment(int videoId, context) async {
    FocusScope.of(context).unfocus();
    commentObj = new CommentData();
    commentObj.videoId = videoId;
    commentObj.comment = commentValue;
    commentObj.userId = userRepo.currentUser.value.userId;
    commentObj.token = userRepo.currentUser.value.token;
    commentObj.userDp = userRepo.currentUser.value.userDP;
    commentObj.userName = userRepo.currentUser.value.userName;
    commentObj.time = 'just now';
    commentValue = '';
    if (!showFollowingPage.value) {
      videoRepo.videosData.value.videos.elementAt(swiperIndex).totalComments =
          videoRepo.videosData.value.videos.elementAt(swiperIndex).totalComments + 1;
    } else {
      videoRepo.followingUsersVideoData.value.videos.elementAt(swiperIndex2).totalComments =
          videoRepo.followingUsersVideoData.value.videos.elementAt(swiperIndex2).totalComments + 1;
    }

    await commentRepo.addComment(commentObj).then((commentId) {
      commentObj.commentId = commentId;
      // comments.insert(0, commentObj);
      print("commentObj");
      print(commentObj.toJson());
      comments.add(commentObj);
      loadMoreUpdateView.value = true;
      loadMoreUpdateView.notifyListeners();
    }).catchError((e) {
      context.showSnackBar(SnackBar(
        content: Text("There's some issue with the server"),
      ));
    });
  }

  VideoPlayerController videoController(int index) {
    if (videoRepo.videosData.value.videos.length > 0) {
      return videoControllers[videoRepo.videosData.value.videos.elementAt(index).url];
    }
  }

  VideoPlayerController videoController2(int index) {
    if (videoRepo.followingUsersVideoData.value.videos.length > 0) {
      return videoControllers2[videoRepo.followingUsersVideoData.value.videos.elementAt(index).url];
    }
  }

  Future<void> initController(int index) async {
    print('>>>>>>>>>>>>>>>>>>>>>>endlistener1 init '+index.toString());

    try {
      var controller = await getControllerForVideo(videoRepo.videosData.value.videos.elementAt(index).url);
      videoControllers[videoRepo.videosData.value.videos.elementAt(index).url] = controller;
      initializeVideoPlayerFutures[videoRepo.videosData.value.videos.elementAt(index).url] = controller.initialize();
      controller.setLooping(true);
      // controller.addListener(() {endListener1(index);});

    } catch (e) {
      print("Init Catch Error: " + e);
    }
  }

  Future<VideoPlayerController> getControllerForVideo(String video) async {
    try {
      final fileInfo =  null;//await DefaultCacheManager().getFileFromCache(video);//web buildhez
      VideoPlayerController controller;
      double volume = 1;

      if (fileInfo == null || fileInfo.file == null) {
        unawaited(DefaultCacheManager().downloadFile(video).whenComplete(() => print('saved video url $video')));
        controller = VideoPlayerController.network(video);
        controller.setVolume(volume);
        return controller;
      } else {
        controller = VideoPlayerController.file(fileInfo.file);
        controller.setVolume(volume);
        return controller;
      }
    } catch (e) {
      print(e.toString() + "Cache Errors");
    }
  }

  Future<bool> checkEulaAgreement() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool check = prefs.getBool('EULA_agree');
    if (check != null) {
      if (!check) {
        try {
          userRepo.checkEulaAgreement().then((agree) {
            if (agree) {
              prefs.setBool('EULA_agree', agree);
            } else {
              getEulaAgreement();
            }
          });
        } catch (e) {
          print(e.toString() + "Cache Errors");
        }
      } else {
        return true;
      }
    } else {
      try {
        userRepo.checkEulaAgreement().then((agree) {
          if (agree) {
            prefs.setBool('EULA_agree', agree);
          } else {
            getEulaAgreement();
          }
        });
      } catch (e) {
        print(e.toString() + "Cache Errors");
      }
    }
  }

  Future<void> getEulaAgreement() async {
    try {
      userRepo.getEulaAgreement().then((value) {
        print("getEulaAgreement");
        print(value);
        var data = json.decode(value);
        print(data['title']);
        print(scaffoldKey);
        Navigator.of(scaffoldKey?.currentContext).pushReplacement(
          MaterialPageRoute(builder: (context) {
            return WillPopScope(
              onWillPop: () {
                DateTime now = DateTime.now();
                if (videoRepo.homeCon.value != null && videoRepo.homeCon.value.pc != null && videoRepo.homeCon.value.pc.isPanelOpen) {
                  print("if check will");
                  videoRepo.homeCon.value.pc.close();
                  return Future.value(false);
                }
                // widget.cont.pc.isPanelOpen ??

                if (currentBackPressTime == null || now.difference(currentBackPressTime) > Duration(seconds: 2)) {
                  currentBackPressTime = now;
                  Fluttertoast.showToast(msg: "Tap again to exit an app.");
                  return Future.value(false);
                }
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                return Future.value(true);
              },
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.blueAccent,
                  automaticallyImplyLeading: false,
                  title: Center(
                    child: Text(
                      data['title'],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                body: SingleChildScrollView(
                  child: Text(
                    data['content'],
                  ),
                ),
                floatingActionButton: FloatingActionButton.extended(
                  backgroundColor: Colors.blueAccent,
                  onPressed: () {
                    userRepo.agreeEula().then((value) {
                      if (value) {
                        videoRepo.homeCon.value.showFollowingPage.value = false;
                        videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                        videoRepo.homeCon.value.getVideos();
                        Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                      }
                    });
                  },
                  icon: Icon(Icons.check),
                  label: Text("Agree"),
                ),
              ),
            );
          }),
        );
      });
    } catch (e) {
      print(e.toString() + "Cache Errors");
    }
    return true;
  }

  Future<void> initController2(int index) async {
    print('>>>>>>>>>>>>>>>>>>>>>>endlistener2 init '+index.toString());

    try {
      var controller = await getControllerForVideo(videoRepo.followingUsersVideoData.value.videos.elementAt(index).url);
      print("cachedcontroller1");
      videoControllers2[videoRepo.followingUsersVideoData.value.videos.elementAt(index).url] = controller;
      initializeVideoPlayerFutures2[videoRepo.followingUsersVideoData.value.videos.elementAt(index).url] = controller.initialize();
      controller.setLooping(false);
      controller.addListener(endListener2);
    } catch (e) {
      print("Init Catch Error: " + e);
    }
  }

  bool alreadyGrowed = false;

  //TODO endlistenereket kigyomlalni miutan szurt peldaul
  void endListener1(int videoIndex){
//    print('>>>>>>>>>>>>>>>>>>>>>>endlistener1 videoIndex ' + videoIndex.toString());
//    print('>>>>>>>>>>>>>>>>>>>>>>endlistener1 0000 ' + videoControllers[videoRepo.videosData .value.videos.elementAt(videoIndex).url].value.position.toString());
//   Duration d =  videoControllers[videoRepo.videosData.value.videos.elementAt(videoIndex).url].value.position;
//     if( videoRepo.videosData.value.videos.elementAt(videoIndex).totalViews!=null && videoRepo.videosData.value.videos.elementAt(videoIndex).totalViews > 0 && videoRepo.videosData.value.videos.length > videoIndex && d <  Duration( milliseconds: 4000)) {
//       videoRepo.videosData.value.videos.elementAt(videoIndex).totalViews = 0;
//     }
//     if( (videoRepo.videosData.value.videos.elementAt(videoIndex).totalViews ==null||videoRepo.videosData.value.videos.elementAt(videoIndex).totalViews < 1) && videoRepo.videosData.value.videos.length > videoIndex && d >  Duration( milliseconds: 4000)) {
//       videoRepo.videosData.value.videos.elementAt(videoIndex).totalViews = 1;
//       updateHistory(videoRepo.videosData.value.videos.elementAt(videoIndex).videoId.toString());
//
//     }
      if(videoRepo.videosData.value.videos.length > videoIndex && videoControllers[videoRepo.videosData.value.videos.elementAt(videoIndex).url].value.position == videoControllers[videoRepo.videosData .value.videos.elementAt(videoIndex).url].value.duration) {
      print('>>>>>>>>>>>>>>>>>>>>>>endlistener1 1');
      print('>>>>>>>>>>>>>>>>>>>>>>endlistener1 index ' + index.toString());
      print('>>>>>>>>>>>>>>>>>>>>>>endlistener1 videoindex ' + videoIndex.toString());
      print('>>>>>>>>>>>>>>>>>>>>>>endlistener1  videoRepo.videosData.value.videos.length.toString() ' + videoRepo.videosData.value.videos.length.toString());
      print('>>>>>>>>>>>>>>>>>>>>>>endlistener1 url ' + videoRepo.videosData.value.videos
          .elementAt(videoIndex)
          .url);
      if (videoControllers[videoRepo.videosData.value.videos.elementAt(videoIndex).url] != null &&
          videoControllers[videoRepo.videosData.value.videos.elementAt(videoIndex).url].hasListeners) {
        videoControllers[videoRepo.videosData.value.videos.elementAt(videoIndex).url].removeListener(() {
          print('>>>>>>>>>>>>>>>>>>>>>>endlistener1 ujra');
          endListener1(videoIndex);
        });
        videoControllers[videoRepo.videosData.value.videos.elementAt(videoIndex).url].seekTo(Duration(seconds: 0, minutes: 0, hours: 0)).whenComplete(() {
          print('>>>>>>>>>>>>>>>>>>>>>>endlistener1 whenComplete');
          videoControllers[videoRepo.videosData.value.videos
              .elementAt(videoIndex)
              .url].pause();
        });
        if (videoRepo.videosData.value.videos.length >( videoIndex+1)) {
          print('>>>>>>>>>>>>>>>>>>>>>>endlistener1 swipeController.next(animation: true);');
          swipeController.next(animation: true);
        }
        print('>>>>>>>>>>>>>>>>>>>>>>endlistener1 removed');
      }
    }

  }
  void endListener2(){
    print('>>>>>>>>>>>>>>>>>>>>>>endlistener2 1');
    print('>>>>>>>>>>>>>>>>>>>>>>endlistener2 index '+index.toString());
    print('>>>>>>>>>>>>>>>>>>>>>>endlistener2 videoindex '+videoIndex.toString());
    print('>>>>>>>>>>>>>>>>>>>>>>endlistener2 url '+videoRepo.followingUsersVideoData.value.videos.elementAt(index).url);
    // Duration d =  videoControllers2[videoRepo.videosData.value.videos.elementAt(videoIndex).url].value.position;
    // if( videoRepo.videosData.value.videos.elementAt(videoIndex).totalViews!=null && videoRepo.videosData.value.videos.elementAt(videoIndex).totalViews > 0 && videoRepo.videosData.value.videos.length > videoIndex && d <  Duration( milliseconds: 4000)) {
    //   videoRepo.videosData.value.videos.elementAt(videoIndex).totalViews = 0;
    // }
    // if( (videoRepo.videosData.value.videos.elementAt(videoIndex).totalViews ==null||videoRepo.videosData.value.videos.elementAt(videoIndex).totalViews < 1)  && videoRepo.videosData.value.videos.length > videoIndex && d >  Duration( milliseconds: 4000)) {
    //   videoRepo.videosData.value.videos.elementAt(videoIndex).totalViews = 1;
    //   updateHistory(videoRepo.videosData.value.videos.elementAt(videoIndex).videoId.toString());
    // }
    if (videoControllers2[videoRepo.followingUsersVideoData.value.videos.elementAt(index).url]!=null) {
      videoControllers2[videoRepo.followingUsersVideoData.value.videos.elementAt(index).url].removeListener(endListener2);
      print('>>>>>>>>>>>>>>>>>>>>>>endlistener2 removed');

    }
  }

  void removeController(int count) async {
    try {
      print('DISPOSE 7');
      await videoController(count)?.dispose();
      print('DISPOSE 7<');
      videoControllers.remove(videoRepo.videosData.value.videos.elementAt(count));
      initializeVideoPlayerFutures.remove(videoRepo.videosData.value.videos.elementAt(count));
    } catch (e) {
      print("Catch: " + e);
    }
  }

  void removeController2(int count) async {
    try {
      print('DISPOSE 8');
      await videoController2(count)?.dispose();
      print('DISPOSE 8<');
      videoControllers2.remove(videoRepo.followingUsersVideoData.value.videos.elementAt(count));
      initializeVideoPlayerFutures2.remove(videoRepo.followingUsersVideoData.value.videos.elementAt(count));
    } catch (e) {
      print("Catch: " + e);
    }
  }

  void stopController(int index) {
    videoController(index)?.pause();
    print("paused $index");
  }

  void playController(int index) async {
    print("Play1");
    videoControllers.forEach((key, value) {
      print("pause");
      value.pause();
    });
    print("Play11 "+index.toString());
    videoController(index)?.play();
    print("Play1 utan");
  }

  void stopController2(int index) {
    videoController2(index)?.pause();
  }

  void playController2(int index) async {
    print("Play2");
    // videoControllers2.forEach((key, value) {
    //   value.pause();
    // });
    videoController2(index)?.play();
  }

  //Swipe Prev Video
  void previousVideo(ind) async {
    print("Index");
    print(ind);
    if (ind < 0) {
      return;
    }
    lock = true;
    stopController(ind + 1);

    if (ind + 2 < videoRepo.videosData.value.videos.length) {
      print('DISPOSE 77');
      await removeController(ind + 2);
      print('DISPOSE 77<');
    }

    playController(ind);

    if (ind == 0) {
      lock = false;
    } else {
      initController(ind - 1).whenComplete(() => lock = false);
    }
  }

  void previousVideo2(ind) async {
    if (ind < 0) {
      return;
    }
    lock = true;
    stopController2(ind + 1);

    if (ind + 2 < videoRepo.followingUsersVideoData.value.videos.length) {
      removeController2(ind + 2);
    }

    playController2(ind);

    if (ind == 0) {
      lock = false;
    } else {
      initController2(ind - 1).whenComplete(() => lock = false);
    }
  }

  //Swipe Next Video
  void nextVideo(ind) async {
    if (ind > videoRepo.videosData.value.videos.length - 1) {
      return;
    }
    lock = true;
    stopController(ind - 1);
    if (ind - 2 >= 0) {
      print('DISPOSE 777');
      await removeController(ind - 2);
      print('DISPOSE 777<');
    }
    playController(ind);
    if (ind == videoRepo.videosData.value.videos.length - 1) {
      lock = false;
    } else {
      initController(ind + 1).whenComplete(() => lock = false);
    }
  }

  void nextVideo2(ind) async {
    if (ind > videoRepo.followingUsersVideoData.value.videos.length - 1) {
      return;
    }
    lock = true;
    stopController2(ind - 1);
    if (ind - 2 >= 0) {
      removeController2(ind - 2);
    }
    playController2(ind);
    if (ind != videoRepo.followingUsersVideoData.value.videos.length - 1) {
      initController2(ind + 1);
    }
  }

  Future<void> preCacheVideos() {
    for (final e in videoRepo.videosData.value.videos) {
      Video video = e;
      try {
        CustomCacheManager.instance.downloadFile(video.url);
      } catch (e) {
        print(e.toString() + "Cache Errors");
      }
    }
    return Future.value();
  }

  Future<void> followUnfollowUser(Video videoObj) async {
    setState(() {});
    followUnfollowLoader = true;
    if (videoRepo.homeCon.value.showFollowingPage.value) {
      print("followUnf1");

      if (videoRepo.followingUsersVideoData.value.videos.length == 1 &&
          videoRepo.followingUsersVideoData.value.videos.elementAt(videoRepo.homeCon.value.swiperIndex2).followText == "Unfollow") {
        videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2).pause();
      }
    }

    videoRepo.followUnfollowUser(videoObj).then((value) {
      followUnfollowLoader = false;
      var response = json.decode(value);
      if (response['status'] == 'success') {
        videoObj.isFollowing = response['followText'] == 'Follow' ? 0 : 1;
        loadMoreUpdateView.value = true;
        loadMoreUpdateView.notifyListeners();
        // getFollowingUserVideos();
        for (var item in videoRepo.videosData.value.videos) {
          if (videoObj.userId == item.userId) {
            item.isFollowing = response['followText'] == 'Follow' ? 0 : 1;
          }
        }
      }
    }).catchError((e) {
      followUnfollowLoader = false;
      ScaffoldMessenger.of(lastContext).showSnackBar(SnackBar(
        content: Text("There is some error"),
      ));
    });
  }
}
