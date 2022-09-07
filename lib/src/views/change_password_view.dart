import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/user_profile_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../models/edit_profile_model.dart';
import '../repositories/profile_repository.dart';

var minDate = new DateTime.now().subtract(Duration(days: 29200));
var yearbefore = new DateTime.now().subtract(Duration(days: 4746));
var formatter = new DateFormat('yyyy-MM-dd 00:00:00.000');
var formatterYear = new DateFormat('yyyy');
var formatterDate = new DateFormat('dd MMM yyyy');

String minYear = formatterYear.format(minDate);
String maxYear = formatterYear.format(yearbefore);
String initDatetime = formatter.format(yearbefore);

class ChangePasswordView extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  ChangePasswordView({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _ChangePasswordViewState createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends StateMVC<ChangePasswordView> {
  UserProfileController _con;
  int page = 1;
  _ChangePasswordViewState() : super(UserProfileController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentPasswordField = TextFormField(
      textAlign: TextAlign.right,
      style: TextStyle(
        color: Colors.black,
        fontSize: 14.0,
      ),
      obscureText: true,
      keyboardType: TextInputType.text,
      controller: _con.currentPasswordController,
      onSaved: (String val) {
        _con.currentPassword = val;
      },
      onChanged: (String val) {
        _con.currentPassword = val;
      },
      decoration: new InputDecoration(
        errorStyle: TextStyle(
          color: Color(0xFF210ed5),
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          wordSpacing: 2.0,
        ),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hintText: "Current Password",
        hintStyle: TextStyle(color: Colors.black54),
      ),
    );
    final newPasswordField = TextFormField(
      textAlign: TextAlign.right,
      style: TextStyle(
        color: Colors.black,
        fontSize: 14.0,
      ),
      obscureText: true,
      keyboardType: TextInputType.text,
      controller: _con.newPasswordController,
      onSaved: (String val) {
        _con.newPassword = val;
      },
      onChanged: (String val) {
        _con.newPassword = val;
      },
      decoration: new InputDecoration(
        errorStyle: TextStyle(
          color: Color(0xFF210ed5),
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          wordSpacing: 2.0,
        ),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hintText: "New Password",
        hintStyle: TextStyle(color: Colors.black54),
      ),
    );
    final confirmPasswordField = TextFormField(
      textAlign: TextAlign.right,
      style: TextStyle(
        color: Colors.black,
        fontSize: 14.0,
      ),
      obscureText: true,
      keyboardType: TextInputType.text,
      controller: _con.confirmPasswordController,
      onSaved: (String val) {
        _con.confirmPassword = val;
      },
      onChanged: (String val) {
        _con.confirmPassword = val;
      },
      decoration: new InputDecoration(
        errorStyle: TextStyle(
          color: Color(0xFF210ed5),
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          wordSpacing: 2.0,
        ),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hintText: "Confirm Password",
        hintStyle: TextStyle(color: Colors.black54),
      ),
    );

    return ValueListenableBuilder(
        valueListenable: usersProfileData,
        builder: (context, EditProfileModel _userProfile, _) {
          return SafeArea(
            child: Scaffold(
              key: _con.scaffoldKey,
              resizeToAvoidBottomInset: false,
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(45.0),
                child: AppBar(
                  iconTheme: IconThemeData(
                    color: Colors.black, //change your color here
                  ),
                  backgroundColor: Colors.white60,
                  title: Text(
                    "Change Password",
                    style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400, color: Colors.black),
                  ),
                  centerTitle: true,
                ),
              ),
              body: ModalProgressHUD(
                inAsyncCall: _con.showLoader,
                progressIndicator: Helper.showLoaderSpinner(Colors.black),
                child: Center(
                    child: Container(
                  color: Color(0xffffffff),
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                        child: Container(
                          child: Form(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            key: _con.formKey,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                  child: Container(
                                    child: Row(
                                      children: <Widget>[
                                        SizedBox(
                                          height: 30.0,
                                          width: 200,
                                          child: Container(
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(
                                                2,
                                                5,
                                                0,
                                                0,
                                              ),
                                              child: Text(
                                                "Current Password",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: SizedBox(
                                            height: 30.0,
                                            width: MediaQuery.of(context).size.width - 250,
                                            child: Container(
                                              child: Padding(
                                                padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                                child: currentPasswordField,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(height: 0.3, width: MediaQuery.of(context).size.width, color: Colors.grey),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                  child: Container(
                                    child: Row(
                                      children: <Widget>[
                                        SizedBox(
                                          height: 30.0,
                                          width: 200,
                                          child: Container(
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                              child: Text(
                                                "New Password",
                                                style: TextStyle(fontSize: 14, color: Colors.black),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: SizedBox(
                                            height: 30.0,
                                            width: MediaQuery.of(context).size.width - 250,
                                            child: Container(
                                              child: Padding(
                                                padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                                child: newPasswordField,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(height: 0.3, width: MediaQuery.of(context).size.width, color: Colors.grey),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                  child: Container(
                                    child: Row(
                                      children: <Widget>[
                                        SizedBox(
                                          height: 30.0,
                                          width: 200,
                                          child: Container(
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                              child: Text(
                                                "Confirm Password",
                                                style: TextStyle(fontSize: 14, color: Colors.black),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: SizedBox(
                                            height: 30.0,
                                            width: MediaQuery.of(context).size.width - 250,
                                            child: Container(
                                              child: Padding(
                                                padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                                child: confirmPasswordField,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _con.changePassword();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 30.0),
                                    child: Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          gradient: Gradients.blush,
                                          /*boxShadow: [
                                                BoxShadow(
                                                  color: Colors.lightGreen,
                                                  spreadRadius: 3,
                                                ),
                                              ],*/
                                        ),
                                        height: config.App(context).appWidth(10),
                                        width: config.App(context).appWidth(80),
                                        child: Center(
                                          child: Text(
                                            "Change Password",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                            ),
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
                      ),
                    ],
                  ),
                )),
              ),
            ),
          );
        });
  }
}
