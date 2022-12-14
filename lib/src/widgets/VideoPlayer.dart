import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:pedantic/pedantic.dart';
import 'package:video_player/video_player.dart';

import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../models/videos_model.dart';
import '../repositories/video_repository.dart' as videoRepo;
import '../services/CacheManager.dart';

class VideoPlayerWidget extends StatefulWidget {
  final Video videoObj;
  VideoPlayerController videoController;
  Future<void> initializeVideoPlayerFuture;
  VideoPlayerWidget(this.videoController, this.videoObj, this.initializeVideoPlayerFuture);
  @override
  VideoPlayerWidgetState createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends StateMVC<VideoPlayerWidget> {
  int chkVideo = 0;
  VoidCallback listener;
  GlobalKey<ScaffoldState> scaffoldKey;
  @override
  void initState() {
    scaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: widget.videoObj.videoId.toString());
    listener = () {
// print("addls");
// print(widget.videoController.value.position.inSeconds);
// print("chkVideo");
// print(chkVideo);
// print(widget.videoObj.videoId);

      if (widget.videoController!=null && widget.videoController.value.position.inSeconds == 5) {
// print("entered=d");
        widget.videoController.removeListener(listener);

        chkVideo = 1;

//        videoRepo.incVideoViews(widget.videoObj);
      } else {
        return;
      }
    };
    checkVideoController();
    super.initState();
  }

  checkVideoController() async {
    try {
      if (widget.videoController.hasListeners) {
        if (widget.videoController?.value.isInitialized) {
          widget.videoController?.play();
          setState(() {
            videoRepo.homeCon.value.onTap = false;
          });
        }
      } else {}
    } catch (e) {
      print("error play=");
      final fileInfo =  null;//await CustomCacheManager.instance.getFileFromCache(widget.videoObj.url);//=null;//web buildhez

      VideoPlayerController controller;
/*double volume = 0;
if (videoRepo.homeCon.value.muted == true) {
volume = 0;video_player_web
} else {
volume = 1;
}*/
      if (fileInfo == null || fileInfo.file == null) {
        print('[VideoControllerService]: No video in cache');

        print('[VideoControllerService]: Saving video to cache');
        unawaited(CustomCacheManager.instance.downloadFile(widget.videoObj.url).whenComplete(() => print('saved video url ${widget.videoObj.url}')));
        controller = VideoPlayerController.network(widget.videoObj.url);
// controller.setVolume(volume);
        widget.videoController = controller;
      } else {
        print('[VideoControllerService]: Loading video from cache');
        controller = VideoPlayerController.file(fileInfo.file);
// controller.setVolume(volume);
        widget.videoController = controller;
      }
      widget.initializeVideoPlayerFuture = widget.videoController.initialize();
      videoRepo.homeCon.value.videoControllers[widget.videoObj.url] = widget.videoController;

      videoRepo.homeCon.value.initializeVideoPlayerFutures[widget.videoObj.url] = widget.initializeVideoPlayerFuture;
      videoRepo.homeCon.notifyListeners();
      if (widget.videoController?.value.isInitialized) {
        widget.videoController?.play();

        setState(() {
          videoRepo.homeCon.value.onTap = false;
        });
      }
    }
    if (chkVideo == 0) {
      widget.videoController.addListener(listener);
    } else {
      widget.videoController.removeListener(listener);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: widget.initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
// widget.videoController.play();
            return GestureDetector(
              onTap: () {
                setState(() {
                  videoRepo.homeCon.value.onTap = true;
                  if (widget.videoController.value.isPlaying) {
                    widget.videoController.pause();
                  } else {
                    widget.videoController.play();
                  }
                });
              },
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Center(
                          child: Container(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height,
                              maxWidth: MediaQuery.of(context).size.width,
//                              minHeight: MediaQuery.of(context).size.height,//faziii csinalta
//                              minWidth: MediaQuery.of(context).size.width,//faziii csinalta
                            ),
                            child: AspectRatio(
                              aspectRatio: widget.videoController.value.aspectRatio,
                              child: VideoPlayer(widget.videoController),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.play_circle_outline,
                              color: widget.videoController.value.isPlaying
                                  ? Colors.transparent
                                  : (!videoRepo.homeCon.value.onTap)
                                      ? Colors.transparent
                                      : Colors.transparent/*Colors.grey[200]*/,//TODO
                              size: 80,

                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: Container(
                            height: config.App(scaffoldKey.currentContext).appHeight(40),
                            width: config.App(scaffoldKey.currentContext).appWidth(100),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black38,
                                  Colors.black26,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          } else {
            return Stack(
              children: [
                Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height,
                      maxWidth: MediaQuery.of(context).size.width,
                    ),
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        image: DecorationImage(
                          image: widget.videoObj.videoThumbnail!=null?CachedNetworkImageProvider(
                           widget.videoObj.videoThumbnail/*"https://www.rd.com/wp-content/uploads/2017/09/01-shutterstock_476340928-Irina-Bg-1024x683.jpg",*/
                          ):
                          new AssetImage('assets/images/noVideo.jpg'),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Helper.showLoaderSpinner(Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    height: config.App(scaffoldKey.currentContext).appHeight(40),
                    width: config.App(scaffoldKey.currentContext).appWidth(100),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black38,
                          Colors.black26,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

/*@override
void dispose() {
// TODO: implement dispose
super.dispose();
}*/
}
