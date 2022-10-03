import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../controllers/user_controller.dart';
import '../helpers/app_config.dart';
import '../models/gender.dart';
import '../repositories/user_repository.dart' as userRepo;
import '../views/showCupertinoDatePicker.dart';

var minDate = new DateTime.now().subtract(Duration(days: 29200));
var yearBefore = new DateTime.now().subtract(Duration(days: 4746));
var formatter = new DateFormat('yyyy-MM-dd 00:00:00.000');
var formatterYear = new DateFormat('yyyy');
var formatterDate = new DateFormat('dd MMM yyyy');

String minYear = formatterYear.format(minDate);
String maxYear = formatterYear.format(yearBefore);
String initDatetime = formatterDate.format(yearBefore);

class CompleteProfileView extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  final String loginType;

  CompleteProfileView({@required this.loginType, this.parentScaffoldKey}) : assert(loginType != null);
  @override
  _CompleteProfileViewState createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends StateMVC<CompleteProfileView> with SingleTickerProviderStateMixin {
  UserController _con;
  _CompleteProfileViewState() : super(UserController()) {
    _con = controller;
  }
  AnimationController animationController;

  @override
  void initState() {
    // TODO: implement initState
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    if (userRepo.socialUserProfile.value != null) {
      print("userRepo.socialUserProfile.value.userDP");
      print(userRepo.socialUserProfile.value.userDP);
      setState(() {
        _con.showLoader = false;
        _con.completeProfile = userRepo.socialUserProfile.value;
        ;
        _con.loginType = widget.loginType;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      // resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        backgroundColor: Colors.white70,
        elevation: 1.0,
        /*leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.grey,
            size: 25,
          ),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/my-profile'),
        ),*/
        title: Center(
          child: Text(
            'Complete Profile',
            style: TextStyle(color: Colors.black54),
          ),
        ),
        /*actions: [
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Image.asset(
                "assets/icons/new/settings.png",
              ),
            ),
            onTap: () {},
          ),
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Image.asset(
                "assets/icons/new/download.png",
              ),
            ),
            onTap: () {},
          ),
        ],*/
      ),
      key: _con.completeProfileScaffoldKey,
      backgroundColor: Colors.white,
      body: EditProfilePanel(),
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

  Widget EditProfilePanel() {
    return ModalProgressHUD(
      progressIndicator: showLoaderSpinner(),
      inAsyncCall: _con.showLoader,
      child: SingleChildScrollView(
        controller: _con.scrollController,
        child: Stack(
          children: [
            Column(
              children: [
                SlidingUpPanel(
                  controller: _con.pc,
                  isDraggable: false,
                  backdropEnabled: true,
                  panelSnapping: false,
                  color: Color(0xffffffff),
                  maxHeight: 95.0,
                  minHeight: 0,
                  onPanelClosed: () {
                    _con.scrollController.animateTo(
                      0,
                      curve: Curves.easeOut,
                      duration: const Duration(milliseconds: 1000),
                    );
                  },
                  panel: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                _con.getImageOption(true);
                                _con.pc.close();
                              },
                              child: Column(
                                children: <Widget>[
                                  Image.asset(
                                    'assets/icons/camera.png',
                                    width: 50,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
                                    child: Text(
                                      "Camera",
                                      style: TextStyle(color: Colors.black, fontSize: 14),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _con.getImageOption(false);
                                _con.pc.close();
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 15.0),
                                child: Column(
                                  children: <Widget>[
                                    Image.asset(
                                      'assets/icons/gallery.png',
                                      width: 50,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
                                      child: Text(
                                        "Gallery",
                                        style: TextStyle(color: Colors.black, fontSize: 14),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
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
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white,
                                            ),
                                          ),
                                          centerTitle: true,
                                        ),
                                      ),
                                      backgroundColor: Colors.black,
                                      body: Center(
                                        child: PhotoView(
                                          enableRotation: true,
                                          imageProvider: userRepo.socialUserProfile.value.userDP != ''
                                              ? CachedNetworkImageProvider(userRepo.socialUserProfile.value.userDP)
                                              : AssetImage("assets/images/splash.png"),
                                        ),
                                      ));
                                }));
                                _con.pc.close();
                              },
                              child: Column(
                                children: <Widget>[
                                  Image.asset(
                                    'assets/icons/view.png',
                                    width: 50,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
                                    child: Text(
                                      "View Picture",
                                      style: TextStyle(color: Colors.black, fontSize: 14),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  body: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: Container(
                      color: Colors.white,
                      /*decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                  ),*/
                      height: MediaQuery.of(context).size.height,
//        color: Colors.white,
                      child: Form(
                        key: _con.completeProfileFormKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: App(context).appHeight(10),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.2),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
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
                                                imageProvider: userRepo.socialUserProfile.value.userDP != ''
                                                    ? _con.selectedDp.path != null
                                                        ? Image.file(
                                                            _con.selectedDp,
                                                          )
                                                        : CachedNetworkImageProvider(
                                                            userRepo.socialUserProfile.value.userDP,
                                                            // placeholder: (context, url) => Helper.showLoaderSpinner(Colors.white),
                                                            // fit: BoxFit.fitWidth,
                                                            // alignment: Alignment.center,
                                                          )
                                                    : AssetImage("assets/images/splash.png"),
                                              ),
                                            ));
                                      },
                                    ),
                                  );
                                },
                                child: Stack(
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _con.scrollController.animateTo(
                                            70,
                                            curve: Curves.easeOut,
                                            duration: const Duration(milliseconds: 1000),
                                          );
                                          _con.pc.open();
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          top: 20.0,
                                        ),
                                        child: Container(
                                          height: App(context).appHeight(20),
                                          decoration: new BoxDecoration(
                                            borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
                                            border: new Border.all(
                                              color: Colors.white,
                                              width: 5.0,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Container(
                                              height: App(context).appHeight(20),
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey,
                                                    blurRadius: 5.0,
                                                  ),
                                                ],
                                                color: Color(0xff2e2f34),
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                  image:
                                                      userRepo.socialUserProfile.value.userDP != '' && userRepo.socialUserProfile.value.userDP != null
                                                          ? _con.selectedDp != null
                                                              ? FileImage(
                                                                  _con.selectedDp,
                                                                )
                                                              : CachedNetworkImageProvider(
                                                                  userRepo.socialUserProfile.value.userDP,
                                                                  // placeholder: (context, url) => Helper.showLoaderSpinner(Colors.white),
                                                                  // fit: BoxFit.fitWidth,
                                                                  // alignment: Alignment.center,
                                                                )
                                                          : AssetImage("assets/images/splash.png"),
                                                  fit: BoxFit.none,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                        bottom: 10,
                                        right: 10,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _con.scrollController.animateTo(
                                                70,
                                                curve: Curves.easeOut,
                                                duration: const Duration(milliseconds: 1000),
                                              );
                                              _con.pc.open();
                                            });
                                          },
                                          child: Icon(
                                            Icons.camera_alt,
                                            color: Colors.black,
                                            size: 35.0,
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: SizedBox(
                                height: 1,
                                child: Container(
                                  color: Colors.white30,
                                ),
                              ),
                            ),
                            SingleChildScrollView(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * .1, vertical: 0),
                                child: Column(
                                  children: <Widget>[
                                    TextFormField(
                                      maxLines: 1,
                                      keyboardType: TextInputType.multiline,
                                      controller: _con.profileUsernameController,
                                      style: TextStyle(
                                        fontFamily: 'RockWellStd',
                                        fontSize: 18.0,
                                        color: Colors.grey,
                                      ),
                                      validator: (value) {
                                        return _con.validateField(value, "Username");
                                      },
                                      onSaved: (String val) {
                                        _con.userName = val;
                                      },
                                      onChanged: (String val) {
                                        _con.userName = val;
                                      },
                                      decoration: InputDecoration(
                                        errorStyle: TextStyle(
                                          color: Colors.red,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          wordSpacing: 2.0,
                                        ),
//                    contentPadding: EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
                                        border: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                        ),
                                        errorBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.red,
                                            width: 1.0,
                                          ),
                                        ),
                                        hintText: "Enter Username",
                                        hintStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      width: App(context).appWidth(100),
                                      padding: EdgeInsets.only(bottom: 10),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            width: 0.5,
                                            color: Colors.lightBlue.shade900,
                                          ),
                                        ),
                                      ),
                                      child: SizedBox(
                                        // height: 30.0,
                                        // width: MediaQuery.of(context).size.width - 150,
                                        child: Container(
                                          child: GestureDetector(
                                            onTap: () {
                                              var currentDOB = yearBefore;
                                              showCupertinoDatePicker(context,
                                                  mode: CupertinoDatePickerMode.date,
                                                  initialDateTime: currentDOB,
                                                  leftHanded: false,
                                                  minimumYear: int.parse(minYear),
                                                  maximumYear: int.parse(maxYear), onDateTimeChanged: (DateTime date) {
                                                DateTime result;
                                                if (date.year > 0) {
                                                  result = DateTime(
                                                    date.year,
                                                    date.month,
                                                    date.day,
                                                  );

                                                  setState(() {
                                                    _con.profileDOB = result;
                                                    _con.profileDOBString = formatterDate.format(result);
                                                  });

                                                  print("_con.profileDOB");
                                                  print(_con.profileDOB);
                                                } else {
                                                  // The user has hit the cancel button.
                                                  result = DateTime(
                                                    currentDOB.year,
                                                    currentDOB.month,
                                                  );
                                                }
                                                // _con.onChanged(result);
                                              });
                                            },
                                            child: (_con.profileDOB != null)
                                                ? Text(
                                                    formatterDate.format(_con.profileDOB),
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w300,
                                                    ),
                                                  )
                                                : Text(
                                                    "Select Date of Birth",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w300,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    TextFormField(
                                      maxLines: 1,
                                      keyboardType: TextInputType.multiline,
                                      controller: _con.passwordController,
                                      style: TextStyle(
                                        fontFamily: 'RockWellStd',
                                        fontSize: 18.0,
                                        color: Colors.grey,
                                      ),
                                      validator: (value) {
                                        return _con.validateField(value, "Password");
                                      },
                                      obscureText: true,
                                      onSaved: (String val) {
                                        _con.password = val;
                                      },
                                      onChanged: (String val) {
                                        _con.password = val;
                                      },
                                      decoration: InputDecoration(
                                        errorStyle: TextStyle(
                                          color: Colors.red,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          wordSpacing: 2.0,
                                        ),
//                    contentPadding: EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
                                        border: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                        ),
                                        errorBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.red,
                                            width: 1.0,
                                          ),
                                        ),
                                        hintText: "Enter Password",
                                        hintStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    TextFormField(
                                      obscureText: true,
                                      maxLines: 1,
                                      keyboardType: TextInputType.multiline,
                                      controller: _con.confirmPasswordController,
                                      style: TextStyle(
                                        fontFamily: 'RockWellStd',
                                        fontSize: 18.0,
                                        color: Colors.grey,
                                      ),
                                      validator: (value) {
                                        return _con.validateField(value, "Confirm Password");
                                      },
                                      onSaved: (String val) {
                                        _con.confirmPassword = val;
                                      },
                                      onChanged: (String val) {
                                        _con.confirmPassword = val;
                                      },
                                      decoration: InputDecoration(
                                        errorStyle: TextStyle(
                                          color: Colors.red,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          wordSpacing: 2.0,
                                        ),
                                        border: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                        ),
                                        errorBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.red,
                                            width: 1.0,
                                          ),
                                        ),
                                        hintText: "Enter Confirm Password",
                                        hintStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            width: 0.5,
                                            color: Colors.lightBlue.shade900,
                                          ),
                                        ),
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: DropdownSearch<Gender>(
                                          autoValidateMode: AutovalidateMode.onUserInteraction,
                                          validator: (value) {
                                            if (value != null) {
                                              return _con.validateField(value.value, "Gender");
                                            } else {
                                              return "Gender is Required";
                                            }
                                          },
                                          items: _con.gender,
                                          // onFind: (String filter) => getData(filter),
                                          itemAsString: (Gender u) => u.name,
                                          onChanged: (Gender data) {
                                            setState(() {
                                              _con.selectedGender = data.value;
                                            });
                                          },
                                        ),
                                        // DropdownButtonHideUnderline(
                                        //   child: new DropdownButton<Gender>(
                                        //     iconEnabledColor: Colors.white,
                                        //     style: new TextStyle(
                                        //       color: Colors.white,
                                        //       fontSize: 15.0,
                                        //     ),
                                        //     // value: _con.selectedGender,
                                        //     onChanged: (Gender newValue) {
                                        //       // usersProfileData.value.gender = newValue.value;
                                        //       setState(() {
                                        //         _con.selectedGender = newValue;
                                        //       });
                                        //     },
                                        //     items: _con.gender.map((Gender user) {
                                        //       return new DropdownMenuItem<Gender>(
                                        //         value: user,
                                        //         child: new Text(
                                        //           user.name,
                                        //           style: TextStyle(
                                        //             color: Colors.black,
                                        //             fontSize: 18,
                                        //             fontWeight: FontWeight.w300,
                                        //           ),
                                        //         ),
                                        //       );
                                        //     }).toList(),
                                        //   ),
                                        // ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              FocusManager.instance.primaryFocus.unfocus();

                                              _con.registerSocial();
                                            },
                                            child: Container(
                                              height: 45,
                                              width: 200,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(30.0),
                                                gradient: Gradients.blush,
                                              ),
                                              child: Center(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                      "Register",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.normal,
                                                        fontSize: 20,
                                                        fontFamily: 'RockWellStd',
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 8.0,
                                                      ),
                                                      child: Icon(
                                                        Icons.send,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            AnimatedIcon(
              color: Colors.black,
              icon: AnimatedIcons.add_event,
              progress: animationController,
              semanticLabel: 'Show menu',
            ),
          ],
        ),
      ),
    );
  }
}
