import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:photo_view/photo_view.dart';

import '../controllers/user_controller.dart';
import '../helpers/helper.dart';
import '../models/user_profile_model.dart';
import '../repositories/user_repository.dart';
import '../repositories/user_repository.dart' as userRepo;
import '../repositories/video_repository.dart' as videoRepo;
import '../views/chat.dart';
import '../views/login_view.dart';

class UsersProfileView extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  final int userId;
  UsersProfileView({Key key, this.userId, this.parentScaffoldKey}) : super(key: key);

  @override
  _UsersProfileViewState createState() => _UsersProfileViewState();
}

class _UsersProfileViewState extends StateMVC<UsersProfileView> {
  UserController _con;
  _UsersProfileViewState() : super(UserController()) {
    _con = controller;
  }

  int page = 1;
  @override
  void initState() {
    // userProfile = new ValueNotifier(UserProfileModel());
    // userProfile.notifyListeners();
    _con.getAds();
    _con.getUsersProfile(widget.userId, page);
    super.initState();
  }

  @override
  void dispose() {
    _con.bannerAd?.dispose();
    _con.bannerAd = null;
    super.dispose();
  }

  Widget profilePhoto(userProfile) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(45.0),
                child: AppBar(
                  iconTheme: IconThemeData(
                    color: Colors.white, //change your color here
                  ),
                  backgroundColor: Color(0xff15161a),
                  title: Text(
                    "PROFILE PICTURE",
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
                  ),
                  centerTitle: true,
                ),
              ),
              backgroundColor: Colors.black,
              body: Center(
                child: PhotoView(
                  enableRotation: true,
                  imageProvider: CachedNetworkImageProvider((userProfile.largeProfilePic.toLowerCase().contains(".jpg") ||
                          userProfile.largeProfilePic.toLowerCase().contains(".jpeg") ||
                          userProfile.largeProfilePic.toLowerCase().contains(".png") ||
                          userProfile.largeProfilePic.toLowerCase().contains(".gif") ||
                          userProfile.largeProfilePic.toLowerCase().contains(".bmp") ||
                          userProfile.largeProfilePic.toLowerCase().contains("fbsbx.com") ||
                          userProfile.largeProfilePic.toLowerCase().contains("googleusercontent.com"))
                      ? userProfile.largeProfilePic
                      : '${GlobalConfiguration().getString('base_url')}' + "default/user-dummy-pic.png"),
                ),
              ));
        }));
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20,
        ),
        child: Container(
          width: 70.0,
          height: 70.0,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.white),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              width: 60.0,
              height: 60.0,
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: userProfile.smallProfilePic != null
                      ? CachedNetworkImageProvider((userProfile.smallProfilePic.toLowerCase().contains(".jpg") ||
                              userProfile.smallProfilePic.toLowerCase().contains(".jpeg") ||
                              userProfile.smallProfilePic.toLowerCase().contains(".png") ||
                              userProfile.smallProfilePic.toLowerCase().contains(".gif") ||
                              userProfile.smallProfilePic.toLowerCase().contains(".bmp") ||
                              userProfile.smallProfilePic.toLowerCase().contains("fbsbx.com") ||
                              userProfile.smallProfilePic.toLowerCase().contains("googleusercontent.com"))
                          ? userProfile.smallProfilePic
                          : '${GlobalConfiguration().getString('base_url')}' + "default/user-dummy-pic.png")
                      : AssetImage('assets/images/default-user.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget userVideo(userProfile) {
    if (userProfile.userVideos != null) {
      if (userProfile.userVideos.length > 0) {
        var size = MediaQuery.of(context).size;
        final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
        final double itemWidth = size.width / 2;
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
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
            itemCount: userProfile.userVideos.length,
            itemBuilder: (BuildContext context, int i) {
              return AnimationConfiguration.staggeredList(
                position: i,
                duration: const Duration(milliseconds: 300),
                child: SlideAnimation(
                  verticalOffset: 20.0,
                  child: FadeInAnimation(
                    child: GestureDetector(
                      onTap: () async {
                        _con.bannerAd?.dispose();
                        _con.bannerAd = null;
                        videoRepo.homeCon.value.userVideoObj.value['userId'] = userProfile.userVideos[i].userId;
                        videoRepo.homeCon.value.userVideoObj.value['videoId'] = userProfile.userVideos[i].videoId;
                        videoRepo.homeCon.value.userVideoObj.value['name'] = userProfile.name.split(" ").first + "'s";
                        videoRepo.homeCon.value.showFollowingPage.value = false;
                        videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                        videoRepo.homeCon.value.getVideos().whenComplete(() {
                          videoRepo.homeCon.notifyListeners();
                          Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                        });
                      },
                      child: Container(
                          child: Stack(
                        children: [
                          Container(
                              height: size.height,
                              decoration: BoxDecoration(
                                color: Colors.black,
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
                              child: Center(
                                child: userProfile.userVideos[i].videoThumbnail != ""
                                    ? CachedNetworkImage(
                                        imageUrl: userProfile.userVideos[i].videoThumbnail,
                                        placeholder: (context, url) => Helper.showLoaderSpinner(Colors.white),
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        'assets/images/noVideo.jpg',
                                        fit: BoxFit.fill,
                                      ),
                              )),
                          Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 7),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Icon(Icons.favorite, size: 13, color: Colors.white),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            Helper.formatter(userProfile.userVideos[i].totalLikes.toString()),
                                            style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Icon(Icons.remove_red_eye, size: 13, color: Colors.white),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            Helper.formatter(userProfile.userVideos[i].totalViews.toString()),
                                            style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      )),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      } else {
        if (!_con.showLoader) {
          return Center(
            child: Container(
              height: MediaQuery.of(context).size.height,
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
                    "No Videos Yet",
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  )
                ],
              ),
            ),
          );
        } else {
          return Container();
        }
      }
    } else {
      if (!_con.showLoader) {
        return Center(
          child: Container(
            height: MediaQuery.of(context).size.height,
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
                  "No Videos Yet",
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                )
              ],
            ),
          ),
        );
      } else {
        return Container();
      }
    }
  }

  Widget tabs(userProfile) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 0),
      child: DefaultTabController(
        length: 1,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              child: TabBar(
                onTap: (index) {
                  setState(() {
                    _con.curIndex = index;
                  });
                },
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.white,
                indicatorWeight: 0.2,
                labelPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                tabs: [
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          (0 == 0)
                              ? Image.asset(
                                  'assets/icons/my-video-e.png',
                                  width: 35,
                                )
                              : Image.asset('assets/icons/my-video-d.png', width: 35),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "User Videos",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height - 410,
                child: TabBarView(children: [
                  Container(child: userVideo(userProfile)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget profilePersonInfo(userProfile) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          userProfile.name != null ? userProfile.name : '',
          style: TextStyle(color: Color(0xfff5ae78), fontSize: 15, fontFamily: 'RockWellStd', fontWeight: FontWeight.w500),
        ),
        Row(
          children: [
            Text(
              userProfile.username != null ? userProfile.username : '',
              style: TextStyle(color: Color(0xfff5ae78), fontSize: 15, fontFamily: 'RockWellStd', fontWeight: FontWeight.w500),
            ),
            userProfile.isVerified == true
                ? Icon(
                    Icons.verified,
                    color: Colors.blueAccent,
                    size: 16,
                  )
                : Container(),
          ],
        ),
        userRepo.currentUser.value.userId != widget.userId
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: Container(
                      height: 25,
                      width: 80,
                      decoration: BoxDecoration(gradient: Gradients.blush),
                      child: Center(
                        child: (!_con.followUnfollowLoader)
                            ? Text(
                                userProfile.followText != null ? userProfile.followText : "Follow",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  fontFamily: 'RockWellStd',
                                ),
                              )
                            : Helper.showLoaderSpinner(Colors.white),
                      ),
                    ),
                    onPressed: () {
                      if (currentUser.value.token == null) {
                        _con.bannerAd?.dispose();
                        _con.bannerAd = null;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPageView(userId: widget.userId),
                          ),
                        );
                      } else {
                        _con.followUnfollowUserFromUserProfile(widget.userId);
                      }
                    },
                  ),
                  ElevatedButton(
                    child: Container(
                      height: 25,
                      width: 80,
                      decoration: BoxDecoration(gradient: Gradients.blush),
                      child: Center(
                          child: Text(
                        "Chat",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          fontFamily: 'RockWellStd',
                        ),
                      )),
                    ),
                    onPressed: () {
                      if (currentUser.value.token == null) {
                        _con.bannerAd?.dispose();
                        _con.bannerAd = null;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPageView(userId: widget.userId),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatView(
                              userId: widget.userId,
                              userName: userProfile.username,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              )
            : Container(),
        Container(
          child: Text(
            userRepo.userProfile.value.bio,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (videoRepo.homeCon.value.showFollowingPage.value) {
          await videoRepo.homeCon.value.getFollowingUserVideos();
        } else {
          print('HHHHHHHHHHHHHHHHHHHHHHooolgetvideos14');
          await videoRepo.homeCon.value.getVideos();
        }
        videoRepo.homeCon.notifyListeners();
        Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
        return Future.value(true);
      },
      child: ValueListenableBuilder(
          valueListenable: userProfile,
          builder: (context, UserProfileModel _userProfile, _) {
            return ModalProgressHUD(
              inAsyncCall: _con.showLoader,
              progressIndicator: Helper.showLoaderSpinner(Colors.white),
              child: SafeArea(
                child: Scaffold(
                  key: _con.userScaffoldKey,
                  // resizeToAvoidBottomPadding: false,
                  resizeToAvoidBottomInset: false,
                  body: RefreshIndicator(
                    onRefresh: _con.refreshUserProfile,
                    child: Container(
                      color: Color(0XFF15161a),
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 15, 10, 5),
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
                                  Container(
                                    width: MediaQuery.of(context).size.width * .78,
                                  ),
                                  currentUser.value.token != null
                                      ? PopupMenuButton<int>(
                                          color: Color(0xff444549),
                                          icon: Icon(Icons.more_vert, size: 22, color: Colors.white),
                                          onSelected: (int) {
                                            _con.blockUser(widget.userId);
                                          },
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              value: 1,
                                              child: Text(
                                                _userProfile.blocked == 'yes' ? 'Unblock' : 'Block',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'RockWellStd',
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                            child: Container(
                              // height: 180,
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  _userProfile != null
                                      ? profilePhoto(_userProfile)
                                      : SizedBox(
                                          height: 0,
                                        ),
                                  _userProfile != null
                                      ? profilePersonInfo(_userProfile)
                                      : SizedBox(
                                          height: 0,
                                        ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3, bottom: 3),
                                        child: Text(
                                          _userProfile.totalVideosLike != null ? _userProfile.totalVideosLike : '',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "LIKES",
                                        style: TextStyle(color: Colors.white, fontSize: 11),
                                      )
                                    ],
                                  ),
                                ),
                                Container(height: 35, width: 0.8, color: Colors.white),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3, bottom: 3),
                                        child: Text(
                                          _userProfile.totalFollowings != null ? _userProfile.totalFollowings : '',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "FOLLOWING",
                                        style: TextStyle(color: Colors.white, fontSize: 11),
                                      )
                                    ],
                                  ),
                                ),
                                Container(height: 35, width: 0.8, color: Colors.white),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3, bottom: 3),
                                        child: Text(
                                          _userProfile.totalFollowers != null ? _userProfile.totalFollowers : '',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "FOLLOWERS",
                                        style: TextStyle(color: Colors.white, fontSize: 11),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 0.4)),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          SingleChildScrollView(
                            child: Container(
                              child: tabs(_userProfile),
                            ),
                          ),
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
