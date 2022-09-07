import 'dart:convert';
import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../models/hash_videos_model.dart';
import '../repositories/hash_repository.dart' as hashRepo;
import '../repositories/video_repository.dart' as videoRepo;
import 'dashboard_controller.dart';

class HashVideosController extends ControllerMVC {
  GlobalKey<ScaffoldState> scaffoldKey;
  GlobalKey<FormState> formKey;
  PanelController pc = new PanelController();
  ScrollController scrollController;
  bool showLoader = false;
  bool showLoadMore = true;
  String searchKeyword = '';
  DashboardController homeCon;
  var searchController = TextEditingController();
  BannerAd bannerAd;
  InterstitialAd _interstitialAd;
  String appId = '';
  String bannerUnitId = '';
  String screenUnitId = '';
  String videoUnitId = '';
  String bannerShowOn = '';
  String interstitialShowOn = '';
  String videoShowOn = '';
  HashVideosController() {
    getAds();
  }

  @override
  void initState() {
    scaffoldKey = new GlobalKey<ScaffoldState>();
    formKey = new GlobalKey<FormState>();
    super.initState();
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

  Future<HashVideosModel> getData(page) {
    homeCon = videoRepo.homeCon.value;
    homeCon.userVideoObj.value['userId'] = 0;
    homeCon.userVideoObj.value['videoId'] = 0;
    homeCon.userVideoObj.notifyListeners();
    homeCon.notifyListeners();
    setState(() {});
    showLoader = true;
    scrollController = new ScrollController();
    hashRepo.getData(page, searchKeyword).then((value) {
      showLoader = false;
      if (value.videos.length == value.totalRecords) {
        showLoadMore = false;
      }
      scrollController.addListener(() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
          if (value.videos.length != value.totalRecords && showLoadMore) {
            page = page + 1;
            getData(page);
          }
        }
      });
    });
  }

  Future<void> getAds() {
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

          if (bannerShowOn.indexOf("3") > -1) {
            bannerAd ??= createBannerAd(bannerUnitId);
            bannerAd
              ..load()
              ..show();
          }

          if (interstitialShowOn.indexOf("3") > -1) {
            _interstitialAd?.dispose();
            _interstitialAd = createInterstitialAd(screenUnitId)
              ..load()
              ..show();
          }

          if (videoShowOn.indexOf("3") > -1) {
            rewardedVideoAd(videoUnitId);
            RewardedVideoAd.instance?.show();
          }
        }
      }
    });
  }
}
