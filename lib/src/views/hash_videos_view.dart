import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/hash_videos_controller.dart';
import '../helpers/helper.dart';
import '../models/hash_videos_model.dart';
import '../repositories/hash_repository.dart';
import '../repositories/video_repository.dart' as videoRepo;

class HashVideosView extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  HashVideosView({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _HashVideosViewState createState() => _HashVideosViewState();
}

class _HashVideosViewState extends StateMVC<HashVideosView> {
  HashVideosController _con;
  int page = 1;
  _HashVideosViewState() : super(HashVideosController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.getData(page);
    super.initState();
  }

  @override
  void dispose() {
    _con.bannerAd?.dispose();
    _con.bannerAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;
    return WillPopScope(
      onWillPop: () async {
        videoRepo.homeCon.value.showFollowingPage.value = false;
        videoRepo.homeCon.value.showFollowingPage.notifyListeners();
        print('HHHHHHHHHHHHHHHHHHHHHHooolgetvideos15');
        videoRepo.homeCon.value.getVideos();
        Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
        return Future.value(true);
      },
      child: ValueListenableBuilder(
          valueListenable: hashData,
          builder: (context, HashVideosModel data, _) {
            return ModalProgressHUD(
              inAsyncCall: _con.showLoader,
              progressIndicator: Helper.showLoaderSpinner(Colors.white),
              child: SafeArea(
                child: Scaffold(
                  key: _con.scaffoldKey,
                  // resizeToAvoidBottomPadding: false,
                  resizeToAvoidBottomInset: false,
                  body: SingleChildScrollView(
                    child: Container(
                      color: Color(0XFF15161a),
                      // height: MediaQuery.of(context).size.height,
                      // width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(5, 15, 0, 0),
                            child: Container(
                              height: 24,
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () async {
                                      videoRepo.homeCon.value.showFollowingPage.value = false;
                                      videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                                      videoRepo.homeCon.value.getVideos();
                                      Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                                    },
                                    child: Icon(
                                      Icons.arrow_back_ios,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10, right: 10),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width - 50,
                                      child: TextField(
                                        controller: _con.searchController,
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 16.0,
                                        ),
                                        obscureText: false,
                                        keyboardType: TextInputType.text,
                                        onChanged: (String val) {
                                          setState(() {
                                            _con.searchKeyword = val;
                                          });
                                          if (val.length > 2) {
                                            Timer(Duration(seconds: 1), () {
                                              _con.getData(1);
                                            });
                                          }
                                        },
                                        decoration: new InputDecoration(
                                          border: UnderlineInputBorder(
                                            borderSide: BorderSide(color: Colors.white54, width: 0.3),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: Colors.white54, width: 0.3),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: Colors.white54, width: 0.3),
                                          ),
                                          hintText: "Search",
                                          hintStyle: TextStyle(fontSize: 16.0, color: Colors.white54),
                                          //contentPadding:EdgeInsets.all(10),
                                          suffixIcon: IconButton(
                                            padding: EdgeInsets.only(bottom: 12),
                                            onPressed: () {
                                              _con.searchController.clear();
                                              setState(() {
                                                _con.searchKeyword = "";
                                              });
                                              _con.getData(1);
                                            },
                                            icon: Icon(
                                              Icons.clear,
                                              color: (_con.searchKeyword.length > 0) ? Colors.white54 : Colors.black,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10, left: 10),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                child: Text(
                                  'Challenges',
                                  style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ),
                          (data.banners != null)
                              ? Container(
                                  height: 150,
                                  width: MediaQuery.of(context).size.width,
                                  child: CarouselSlider(
                                    options: CarouselOptions(
                                      enlargeCenterPage: true,
                                      viewportFraction: 0.8,
                                      aspectRatio: 2.0,
                                      height: 150.0,
                                      initialPage: 0,
                                      autoPlay: true,
                                      autoPlayInterval: Duration(seconds: 8),
                                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                                      enableInfiniteScroll: true,
                                      reverse: false,
                                    ),
                                    items: data.banners.map((var value) {
                                      return Builder(
                                        builder: (BuildContext context) {
                                          return AnimationConfiguration.staggeredList(
                                            position: 0,
                                            duration: const Duration(milliseconds: 250),
                                            child: SlideAnimation(
                                              verticalOffset: 20.0,
                                              child: FadeInAnimation(
                                                child: Container(
                                                  width: MediaQuery.of(context).size.width,
                                                  child: CachedNetworkImage(
                                                    imageUrl: value.banner,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context, url) => Center(
                                                      child: Helper.showLoaderSpinner(Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                                  ))
                              : Container(),
                          Padding(
                            padding: const EdgeInsets.only(top: 13, bottom: 2, left: 10),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                child: Text(
                                  'Recommended',
                                  style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ),
                          (data.videos != null && data.videos.length > 0)
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height - 310,
                                    child: GridView.builder(
                                      controller: _con.scrollController,
                                      primary: false,
                                      padding: const EdgeInsets.all(2),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        childAspectRatio: (itemWidth / itemHeight),
                                        crossAxisSpacing: 15,
                                        mainAxisSpacing: 15,
                                        crossAxisCount: 3,
                                      ),
                                      itemCount: data.videos.length,
                                      itemBuilder: (BuildContext context, int i) {
                                        return AnimationConfiguration.staggeredList(
                                          position: i,
                                          duration: const Duration(milliseconds: 300),
                                          child: SlideAnimation(
                                            verticalOffset: 20.0,
                                            child: FadeInAnimation(
                                              child: GestureDetector(
                                                onTap: () async {
                                                  print("Click Hash Videos");
                                                  print(data.videos[i].userName);

                                                  videoRepo.homeCon.value.userVideoObj.value['userId'] = data.videos[i].userId;
                                                  videoRepo.homeCon.value.userVideoObj.value['videoId'] = data.videos[i].id;
                                                  videoRepo.homeCon.value.userVideoObj.value['name'] = data.videos[i].userName + "'s";

                                                  videoRepo.homeCon.value.getVideos().whenComplete(() {
                                                    videoRepo.homeCon.notifyListeners();
                                                    Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                                                  });
                                                },
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: <Widget>[
                                                    Container(
                                                        height: MediaQuery.of(context).size.height,
                                                        width: MediaQuery.of(context).size.width,
                                                        child: data.videos[i].thumb != ""
                                                            ? Container(
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(10),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors.white.withOpacity(0.6),
                                                                      blurRadius: 3.0, // soften the shadow
                                                                      spreadRadius: 0.0, //extend the shadow
                                                                      offset: Offset(
                                                                        0.0, // Move to right 10  horizontally
                                                                        0.0, // Move to bottom 5 Vertically
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                                padding: const EdgeInsets.all(1),
                                                                child: ClipRRect(
                                                                  borderRadius: BorderRadius.circular(
                                                                    5.0,
                                                                  ),
                                                                  child: CachedNetworkImage(
                                                                    imageUrl: data.videos[i].thumb,
                                                                    placeholder: (context, url) => Center(
                                                                      child: Helper.showLoaderSpinner(Colors.white),
                                                                    ),
                                                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                                                    fit: BoxFit.cover,
                                                                  ),
                                                                ),
                                                              )
                                                            : ClipRRect(
                                                                borderRadius: BorderRadius.circular(5.0),
                                                                child: Image.asset(
                                                                  'assets/images/noVideo.jpg',
                                                                  fit: BoxFit.fill,
                                                                ),
                                                              )),
                                                    Positioned(
                                                      bottom: 20,
                                                      child: Container(
                                                        width: 35.0,
                                                        height: 35.0,
                                                        decoration: new BoxDecoration(
                                                          borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
                                                          border: new Border.all(
                                                            color: Colors.white,
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                        child: Container(
                                                          width: 35.0,
                                                          height: 35.0,
                                                          decoration: new BoxDecoration(
                                                            image: new DecorationImage(
                                                                image: (data.videos[i].dp != "")
                                                                    ? NetworkImage(
                                                                        data.videos[i].dp,
                                                                      )
                                                                    : AssetImage(
                                                                        'assets/images/default-user.png',
                                                                      ),
                                                                fit: BoxFit.contain),
                                                            borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                        bottom: 5,
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              data.videos[i].userName,
                                                              style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 11,
                                                                  fontFamily: 'RockWellStd',
                                                                  fontWeight: FontWeight.bold),
                                                            ),
                                                            data.videos[i].isVerified == true ? SizedBox(width: 5) : Container(),
                                                            data.videos[i].isVerified == true
                                                                ? Icon(
                                                                    Icons.verified,
                                                                    color: Colors.blueAccent,
                                                                    size: 16,
                                                                  )
                                                                : Container(),
                                                          ],
                                                        )),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                              : (!_con.showLoader)
                                  ? Center(
                                      child: Container(
                                        height: MediaQuery.of(context).size.height - 360,
                                        width: MediaQuery.of(context).size.width,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(
                                              Icons.videocam,
                                              size: 30,
                                              color: Colors.grey,
                                            ),
                                            Text(
                                              "No Videos Found",
                                              style: TextStyle(color: Colors.grey, fontSize: 15),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}

class SettingMenu {
  static const String LOGOUT = 'Logout';
  static const String EDIT_PROFILE = 'Edit Profile';
  static const List<String> choices = <String>[EDIT_PROFILE, LOGOUT];
}
