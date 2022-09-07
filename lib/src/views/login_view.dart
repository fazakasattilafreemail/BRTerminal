import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/user_controller.dart';
import '../helpers/helper.dart';
import '../models/login_screen_model.dart';
import '../repositories/login_page_repository .dart' as loginRepo;
import '../repositories/video_repository.dart' as videoRepo;
import '../views/password_login_view.dart';
import '../views/sign_up_view.dart';

class LoginPageView extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  final int userId;
  LoginPageView({Key key, this.userId, this.parentScaffoldKey}) : super(key: key);

  @override
  _LoginPageViewState createState() => _LoginPageViewState();
}

class _LoginPageViewState extends StateMVC<LoginPageView> {
  UserController _con;
  _LoginPageViewState() : super(UserController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.getLoginPageData();
    if (widget.userId != null && widget.userId > 0) {
      print(widget.userId);
      _con.userIdValue.value = widget.userId;
      _con.userIdValue.notifyListeners();
    }
    _con.getUuId();
    super.initState();
  }

  void dispose() {
    _con.showLoaderDialog(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        videoRepo.homeCon.value.showFollowingPage.value = false;
        videoRepo.homeCon.value.showFollowingPage.notifyListeners();
        print('HHHHHHHHHHHHHHHHHHHHHHooolgetvideos13');
        videoRepo.homeCon.value.getVideos();
        Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
        return Future.value(true);
      },
      child: ValueListenableBuilder(
          valueListenable: loginRepo.LoginPageData,
          builder: (context, LoginScreenData data, _) {
            return data != null
                ? ModalProgressHUD(
                    inAsyncCall: _con.showLoader,
                    progressIndicator: Helper.showLoaderSpinner(Colors.white),
                    child: SafeArea(
                      child: Scaffold(
                        key: _con.userScaffoldKey,
                        backgroundColor: Colors.black,
                        body: Container(
                          height: MediaQuery.of(context).size.height,
                          color: Color(0XFF15161a),
                          child: Stack(
                            children: [
                              Container(
                                child: Center(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: <Widget>[
                                        SizedBox(
                                          height: 40,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width / 1.5,
                                          child: data.logo != '' && data.logo != null
                                              ? CachedNetworkImage(
                                                  imageUrl: data.logo,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) => Center(
                                                    child: Helper.showLoaderSpinner(Colors.white),
                                                  ),
                                                  errorWidget: (context, url, error) => Center(
                                                    child: Image.asset(
                                                      'assets/images/login-logo.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                )
                                              : Image.asset(
                                                  'assets/images/login-logo.png',
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Center(
                                          child: Text(
                                            data.title != null ? data.title : "Sign Up For ${GlobalConfiguration().get('app_name')}",
                                            style: TextStyle(
                                              color: Color(0xfffcb37b),
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'QueenCamelot',
                                              fontSize: 25,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                                            child: Text(
                                              data.description != null
                                                  ? data.description
                                                  : "Create a profile, follow other creators build your fan following by creating your own videos.",
                                              style: TextStyle(
                                                height: 1.55,
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton(

                                              child: Container(
                                                height: 40,
                                                width: MediaQuery.of(context).size.width * 0.4,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xff7350c7),
                                                      Color(0xffec4a63),
                                                    ],
                                                    begin: FractionalOffset(0.0, 1),
                                                    end: FractionalOffset(0.4, 4),
                                                    stops: [0.1, 0.7],
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Create an account',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                      fontFamily: 'RockWellStd',
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => SignUpView(),
                                                  ),
                                                );
                                              },
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10.0,
                                              ),
                                              child: Container(
                                                color: Colors.white,
                                                width: 1,
                                                height: 40,
                                              ),
                                            ),
                                            ElevatedButton(
                                              child: Container(
                                                height: 40,
                                                width: MediaQuery.of(context).size.width * 0.4,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xff7350c7),
                                                      Color(0xffec4a63),
                                                    ],
                                                    begin: FractionalOffset(0.0, 1),
                                                    end: FractionalOffset(0.4, 4),
                                                    stops: [0.1, 0.7],
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Login',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                      fontFamily: 'RockWellStd',
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => PasswordLoginView(),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        (!Platform.isAndroid && data.appleLogin != null && data.appleLogin == true)
                                            ? SizedBox(
                                                height: 30,
                                              )
                                            : Container(),
                                        (!Platform.isAndroid && data.appleLogin != null && data.appleLogin == true)
                                            ? Center(
                                                child: GestureDetector(
                                                  child: Image.asset(
                                                    'assets/images/signin-with-apple.png',
                                                    fit: BoxFit.fill,
                                                    width: 205,
                                                    height: 43,
                                                  ),
                                                  onTap: () async {
                                                    _con.signInWithApple();
                                                  },
                                                ),
                                              )
                                            : Container(),
                                        data.googleLogin != null && data.googleLogin == true
                                            ? SizedBox(
                                                height: 30,
                                              )
                                            : Container(),
                                        data.googleLogin != null && data.googleLogin == true
                                            ? Center(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    _con.loginWithGoogle();
                                                  },
                                                  child: Image.asset(
                                                    'assets/images/google-b.png',
                                                    fit: BoxFit.fill,
                                                    width: 200,
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                        data.fbLogin != null && data.fbLogin == true
                                            ? SizedBox(
                                                height: 30,
                                              )
                                            : Container(),
                                        data.fbLogin != null && data.fbLogin == true
                                            ? Center(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    _con.loginWithFB();
                                                  },
                                                  child: Image.asset(
                                                    'assets/images/facebook-b.png',
                                                    fit: BoxFit.fill,
                                                    width: 200,
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                        SizedBox(
                                          height: 30,
                                        ),
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                                            child: Text(
                                              data.privacyPolicy != null
                                                  ? data.privacyPolicy
                                                  : "By continuing you agree to ${GlobalConfiguration().get('app_name')} terms of use and confirm that you have read our privacy policy.",
                                              style: TextStyle(
                                                height: 1.55,
                                                color: Colors.white70,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 50,
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: <Widget>[
                                            GestureDetector(
                                              onTap: () {
                                                _con.launchURL("${GlobalConfiguration().get('base_url')}terms");
                                              },
                                              child: Text(
                                                "Terms of use",
                                                style: TextStyle(color: Colors.white70, fontSize: 17),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 15,
                                            ),
                                            Container(
                                              width: 1,
                                              height: 17,
                                              color: Colors.white70,
                                            ),
                                            SizedBox(
                                              width: 15,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                _con.launchURL("${GlobalConfiguration().get('base_url')}privacy-policy");
                                              },
                                              child: Text(
                                                "Privacy Policy",
                                                style: TextStyle(color: Colors.white70, fontSize: 17),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 30,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 5,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: InkWell(
                                      onTap: () async {
                                        videoRepo.homeCon.value.showFollowingPage.value = false;
                                        videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                                        videoRepo.homeCon.value.getVideos();
                                        Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                                      },
                                      child: Text(
                                        "Skip",
                                        style: TextStyle(color: Colors.white, fontSize: 20),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(
                    color: Colors.black,
                    child: showLoaderSpinner(),
                  );
          }),
    );
  }

  showLoaderSpinner() {
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
}
