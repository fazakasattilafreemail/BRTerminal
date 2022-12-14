import 'dart:async';

import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/following_controller.dart';
import '../helpers/helper.dart';
import '../models/following_model.dart';
import '../repositories/following_repository.dart';
import 'chat.dart';
import 'user_profile_view.dart';

class FriendsListView extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  FriendsListView({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _FriendsListViewState createState() => _FriendsListViewState();
}

class _FriendsListViewState extends StateMVC<FriendsListView> {
  FollowingController _con;
  int page = 1;
  _FriendsListViewState() : super(FollowingController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.friendsList(page);
    super.initState();
  }

  Widget layout(obj) {
    if (obj != null) {
      if (obj.users.length > 0) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 185,
                child: ListView.builder(
                  controller: _con.scrollController,
                  padding: EdgeInsets.zero,
                  itemCount: obj.users.length,
                  itemBuilder: (context, i) {
                    print(obj.users[0].toString());
                    var fullName =
                        obj.users[i].firstName + " " + obj.users[i].lastName;
                    return Container(
                      decoration: new BoxDecoration(
                        border: new Border(
                          bottom: new BorderSide(
                            width: 0.2,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      child: ListTile(
                        leading: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UsersProfileView(userId: obj.users[i].id),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100.0),
                            child: (obj.users[i].dp != '')
                                ? Image.network(
                                    obj.users[i].dp,
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: Helper.showLoaderSpinner(
                                            Colors.black54),
                                      );
                                    },
                                    fit: BoxFit.fill,
                                    width: 50,
                                    height: 50,
                                  )
                                : Image.asset(
                                    'assets/images/default-user.png',
                                    fit: BoxFit.fill,
                                    width: 50,
                                    height: 50,
                                  ),
                          ),
                        ),
                        title: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UsersProfileView(userId: obj.users[i].id),
                              ),
                            );
                          },
                          child: Text(
                            obj.users[i].username,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        subtitle: Text(
                          fullName,
                          style:
                              TextStyle(color: Colors.black.withOpacity(0.8)),
                        ),
                        trailing: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatView(
                                    userId: obj.users[i].id,
                                    userName: fullName,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 85,
                              height: 26,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Center(
                                child: Text(
                                  "Start Chat",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )),
                        contentPadding: EdgeInsets.symmetric(horizontal: 5),
                      ),
                    );
                  },
                )),
          ),
        );
      } else {
        if (_con.noRecord) {
          return Center(
            child: Container(
              height: MediaQuery.of(context).size.height - 185,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.grey,
                  ),
                  Text(
                    "No record found",
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  )
                ],
              ),
            ),
          );
        } else if (!_con.showLoader) {
          return Center(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/users',
                );
              },
              child: Container(
                height: MediaQuery.of(context).size.height - 80,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          width: 2,
                          color: Colors.grey,
                        ),
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "This is your feed of user you follow.",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      "You can follow people or subscribe to hashtags.",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Icon(
                      Icons.person_add,
                      color: Colors.grey,
                      size: 45,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
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
            height: MediaQuery.of(context).size.height - 185,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.grey,
                ),
                Text(
                  "No User Yet",
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: friendsData,
        builder: (context, FollowingModel _user, _) {
          print("_user");
          print(_user);
          return ModalProgressHUD(
            inAsyncCall: _con.showLoader,
            progressIndicator: Helper.showLoaderSpinner(Colors.black),
            child: SafeArea(
              child: Scaffold(
                key: _con.scaffoldKey,
                // resizeToAvoidBottomPadding: false,
                resizeToAvoidBottomInset: false,
                body: SingleChildScrollView(
                  child: Container(
                    // color: Color(0XFF15161a),
                    color: Colors.white70,
                    child: Column(
                      children: <Widget>[
                        SingleChildScrollView(
                          child: Container(
                              child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height,
                                child: Container(
                                    child: Column(
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        Flexible(
                                          flex: 0,
                                          child: IconButton(
                                            color: Colors.grey,
                                            icon: new Icon(
                                              Icons.arrow_back_ios,
                                              size: 18,
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ),
                                        Flexible(
                                          flex: 1,
                                          child: Container(
                                            padding: EdgeInsets.only(right: 15),
                                            child: TextField(
                                              controller: _con.searchController,
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16.0,
                                              ),
                                              obscureText: false,
                                              keyboardType: TextInputType.text,
                                              onChanged: (String val) {
                                                setState(() {
                                                  _con.searchKeyword = val;
                                                });
                                                Timer(Duration(seconds: 1), () {
                                                  _con.friendsList(1);
                                                });
                                              },
                                              decoration: new InputDecoration(
                                                border: UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.grey,
                                                      width: 0.3),
                                                ),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.grey,
                                                      width: 0.3),
                                                ),
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.grey,
                                                      width: 0.3),
                                                ),
                                                hintText: "Search",
                                                hintStyle: TextStyle(
                                                    fontSize: 16.0,
                                                    color: Colors.grey),
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                        2, 15, 0, 0),
                                                suffixIcon: IconButton(
                                                  padding: EdgeInsets.only(
                                                      bottom: 0, right: 0),
                                                  onPressed: () {
                                                    _con.searchController
                                                        .clear();
                                                    setState(() {
                                                      _con.searchKeyword = '';
                                                      _con.friendsList(1);
                                                    });
                                                  },
                                                  icon: Icon(
                                                    Icons.clear,
                                                    color: (_con.searchKeyword
                                                                .length >
                                                            0)
                                                        ? Colors.black
                                                        : Colors.white54,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    (_user != null)
                                        ? layout(_user)
                                        : Container()
                                  ],
                                )),
                              ),
                            ],
                          )),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
