import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../models/videos_model.dart';
import '../repositories/video_repository.dart' as videoRepo;

class VideoDescription extends StatefulWidget {
  final Video video;
  final PanelController pc3;
  final  Function(String) editClicked;
  VideoDescription( this.video, this.pc3, this.editClicked);
  @override
  _VideoDescriptionState createState() => _VideoDescriptionState();
}

class _VideoDescriptionState extends State<VideoDescription> {
  String username = "";
  String description = "";
  String appToken = "";
  int soundId = 0;
  int loginId = 0;
  bool isLogin = false;
  AnimationController animationController;
  // static const double ActionWidgetSize = 60.0;
  // static const double ProfileImageSize = 50.0;

  String soundImageUrl;

  String profileImageUrl = "";

  bool showFollowLoader = false;
  bool isVerified = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    username = widget.video.username;
    isVerified = widget.video.isVerified;
    // isVerified = true;
    description = widget.video.description;
    profileImageUrl = widget.video.userDP;
    print("CheckVerified $username ${widget.video.isVerified};");
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
/*
  _getSessionData() async {
    sessions.getUserInfo().then((obj) {
      setState(() {
        if (obj['user_id'] > 0) {
          isLogin = true;
          loginId = obj['user_id'];
          appToken = obj['app_token'];
        } else {}
      });
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120.0,
      padding: EdgeInsets.only(left: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[

              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  username != ''
                      ? Row(
                        children: [
                          InkWell(
                            onTap: () async {
                              await videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                              await videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
                              print('velt egesz');
                              widget.editClicked('type');
                            },
                            child: Text(
                              username!=null && username.contains(";")&& username.split(";").length>0?username.split(";")[0]+"  ":"hhihi",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              await videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex)?.pause();
                              await videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2)?.pause();
                              print('velt egesz');
                              widget.editClicked('name');
                            },
                            child: Text(
                              username!=null && username.contains(";")&& username.split(";").length>1?"  "+username.split(";")[1]+"  ":"",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20.0,
                          ),
                        ],
                      )
                      : Container(),

                ],
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[

              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  username != ''
                      ? Row(
                        children: [
                          Text(
                            description!=null?description:"#",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          isVerified == true
                              ? Icon(
                                  Icons.verified,
                                  color: Colors.blueAccent,
                                  size: 16,
                                )
                              : Container(),
                          SizedBox(
                            width: 20.0,
                          ),
                        ],
                      )
                      : Container()
                ],
              ),
            ],
          ),

        ],
      ),
    );
  }


  LinearGradient get musicGradient =>
      LinearGradient(colors: [Colors.grey[800], Colors.grey[900], Colors.grey[900], Colors.grey[800]], stops: [0.0, 0.4, 0.6, 1.0], begin: Alignment.bottomLeft, end: Alignment.topRight);
}
