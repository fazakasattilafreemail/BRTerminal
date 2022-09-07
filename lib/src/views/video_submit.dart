import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/video_recorder_controller.dart';
import '../views/video_recorder.dart';

class VideoSubmit extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  final String videoPath;
  final String thumbPath;
  final String gifPath;

  VideoSubmit({@required this.videoPath, @required this.thumbPath, @required this.gifPath, this.parentScaffoldKey})
      : assert(videoPath != null),
        assert(thumbPath != null);
  @override
  _VideoSubmitState createState() => _VideoSubmitState();
}

class _VideoSubmitState extends StateMVC<VideoSubmit> with SingleTickerProviderStateMixin {
  VideoRecorderController _con;
  _VideoSubmitState() : super(VideoRecorderController()) {
    _con = controller;
  }
  AnimationController animationController;

  @override
  void initState() {
    print("thumbImg ${widget.thumbPath}");
    print("videoPath ${widget.videoPath}");
    // TODO: implement initState
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    getImageWidth();
    super.initState();
  }

  bool fitHeight = false;
  getImageWidth() async {
    File image = new File(widget.thumbPath); // Or any other way to get a File instance.
    print("getImageWidth ${widget.videoPath} ${widget.thumbPath}");
    var decodedImage = await decodeImageFromList(image.readAsBytesSync());
    print("${decodedImage.width} > ${decodedImage.height}");
    if (decodedImage.width > decodedImage.height) {
      print("entered");
      setState(() {
        fitHeight = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.white70,
        elevation: 1.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.grey,
            size: 25,
          ),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VideoRecorder(),
            ),
          ),
        ),
        title: Text('Post'),
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
      key: _con.scaffoldKey,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: publishPanel(),
      ),
    );
  }

  Widget publishPanel() {
    const Map<String, int> privacies = {'Public': 0, 'Private': 1, 'Only Followers': 2};

    return Stack(
      children: [
        Column(
          children: [
            MediaQuery.removePadding(
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
                  key: _con.key,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 7.5,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.2),
                        child: Container(
                          height: MediaQuery.of(context).size.height / 2.5,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 5.0,
                              ),
                            ],

                            /*border: Border.all(
                              color: Colors.pinkAccent,
                              width: 0.5,
                            ),*/
                            color: Color(0xff2e2f34),
                            shape: BoxShape.rectangle,
                            image: DecorationImage(
                              image: widget.thumbPath != ''
                                  ? new FileImage(
                                      File(
                                        widget.thumbPath,
                                      ),
                                    )
                                  : AssetImage("assets/images/camera.png"),
                              fit: fitHeight == true ? BoxFit.fitHeight : BoxFit.fitWidth,
                            ),
                          ),

                          /* child: CachedNetworkImage(
                                        imageUrl: thumbPath,
                                        height: 175,
                                      ),*/
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
                      Container(
                        height: MediaQuery.of(context).size.height / 3,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * .1, vertical: 0),
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                flex: 4,
                                child: TextFormField(
                                  maxLines: 5,
                                  keyboardType: TextInputType.multiline,
                                  style: TextStyle(
                                    fontFamily: 'RockWellStd',
                                    fontSize: 18.0,
                                    color: Colors.grey,
                                  ),
                                  validator: _con.validateDescription,
                                  onSaved: (String val) {
                                    _con.description = val;
                                  },
                                  onChanged: (String val) {
                                    _con.description = val;
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
                                    hintText: "Enter Video Description",
                                    hintStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                              ),
                              /*Expanded(
                                flex: 4,
                                child: TextFormField(
                                  maxLines: 5,
                                  keyboardType: TextInputType.multiline,
                                  style: TextStyle(
                                    fontFamily: 'RockWellStd',
                                    fontSize: 18.0,
                                    color: Colors.grey,
                                  ),
                                  // validator: _con.validateHashTags,
                                  onSaved: (String val) {
                                    _con.description = val;
                                  },
                                  onChanged: (String val) {
                                    _con.description = val;
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
                                      borderSide:
                                          BorderSide(color: Colors.grey),
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
                                    */ /*errorBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1.0,
                                    ),
                                  ),*/ /*
                                    hintText: "Add Hash Tags",
                                    hintStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                              ),*/
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Container(
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      canvasColor: Colors.black,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                          flex: 3,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.lock_outline,
                                                color: Colors.grey,
                                                size: 22,
                                              ),
                                              SizedBox(
                                                width: 15,
                                              ),
                                              Text(
                                                "Privacy Setting",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 15,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            width: MediaQuery.of(context).size.width * .4,
                                            child: Theme(
                                              data: Theme.of(context).copyWith(
//                                      canvasColor: Color(0xffffffff),
                                                canvasColor: Colors.black87,
                                              ),
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButtonFormField(
                                                  isExpanded: true,
                                                  hint: new Text(
                                                    "Select Type",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  iconEnabledColor: Colors.white,
                                                  style: new TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 15.0,
                                                  ),
                                                  value: _con.privacy,
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      _con.privacy = newValue;
                                                    });
                                                  },
                                                  items: privacies
                                                      .map((text, value) {
                                                        return MapEntry(
                                                          text,
                                                          DropdownMenuItem<int>(
                                                            value: value,
                                                            child: new Text(
                                                              text,
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors.grey,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      })
                                                      .values
                                                      .toList(),
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
                              SizedBox(
                                height: 25,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton(

                                      child: Container(
                                        height: 45,
                                        width: 200,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(30.0),
                                          gradient: Gradients.blush,
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Cancel",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 20,
                                              fontFamily: 'RockWellStd',
                                            ),
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        // Validate returns true if the form is valid, otherwise false.
                                        Navigator.of(context).pushReplacementNamed('/redirect-page', arguments: 0);
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton(
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
                                                "Submit",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 20,
                                                  fontFamily: 'RockWellStd',
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                child: Icon(
                                                  Icons.send,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      onPressed: () async {
                                        FocusManager.instance.primaryFocus.unfocus();

                                        // Validate returns true if the form is valid, otherwise false.
                                        if (_con.key.currentState.validate()) {
                                          // If the form is valid, display a snackbar. In the real world,
                                          // you'd often call a server or save the information in a database.
                                          // _con.enableVideo(context);
                                          print("thumbPath ${_con.thumbPath}");
                                          bool resp = await _con.uploadVideo(
                                            widget.videoPath,
                                            widget.thumbPath,
                                          );
                                          if (resp == true) {
                                            Navigator.of(context).pushReplacementNamed('/my-profile');
                                          }
                                        } else {
                                          // Scaffold.of(context).showSnackBar(
                                          //   SnackBar(
                                          //     backgroundColor: Colors.redAccent,
                                          //     behavior: SnackBarBehavior.floating,
                                          //     content: Text("Enter Video Description"),
                                          //   ),
                                          // );
                                        }
                                      },
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
          ],
        ),
        AnimatedIcon(
          color: Colors.black,
          icon: AnimatedIcons.add_event,
          progress: animationController,
          semanticLabel: 'Show menu',
        ),
        (_con.isUploading == true)
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop),
                    image: widget.thumbPath != ''
                        ? new FileImage(
                            File(
                              widget.thumbPath,
                            ),
                          )
                        : AssetImage("assets/images/camera.png"),
                    fit: fitHeight == true ? BoxFit.fitHeight : BoxFit.fitWidth,
                  ),
//                            borderRadius: BorderRadius.circular(20),
                  color: const Color(0xff7c94b6),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.black87,
                        ),
                        width: 200,
                        height: 170,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: <Widget>[
                              Container()
                              // Center(
                              //   child: CircularPercentIndicator(
                              //     progressColor: Colors.pink,
                              //     percent: _con.uploadProgress,
                              //     radius: 120.0,
                              //     lineWidth: 8.0,
                              //     circularStrokeCap: CircularStrokeCap.round,
                              //     center: _con.uploadProgress >= 1
                              //         ? Image.asset(
                              //             "assets/icons/select.png",
                              //             width: 80,
                              //           )
                              //         : Text(
                              //             (_con.uploadProgress * 100).toStringAsFixed(2) + "%",
                              //             style: TextStyle(color: Colors.white),
                              //           ),
                              //   ),
                              // ),

                              /*Container(
                                            child: Text(
                                              (uploadProgress * 100)
                                                      .toStringAsFixed(2) +
                                                  " %",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10.0,
                                          ),
                                          SizedBox(
                                            height: 2.0,
                                            child: LinearProgressIndicator(
                                              value: uploadProgress,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10.0,
                                          ),*/
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    _con.uploadProgress >= 1
                        ? Column(
                            children: [
                              Center(
                                child: Container(
                                  child: Text(
                                    "Yay!!",
                                    style: TextStyle(
                                      color: Colors.pinkAccent,
                                      fontSize: 30,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              Center(
                                child: Container(
                                  child: Text(
                                    "Your video is posted",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              Center(
                                child: ElevatedButton(
                                  child: Container(
                                    height: 45,
                                    width: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30.0),
                                      gradient: Gradients.blush,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Exit",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 20,
                                          fontFamily: 'RockWellStd',
                                        ),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pushReplacementNamed('/my-profile');
                                  },
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  ],
                ),
              )
            : Container(),
      ],
    );
  }
}
