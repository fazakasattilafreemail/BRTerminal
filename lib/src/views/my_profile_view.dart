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
import '../repositories/video_repository.dart' as videoRepo;
import '../views/edit_profile_view.dart';
import '../views/followings.dart';
import '../views/verify_profile.dart';
import 'change_password_view.dart';

class MyProfileView extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  MyProfileView({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _MyProfileViewState createState() => _MyProfileViewState();
}

class _MyProfileViewState extends StateMVC<MyProfileView> {
  UserController _con;
  int page = 1;
  _MyProfileViewState() : super(UserController()) {
    _con = controller;
  }

  @override
  void initState() {
    // userProfile = new ValueNotifier(UserProfileModel());
    // userProfile.notifyListeners();
    _con.getMyProfile(page);
    super.initState();
  }

  void onSelectedMenu(String choice) {
    if (choice == SettingMenu.LOGOUT) {
      logout().whenComplete(() async {
        videoRepo.homeCon.value.showFollowingPage.value = false;
        videoRepo.homeCon.value.showFollowingPage.notifyListeners();
        print('HHHHHHHHHHHHHHHHHHHHHHooolgetvideos18');
        videoRepo.homeCon.value.getVideos();
        Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
      });
    } else if (choice == SettingMenu.EDIT_PROFILE) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfileView(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyProfileView(),
        ),
      );
    }
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
                        videoRepo.homeCon.value.userVideoObj.value['userId'] = currentUser.value.userId;
                        videoRepo.homeCon.value.userVideoObj.value['videoId'] = userProfile.userVideos[i].videoId;
                        videoRepo.homeCon.value.userVideoObj.notifyListeners();

                        videoRepo.homeCon.value.showFollowingPage.value = false;
                        videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                        videoRepo.homeCon.value.getVideos();
                        Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
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
                                            userProfile.userVideos[i].totalLikes.toString(),
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
                                            userProfile.userVideos[i].totalViews.toString(),
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
        ElevatedButton(

          child: Container(
            height: 25,
            width: 80,
            decoration: BoxDecoration(gradient: Gradients.blush),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    "Edit Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      fontFamily: 'RockWellStd',
                    ),
                  ),
                ],
              ),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProfileView(),
              ),
            );
          },
        ),
        Container(
          child: Text(
            userProfile.bio,
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
          await videoRepo.homeCon.value.getVideos();
        }
        videoRepo.homeCon.notifyListeners();
        Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);

        return Future.value(true);
      },
      child: ValueListenableBuilder(
          valueListenable: myProfile,
          builder: (context, UserProfileModel userProfile, _) {
            return ModalProgressHUD(
              inAsyncCall: _con.showLoader,
              progressIndicator: Helper.showLoaderSpinner(Colors.white),
              child: SafeArea(
                child: Scaffold(
                  endDrawer: Container(
                    width: 250,
                    child: Drawer(
//                      elevation: 1,
                      // Add a ListView to the drawer. This ensures the user can scroll
                      // through the options in the drawer if there isn't enough vertical
                      // space to fit everything.
                      child: Stack(
                        children: [
                          Container(
                            color: Color(0XFF15161a).withOpacity(0.9),
                            child: ListView(
                              // Important: Remove any padding from the ListView.
                              padding: EdgeInsets.zero,
                              children: <Widget>[
                                Container(
                                  height: 60.0,
                                  child: DrawerHeader(
                                    child: Text(
                                      'Settings',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0XFF15161a).withOpacity(0.1),
                                      border: Border(
                                        bottom: BorderSide(
                                          width: 0.5,
                                          color: Colors.white60,
                                        ),
                                      ),
                                    ),
                                    margin: EdgeInsets.all(0.0),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 20,
                                    ),
                                  ),
                                ),
                                ListTile(
                                  // contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditProfileView(),
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.verified_user,
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    'Verification',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VerifyProfileView(),
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.lock,
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    'Change Password',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChangePasswordView(),
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.logout,
                                    color: Colors.white,
                                    textDirection: TextDirection.rtl,
                                  ),
                                  title: Text(
                                    'Logout',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    logout().whenComplete(() async {
                                      videoRepo.homeCon.value.showFollowingPage.value = false;
                                      videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                                      videoRepo.homeCon.value.getVideos();
                                      Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            child: Container(
                              width: 250,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "App Version  ${userProfile.appVersion}",
                                    style: TextStyle(
                                      color: Colors.white60,
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
                  key: _con.userScaffoldKey,
                  // resizeToAvoidBottomPadding: false,
                  resizeToAvoidBottomInset: false,
                  body: RefreshIndicator(
                    onRefresh: _con.refreshMyProfile,
                    color: Colors.white,
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
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
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
                                    width: MediaQuery.of(context).size.width - 88,
                                  ),
                                  InkWell(
                                      child: Icon(Icons.settings, size: 22, color: Colors.white),
                                      onTap: () {
                                        _con.userScaffoldKey.currentState.openEndDrawer();
                                      }),
                                  // PopupMenuButton<String>(
                                  //   icon: Icon(Icons.settings, size: 22, color: Colors.white),
                                  //   onSelected: onSelectedMenu,
                                  //   color: Color(0xff444549),
                                  //   itemBuilder: (BuildContext context) {
                                  //     return SettingMenu.choices.map((String choice) {
                                  //       return PopupMenuItem(
                                  //         height: 30,
                                  //         value: choice,
                                  //         child: Text(
                                  //           choice,
                                  //           style: TextStyle(
                                  //             color: Colors.white,
                                  //             fontFamily: 'RockWellStd',
                                  //             fontSize: 15,
                                  //           ),
                                  //         ),
                                  //       );
                                  //     }).toList();
                                  //   },
                                  // )
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
                                  userProfile != null
                                      ? profilePhoto(userProfile)
                                      : SizedBox(
                                          height: 0,
                                        ),
                                  userProfile != null
                                      ? profilePersonInfo(userProfile)
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
                                          userProfile.totalVideosLike != null ? userProfile.totalVideosLike : '',
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
                                        child: GestureDetector(
                                          onTap: () {
                                            if (userProfile.totalFollowings != '0') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => FollowingsView(type: 0),
                                                ),
                                              );
                                            }
                                          },
                                          child: Text(
                                            userProfile.totalFollowings != null ? userProfile.totalFollowings : '',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (userProfile.totalFollowings != '0') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => FollowingsView(type: 0),
                                              ),
                                            );
                                          }
                                        },
                                        child: Text(
                                          "FOLLOWING",
                                          style: TextStyle(color: Colors.white, fontSize: 11),
                                        ),
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
                                        child: GestureDetector(
                                          onTap: () {
                                            if (userProfile.totalFollowers != '0') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => FollowingsView(type: 1),
                                                ),
                                              );
                                            }
                                          },
                                          child: Text(
                                            userProfile.totalFollowers != null ? userProfile.totalFollowers : '',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (userProfile.totalFollowers != '0') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => FollowingsView(type: 1),
                                              ),
                                            );
                                          }
                                        },
                                        child: Text(
                                          "FOLLOWERS",
                                          style: TextStyle(color: Colors.white, fontSize: 11),
                                        ),
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
                              child: tabs(userProfile),
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

class SettingMenu {
  static const String LOGOUT = 'Logout';
  static const String EDIT_PROFILE = 'Edit Profile';
  static const String VERIFY = 'Verification';
  static const List<String> choices = <String>[EDIT_PROFILE, VERIFY, LOGOUT];
}
