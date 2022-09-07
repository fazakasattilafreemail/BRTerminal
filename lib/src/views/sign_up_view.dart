import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/user_controller.dart';
import '../views/verify_otp_screen.dart';

class SignUpView extends StatefulWidget {
  @override
  _SignUpViewState createState() => _SignUpViewState();
}

class _SignUpViewState extends StateMVC<SignUpView> {
  UserController _con;
  _SignUpViewState() : super(UserController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _con.showLoader,
      child: SafeArea(
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Color(0XFF15161a),
            leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.white60,
              ),
            ),
          ),
          key: _con.userScaffoldKey,
          body: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.only(left: 15.0, right: 15.0),
              color: Color(0XFF15161a),
              child: Center(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.035,
                      ),
                      Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'QueenCamelot',
                          fontSize: 30,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.024),
                      Container(
                        padding: EdgeInsets.only(
                          left: 15,
                          right: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0XFF2e2f34),
                          borderRadius: BorderRadius.all(
                            Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                            Text(
                              "Create An Account",
                              style: TextStyle(
                                color: Color(0xfffcb37b),
                                fontWeight: FontWeight.w400,
                                fontFamily: 'QueenCamelot',
                                fontSize: 24,
                              ),
                            ),
                            Container(
                              color: Colors.grey[400],
                              height: .4,
                              width: MediaQuery.of(context).size.width * .6,
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.011),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Form(
                                key: _con.registerFormKey,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      controller: _con.fullNameController,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'RockWellStd',
                                        fontSize: 14.0,
                                        color: Colors.white,
                                      ),
                                      keyboardType: TextInputType.text,
                                      onChanged: (String val) {
                                        _con.fullName = val;
                                      },
                                      decoration: InputDecoration(
                                        errorStyle: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.normal,
                                          wordSpacing: 2.0,
                                        ),
                                        border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.white,
                                            width: 1.0,
                                          ),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.white,
                                            width: 1.0,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.white,
                                            width: 1.0,
                                          ),
                                        ),
                                        errorBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.red,
                                            width: 1.0,
                                          ),
                                        ),
                                        prefixIcon: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Icon(
                                              Icons.perm_identity,
                                              color: Colors.white,
                                              size: 20.0,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10.0),
                                              child: Container(
                                                color: Colors.white,
                                                width: 1,
                                                height: 25,
                                              ),
                                            ),
                                          ],
                                        ),
                                        contentPadding: EdgeInsets.only(top: 12),
                                        hintText: "Enter Your Full Name",
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      validator: (value) {
                                        return _con.validateField(value, "Full Name");
                                      },
                                    ),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.015,
                                    ),
                                    TextFormField(
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      controller: _con.emailController,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'RockWellStd',
                                        fontSize: 14.0,
                                        color: Colors.white,
                                      ),
                                      validator: _con.validateEmail,
                                      keyboardType: TextInputType.text,
                                      onChanged: (String val) {
                                        _con.email = val;
                                      },
                                      decoration: InputDecoration(
                                        errorStyle: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.normal,
                                          wordSpacing: 2.0,
                                        ),
                                        border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.white,
                                            width: 1.0,
                                          ),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.white,
                                            width: 1.0,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.white,
                                            width: 1.0,
                                          ),
                                        ),
                                        errorBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.red,
                                            width: 1.0,
                                          ),
                                        ),
                                        prefixIcon: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Icon(
                                              Icons.email_outlined,
                                              color: Colors.white,
                                              size: 20.0,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10.0),
                                              child: Container(
                                                color: Colors.white,
                                                width: 1,
                                                height: 25,
                                              ),
                                            ),
                                          ],
                                        ),
                                        contentPadding: EdgeInsets.only(top: 12),
                                        hintText: "Enter Your Email",
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.015,
                                    ),
                                    TextFormField(
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      controller: _con.userNameController,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'RockWellStd',
                                        fontSize: 14.0,
                                        color: Colors.white,
                                      ),
                                      validator: (value) {
                                        return _con.validateField(value, "Username");
                                      },
                                      keyboardType: TextInputType.text,
                                      onSaved: (String val) {
                                        _con.userName = val;
                                      },
                                      decoration: InputDecoration(
                                        errorStyle: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.normal,
                                          wordSpacing: 2.0,
                                        ),
                                        border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.white,
                                            width: 1.0,
                                          ),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.white,
                                            width: 1.0,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.white,
                                            width: 1.0,
                                          ),
                                        ),
                                        errorBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.red,
                                            width: 1.0,
                                          ),
                                        ),
                                        prefixIcon: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Icon(
                                              Icons.alternate_email_rounded,
                                              color: Colors.white,
                                              size: 20.0,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10.0),
                                              child: Container(
                                                color: Colors.white,
                                                width: 1,
                                                height: 25,
                                              ),
                                            ),
                                          ],
                                        ),
                                        contentPadding: EdgeInsets.only(top: 12),
                                        hintText: "Enter Username",
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.015,
                                    ),
                                    TextFormField(
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      controller: _con.passwordController,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'RockWellStd',
                                        fontSize: 14.0,
                                        color: Colors.white,
                                      ),
                                      validator: (value) {
                                        return _con.validateField(value, "Password");
                                      },
                                      keyboardType: TextInputType.text,
                                      obscureText: true,
                                      onChanged: (String val) {
                                        _con.password = val;
                                      },
                                      decoration: InputDecoration(
                                        errorStyle: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.normal,
                                          wordSpacing: 2.0,
                                        ),
                                        border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.white,
                                            width: 1.0,
                                          ),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.white,
                                            width: 1.0,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.white,
                                            width: 1.0,
                                          ),
                                        ),
                                        errorBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.red,
                                            width: 1.0,
                                          ),
                                        ),
                                        prefixIcon: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Icon(
                                              Icons.lock_outline_rounded,
                                              color: Colors.white,
                                              size: 20.0,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10.0),
                                              child: Container(
                                                color: Colors.white,
                                                width: 1,
                                                height: 25,
                                              ),
                                            ),
                                          ],
                                        ),
                                        contentPadding: EdgeInsets.only(top: 12),
                                        hintText: "Enter Password",
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.015,
                                    ),
                                    TextFormField(
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      controller: _con.confirmPasswordController,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'RockWellStd',
                                        fontSize: 14.0,
                                        color: Colors.white,
                                      ),
                                      validator: (String value) {
                                        if (value.isEmpty) {
                                          return 'Please re-enter password';
                                        }
                                        print(_con.passwordController.text);
                                        print(_con.confirmPasswordController.text);
                                        if (_con.passwordController.text != _con.confirmPasswordController.text) {
                                          return "Password does not match";
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.text,
                                      onSaved: (String val) {
                                        _con.confirmPassword = val;
                                      },
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        errorStyle: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.normal,
                                          wordSpacing: 2.0,
                                        ),
                                        border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.white,
                                            width: 1.0,
                                          ),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.white,
                                            width: 1.0,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.white,
                                            width: 1.0,
                                          ),
                                        ),
                                        errorBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.red,
                                            width: 1.0,
                                          ),
                                        ),
                                        prefixIcon: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Icon(
                                              Icons.lock_outline_rounded,
                                              color: Colors.white,
                                              size: 20.0,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10.0),
                                              child: Container(
                                                color: Colors.white,
                                                width: 1,
                                                height: 25,
                                              ),
                                            ),
                                          ],
                                        ),
                                        contentPadding: EdgeInsets.only(top: 12),
                                        hintText: "Enter Confirm Password",
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.03,
                                    ),
                                    ElevatedButton(
                                      child: Container(
                                        height: 45,
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                          colors: [Color(0xffec4a63), Color(0xff7350c7)],
                                          begin: FractionalOffset(0.0, 1),
                                          end: FractionalOffset(0.4, 4),
                                          stops: [0.1, 0.7],
                                        )),
                                        child: Center(
                                          child: Text(
                                            'Register',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontFamily: 'RockWellStd',
                                            ),
                                          ),
                                        ),
                                      ),
                                      onPressed: () async {
                                        _con.register().then((value) {
                                          print("value");
                                          print(value);
                                          if (value != null) {
                                            if (value) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => VerifyOTPView(),
                                                ),
                                              );
                                            }
                                          }
                                        });
                                        // print(check);
                                      },
                                    ),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.03,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width - 30,
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                        ),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "Already ",
                                    style: TextStyle(
                                      height: 1.55,
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    "have an account ",
                                    style: TextStyle(
                                      height: 1.55,
                                      color: Color(0xfffcb37b),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              child: Container(
                                height: 45,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                  colors: [Color(0xffec4a63), Color(0xff7350c7)],
                                  begin: FractionalOffset(0.0, 1),
                                  end: FractionalOffset(0.4, 4),
                                  stops: [0.1, 0.7],
                                )),
                                child: Center(
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontFamily: 'RockWellStd',
                                    ),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, '/password-login');
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyDateTimePicker extends StatefulWidget {
  @override
  _MyDateTimePickerState createState() => _MyDateTimePickerState();
}

class _MyDateTimePickerState extends State<MyDateTimePicker> {
  DateTime _dateTime = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return CupertinoDatePicker(
      initialDateTime: _dateTime,
      onDateTimeChanged: (dateTime) {
        setState(() {
          _dateTime = dateTime;
        });
      },
    );
  }
}
