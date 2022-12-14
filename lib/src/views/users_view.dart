import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/user_controller.dart';
import '../helpers/helper.dart';
import '../models/videos_model.dart';
import '../repositories/user_repository.dart';
import '../repositories/video_repository.dart' as videoRepo;

class UsersView extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  UsersView({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _UsersViewState createState() => _UsersViewState();
}

class _UsersViewState extends StateMVC<UsersView> {
  UserController _con;
  _UsersViewState() : super(UserController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.getUsers(1);
    super.initState();
  }

  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;
    return WillPopScope(
      onWillPop: () async {
        videoRepo.homeCon.value.showFollowingPage.value = false;
        videoRepo.homeCon.value.showFollowingPage.notifyListeners();
        print('HHHHHHHHHHHHHHHHHHHHHHooolgetvideos17');
        videoRepo.homeCon.value.getVideos();
        Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
        return Future.value(true);
      },
      child: ValueListenableBuilder(
          valueListenable: usersData,
          builder: (context, VideoModel data, _) {
            return ModalProgressHUD(
              inAsyncCall: _con.showLoader,
              progressIndicator: Helper.showLoaderSpinner(Colors.white),
              child: SafeArea(
                child: Scaffold(
                  key: _con.userScaffoldKey,
                  resizeToAvoidBottomInset: false,
                  body: SafeArea(
                      child: SingleChildScrollView(
                    child: Container(
                      color: Color(0XFF15161a),
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 15, 0, 0),
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
                                              _con.getUsers(1);
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
                                              _con.getUsers(1);
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
                            height: 8,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 13, bottom: 2, left: 15),
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
                          (data.videos.length > 0)
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height - 110,
                                    child: GridView.builder(
                                      controller: _con.scrollController1,
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
                                        final item = data.videos.elementAt(i);
                                        return AnimationConfiguration.staggeredList(
                                          position: i,
                                          duration: const Duration(milliseconds: 300),
                                          child: SlideAnimation(
                                            verticalOffset: 20.0,
                                            child: FadeInAnimation(
                                              child: GestureDetector(
                                                onTap: () {
//                                        Navigator.push(
//                                          context,
//                                          MaterialPageRoute(
//                                              builder: (context) => HomePage(
//                                                  videoModelList.data[i])),
//                                        );
                                                },
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: <Widget>[
                                                    Container(
                                                        height: MediaQuery.of(context).size.height,
                                                        width: MediaQuery.of(context).size.width,
                                                        child: item.videoThumbnail != ""
                                                            ? Container(
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(5),
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
                                                                    borderRadius: BorderRadius.circular(5.0),
                                                                    child: CachedNetworkImage(
                                                                      imageUrl: item.videoThumbnail,
                                                                      placeholder: (context, url) => Center(
                                                                        child: Helper.showLoaderSpinner(Colors.white),
                                                                      ),
                                                                      fit: BoxFit.cover,
                                                                    )),
                                                              )
                                                            : ClipRRect(
                                                                borderRadius: BorderRadius.circular(5.0),
                                                                child: Image.asset(
                                                                  'assets/images/noVideo.jpg',
                                                                  fit: BoxFit.fill,
                                                                ),
                                                              )),
                                                    Container(
                                                      color: Colors.black12,
                                                    ),
                                                    Positioned(
                                                      bottom: 55,
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
                                                                image: (item.userDP != "")
                                                                    ? NetworkImage(
                                                                        item.userDP,
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
                                                        bottom: 37,
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              item.username,
                                                              style: TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'RockWellStd', fontWeight: FontWeight.bold),
                                                            ),
                                                            SizedBox(width: 5),
                                                            item.isVerified == true
                                                                ? Icon(
                                                                    Icons.verified,
                                                                    color: Colors.blueAccent,
                                                                    size: 16,
                                                                  )
                                                                : Container(),
                                                          ],
                                                        )),
                                                    Positioned(
                                                      bottom: -5,
                                                      child: ButtonTheme(
                                                        minWidth: 80,
                                                        height: 25,
                                                        child: ElevatedButton(
                                                          child: Container(
                                                            height: 25,
                                                            width: 80,
                                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(3.0), gradient: Gradients.blush),
                                                            child: Center(
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                children: <Widget>[
                                                                  ((_con.followUserId != item.userId))
                                                                      ? Text(
                                                                          item.followText,
                                                                          style: TextStyle(
                                                                            color: Colors.white,
                                                                            fontWeight: FontWeight.bold,
                                                                            fontSize: 11,
                                                                            fontFamily: 'RockWellStd',
                                                                          ),
                                                                        )
                                                                      : Helper.showLoaderSpinner(Colors.white),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            setState(() {
                                                              _con.followUnfollowUser(item.userId, i);
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    ),
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
                              : (!_con.showUserLoader)
                                  ? Center(
                                      child: Container(
                                        height: MediaQuery.of(context).size.height - 360,
                                        width: MediaQuery.of(context).size.width,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Container(
                                              margin: EdgeInsets.all(10),
                                              padding: EdgeInsets.all(5),
                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), border: Border.all(width: 2, color: Colors.grey)),
                                              child: Icon(
                                                Icons.person,
                                                color: Colors.grey,
                                                size: 20,
                                              ),
                                            ),
                                            Text(
                                              "No User Yet",
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
                  )),
                ),
              ),
            );
          }),
    );
  }
}
