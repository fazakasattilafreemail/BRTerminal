import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/user_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../models/edit_profile_model.dart';
import '../repositories/profile_repository.dart';

class ForgotPasswordView extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  ForgotPasswordView({Key key, this.parentScaffoldKey}) : super(key: key);
  @override
  _ForgotPasswordViewState createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends StateMVC<ForgotPasswordView> {
  UserController _con;
  int page = 1;
  _ForgotPasswordViewState() : super(UserController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final emailField = TextFormField(
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.black,
        fontSize: 14.0,
      ),
      keyboardType: TextInputType.text,
      controller: _con.emailController,
      onSaved: (String val) {
        _con.email = val;
      },
      onChanged: (String val) {
        _con.email = val;
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
        hintText: "Enter Registered Email",
        hintStyle: TextStyle(color: Colors.black54),
      ),
    );

    return ValueListenableBuilder(
        valueListenable: usersProfileData,
        builder: (context, EditProfileModel _userProfile, _) {
          return SafeArea(
            child: Scaffold(
              key: _con.forgotPasswordScaffoldKey,
              // resizeToAvoidBottomPadding: false,
              resizeToAvoidBottomInset: false,
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(45.0),
                child: AppBar(
                  iconTheme: IconThemeData(
                    color: Colors.black, //change your color here
                  ),
                  backgroundColor: Colors.white60,
                  title: Text(
                    "Forgot Password",
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                        child: Container(
                          child: Form(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            key: _con.formKey,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                    child: emailField,
                                  ),
                                ),
                                Container(
                                  height: 0.3,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.grey,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _con.sendPasswordResetOTP();
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
                                            "Send OTP",
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
