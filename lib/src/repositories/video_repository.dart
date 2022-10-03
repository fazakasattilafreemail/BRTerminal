import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:Leuke/src/helpers/shared_pref.dart';
import 'package:Leuke/src/models/my_models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/dashboard_controller.dart';
import '../helpers/helper.dart';
import '../models/videos_model.dart';
import '../repositories/user_repository.dart' as userRepo;

ValueNotifier<DashboardController> homeCon = new ValueNotifier(DashboardController());
ValueNotifier<bool> dataLoaded = new ValueNotifier(false);
ValueNotifier<bool> firstLoad = new ValueNotifier(true);
ValueNotifier<VideoModel> videosData = new ValueNotifier(VideoModel());
ValueNotifier<List<String>> watchedVideos = new ValueNotifier([]);
ValueNotifier<VideoModel> followingUsersVideoData = new ValueNotifier(VideoModel());

//Future<VideoModel> getVideos(page, [obj]) async {
//  Uri uri = Helper.getUri('get-videos');
//  uri = uri.replace(queryParameters: {
//    "page_size": '10',
//    "page": page.toString(),
//    "user_id": obj != null
//        ? (obj['userId'] == null)
//            ? '0'
//            : obj['userId'].toString()
//        : '0',
//    "video_id": obj != null
//        ? (obj['videoId'] == null)
//            ? '0'
//            : obj['videoId'].toString()
//        : '0',
//    "login_id": userRepo.currentUser.value.userId == null ? '0' : userRepo.currentUser.value.userId.toString(),
//  });
//  try {
//    Map<String, String> headers = {
//      'Content-Type': 'application/json; charset=UTF-8',
//      'USER': '${GlobalConfiguration().get('api_user')}',
//      'KEY': '${GlobalConfiguration().get('api_key')}',
//    };
//    var response = await http.get(uri, headers: headers);
//    if (response.statusCode == 200) {
//      var jsonData = json.decode(response.body);
//      if (jsonData['status'] == 'success') {
//        print(jsonData.toString());
//        if (page > 1) {
//          videosData.value.videos.addAll(VideoModel.fromJson(json.decode(response.body)['data']).videos);
//        } else {
//          videosData.value = null;
//          videosData.notifyListeners();
//          videosData.value = VideoModel.fromJson(json.decode(response.body)['data']);
//        }
//        videosData.notifyListeners();
//        return videosData.value;
//      }
//    }
//  } catch (e) {
//    print(e.toString());
//    VideoModel.fromJson({});
//  }
//}


class VideoElem {
  final String type;
  final PayloadElem payload;

  VideoElem(
      {
        this.type,
        this.payload});

  factory VideoElem.fromJson(Map<String, dynamic> parsedJson) {
    var payload = parsedJson['payload']!=null?parsedJson['payload']:null;
    PayloadElem payloadE = payload!=null?PayloadElem.fromJson(payload):null;
    return VideoElem(
        type: parsedJson['type'],
        payload: payloadE
    );
  }
}

class PayloadElem {
  final List<VideoItemElem> videos;

  PayloadElem(
      {
        this.videos});

  factory PayloadElem.fromJson(Map<String, dynamic> parsedJson) {
    var videos = parsedJson['videos']!=null?parsedJson['videos'] as List:null;
    List<VideoItemElem> videoItemList = videos!=null?videos.map((i) => VideoItemElem.fromJson(i)).toList()/*.reversed.toList()*/:null;
    return PayloadElem(
        videos: videoItemList
    );
  }
}
class FilterElem {
  List<String> jatekosok;
  List<String> csapatok;
  List<String> ratingek;
  List<String> helyzettipusok;
  List<String> rating;
  String start_date;
  String end_date;

  FilterElem(
      {this.jatekosok,
        this.csapatok, this.ratingek, this.helyzettipusok,  this.rating, this.start_date, this.end_date});


}
class VideoItemElem {
  String id;
  String name;
  bool processed;
  String url;
  String thumbnail;
  final List<FilesItemElem> files;

  VideoItemElem(
      {this.id,
        this.name, this.processed, this.url, this.thumbnail, this.files});

  factory VideoItemElem.fromJson(Map<String, dynamic> parsedJson) {
    var files = parsedJson.containsKey('files') && parsedJson['files']!=null?parsedJson['files'] as List:null;
    List<FilesItemElem> filesItemList = files!=null?files.map((i) => FilesItemElem.fromJson(i)).toList()/*.reversed.toList()*/:null;
    return VideoItemElem(
        id: parsedJson['id'],
        name: parsedJson['name'],
        processed: parsedJson['processed'],
        url: parsedJson['url'],
        thumbnail: parsedJson.containsKey('thumbnail')?parsedJson['thumbnail']:"",
        files: filesItemList
    );
  }
}
class FilesItemElem {
  String quality;
  String type;
  String link;
  String created_time;
  int size;

  FilesItemElem(
      {this.quality,
        this.type, this.link, this.created_time, this.size});

  factory FilesItemElem.fromJson(Map<String, dynamic> parsedJson) {
    return FilesItemElem(
        quality: parsedJson['quality'],
        type: parsedJson['type'],
        link: parsedJson['link'],
        created_time: parsedJson['created_time'],
        size: parsedJson['size']
    );
  }
}

String meccsNameWithoutTime(String m){
  try {
    String s = m.split("_")[1];

    return s;
  } catch(e){

  }
  return m;
}
Future<VideoModel> getVideos(page, FilterElem filterElem, Map<String, MyPlayerElem> myPlayers,VoidCallback callBackForFilteredLength, String selProfile, [String defaultFilter])  async {
  print('GETVIDEOS filterElem1');
  if (filterElem!=null) {
    print('GETVIDEOS filterElem : ' );
  }
  try {
    List<String> deepIds = await SharedPreferencesHelper.getDeepLinkIds();
    // await SharedPreferencesHelper.setDeepLinkIds(<String>[]);
    print('torolveeeee: ' );
    String deepProfile = "";
    if (deepIds!=null && deepIds.length != 0){
      deepProfile =  await SharedPreferencesHelper.getDeepLinkProfile();
    }
    print('get lastVideosResponse1 selProfile: '+selProfile==null?"null":"nem null");
    String lastVideosResponse =  await SharedPreferencesHelper.getLastVideosResponse();
    print('get lastVideosResponse2: '+lastVideosResponse);
    var response = null;
    if (lastVideosResponse==null ||lastVideosResponse=='') {
      var headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImV4cCI6MTY5MDUzMjg1OSwiaWF0IjoxNjU4OTk2ODU5fQ.LiAvXxwjHI3sZfCJS5MBDoaG9MBzq6E4bErPLF8Jd80'
      };
      if (selProfile!=null&&(selProfile.contains("FKCS2008")||selProfile=='playersszereda')) {
        print('200 selProfile nem null: ' +selProfile);
        headers = {
          'Accept': 'application/json',
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImV4cCI6MTY5Mjc2OTAwMiwiaWF0IjoxNjYxMjMzMDAyfQ.5PCJFMXlCnZRvJnNkEpxEI_1Cks2kRDGbiR5KCdEOXc'
        };
      }
      if (deepProfile!=null&&deepProfile!="") {
        if (deepProfile=="0") {
          print('200 deepProfile nem null: ' + deepProfile);
          headers = {
            'Accept': 'application/json',
            'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImV4cCI6MTY5Mjc2OTAwMiwiaWF0IjoxNjYxMjMzMDAyfQ.5PCJFMXlCnZRvJnNkEpxEI_1Cks2kRDGbiR5KCdEOXc'
          };
        } else if (deepProfile=="1") {
          print('200 deepProfile nem null: ' + deepProfile);
          headers = {
            'Accept': 'application/json',
            'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImV4cCI6MTY5MDUzMjg1OSwiaWF0IjoxNjU4OTk2ODU5fQ.LiAvXxwjHI3sZfCJS5MBDoaG9MBzq6E4bErPLF8Jd80'
          };
        }
      }
      var url =
          "https://api.backrec.eu" +
              "/videos?start=2021-02-02&end=2025-12-31";//2021-02-02&end=2025-12-31
      if (filterElem!=null && filterElem.start_date!=null && filterElem.start_date!="" && filterElem.end_date!=null && filterElem.end_date!=""){
        url =
            "https://api.backrec.eu" +
                "/videos?start="+filterElem.start_date+"&end="+filterElem.end_date;//+filterElem.start_date+"&end="+filterElem.end_date;
      }
      if (filterElem != null && filterElem.csapatok != null &&
          filterElem.csapatok.length > 0) {
        print('111111 videos ' + filterElem.csapatok[0]);
        String pref = "&prefix=";
        filterElem.csapatok.forEach((element) {
          if (pref!='&prefix='){
            pref+=",";
          }
          if (element.contains("_")){
            pref+=element.split("_")[1];
          } else {
            pref+=element;
          }
        });
        if (pref!='&prefix=' && !pref.endsWith(",")){
          url+=pref;
        }
        // url =
        //    "http://199.192.19.153:3000"+"/videos?start=2022-01-24&end=2022-02-31&prefix="+filterElem.csapatok[0];
      } else if (selProfile!=null) {




        //EZ A RESZ KISZEDVE, H BARMILYEN CSAPAT BEJOJJON
        /*String selectedProfilFilter = selProfile;
        // String selectedProfilFilter = "FKCS2008,FKCS2009,FKCS2010,FKCS2011,FKCS2013,Nyaradszereda2009,Nyaradszereda2011,Nyaradszereda2013";
        String pref = "&prefix=";
        if (pref!='&prefix='){
          pref+=",";
        }
        pref+=selectedProfilFilter;
        if (pref!='&prefix=' && !pref.endsWith(",")){
          url+=pref;
        }*/




        //
        // String selectedProfilFilter = selProfile;
        // // String selectedProfilFilter = "FKCS2008,FKCS2009,FKCS2010,FKCS2011,FKCS2013,Nyaradszereda2009,Nyaradszereda2011,Nyaradszereda2013";
        // String pref = "&prefix=";
        // if (pref!='&prefix='){
        //   pref+=",";
        // }
        // if (double.tryParse(selProfile) != null){
        //   pref=pref+"\_"+selProfile+"\_";
        // } else {
        //   pref+=selectedProfilFilter;
        // }
        //
        // if (pref!='&prefix=' && !pref.endsWith(",")){
        //   url+=pref;
        // }
      }
      print('vegso url: '+url);
      response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 60));
    } else{

      await Future.delayed(Duration(milliseconds: 200));

    }
    if ((response!=null && response.statusCode == 200)|| (lastVideosResponse!=null &&lastVideosResponse!='') ) {

      print('200 BR videos ' +deepIds.toString());
      var responseJson;
      if (response!=null &&  response.statusCode == 200) {
        print('setlastvideos meghivodik');
        await SharedPreferencesHelper.setLastVideosResponse(response.body);
        responseJson = json.decode(response.body);
      } else {
        responseJson = json.decode(lastVideosResponse);
      }
      VideoElem listOfVideosTmp = new VideoElem.fromJson(responseJson);
      VideoElem listOfVideos = new VideoElem.fromJson(responseJson);
      print('listOfVideosssss '+listOfVideos.payload.videos.length.toString() );
      listOfVideosTmp.payload.videos.removeWhere((element) => !element.name.contains("."));
      listOfVideosTmp.payload.videos.sort((a, b) => a.name.compareTo(b.name));
      listOfVideos.payload.videos.clear();
      String recentMeccsekString = "";
      String meccsLast = "-";

      print('NYOMOZ  1' );
      if (listOfVideosTmp.payload.videos.length > 0) {
        VideoItemElem videoElemLast = listOfVideosTmp.payload.videos[listOfVideosTmp.payload.videos.length-1];
        log('NYOMOZ  1 videoElemLast.name:' +videoElemLast.name);
        List<String> splitArray = videoElemLast.name.split("_");

        if(splitArray.length>0){
          meccsLast =videoElemLast.name.split("-")[0]+"_"+ splitArray[splitArray.length-1].substring(0,splitArray[splitArray.length-1].lastIndexOf("."));
        }
      }
      print ('NYOMOZ  2 ' +listOfVideosTmp.payload.videos.length.toString());

       if (defaultFilter=="last_match" && meccsLast!="-") {
        List<String> meccsFilterForDefault = <String>[];
        meccsFilterForDefault.add(meccsLast);
        List<String> meccsFilterForDefault1 = <String>[];
        meccsFilterForDefault1.add(meccsNameWithoutTime(meccsLast));
        SharedPreferencesHelper.setFilterMatches(meccsFilterForDefault1);
        SharedPreferencesHelper.setFilterNames(<String>[]);
        SharedPreferencesHelper.setFilterTypes(<String>[]);
        SharedPreferencesHelper.setFilterRating(<String>['1','1','1','1','1']);
        if (deepIds!=null && deepIds.length != 0){
          filterElem = new FilterElem(rating: <String>['1','1','1','1','1'] );
          homeCon.value.myfilter = filterElem;
        } else {
          filterElem = new FilterElem(csapatok: meccsFilterForDefault1,
              rating: <String>['1', '1', '1', '1', '1']);
          homeCon.value.myfilter = filterElem;
        }
      }
      print('NYOMOZ  22' );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      //HD 1080p
      //HD 720p
      //SD 540p
      //SD 360p
      //SD 240p
      String qualitySelected =  await prefs.getString("quality") ?? "HD_720p";
      // print('NYOMOZ  222  '+qualitySelected);
      // print('NYOMOZ  2221  '+listOfVideosTmp.toString());
      // print('NYOMOZ  22211  '+listOfVideosTmp.payload.toString());
      // print('NYOMOZ  222111  '+listOfVideosTmp.payload.videos.toString());
      print('NYOMOZ  22ee'+deepIds.toString() );
      for (VideoItemElem videoElem in listOfVideosTmp.payload.videos) {
        if (deepIds!=null && deepIds.length > 0 && !deepIds.contains(videoElem.id)){print('NYOMOZ  ??2222 ' );}
        else {
        Video v = new Video();
        String usedUrl = videoElem.url;
        print('NYOMOZ  2222 ' + usedUrl);
        try {
          if (videoElem.files != null && videoElem.files.length > 0) {
            videoElem.files.sort((a, b) => b.size.compareTo(a.size));
            videoElem.files.removeWhere((element) => element.quality == "hls");

            // videoElem.files.forEach((element) {
            //   print('Q:'+element.quality+'  SIZE::: '+element.size.toString());
            // });
            print("\n\nkov\n");
            if (qualitySelected == "HD_1080p" && videoElem.files.length > 0 &&
                (videoElem.files[ 0].quality != "hls")) {
              usedUrl = videoElem.files[0].link;
            } else
            if (qualitySelected == "HD_720p" && videoElem.files.length > 1 &&
                (videoElem.files[ 1].quality != "hls")) {
              usedUrl = videoElem.files[1].link;
            } else
            if (qualitySelected == "SD_540p" && videoElem.files.length > 2 &&
                (videoElem.files[ 2].quality != "hls")) {
              usedUrl = videoElem.files[2].link;
            } else
            if (qualitySelected == "SD_360p" && videoElem.files.length > 3 &&
                (videoElem.files[ 3].quality != "hls")) {
              usedUrl = videoElem.files[3].link;
            } else
            if (qualitySelected == "SD_240p" && videoElem.files.length > 4 &&
                (videoElem.files[ 4].quality != "hls")) {
              usedUrl = videoElem.files[4].link;
            } else
            if (videoElem.files[ videoElem.files.length - 1].quality != "hls") {
              usedUrl = videoElem.files[ videoElem.files.length - 1].link;
            }
          }
        } catch (e) {
          print('GEBASZZZZZZZZZZZZZZZZZZZZZZZ');
          usedUrl = videoElem.url;
        }

        v.url = usedUrl;
        print('1 URL VEGLEGES :' + videoElem.name);
        v.videoId = int.parse(videoElem.id);
        List<String> splitArray = videoElem.name.split("_");
        String meccs = "-";
        String idopont = "";
        if (splitArray.length > 0) {

          print(" splitArray[splitArray.length - 1].lastIndexOf(.) :" +  splitArray[splitArray.length - 1].lastIndexOf(".").toString());
          meccs = splitArray[splitArray.length - 1].substring(
              0, splitArray[splitArray.length - 1].lastIndexOf("."));
          print('splitArray[0] '+splitArray[0]);
          idopont = splitArray[0].split("-")[0];
        }
        print('NYOMOZ  3');

        List<String> videoTipusTags = <String>[];
        String videoRatingTag = "";
        List<String> videoNameTags = <String>[];
        if (splitArray.length >= 4) {
          String tagsString = splitArray[2];
          if (tagsString.length >= 9) {
            String elsoTip = tagsString.substring(0, 1);
            if (elsoTip != '0') {
              videoTipusTags.add(elsoTip);
            }
            String masodikTip = tagsString.substring(1, 2);
            if (masodikTip != '0') {
              videoTipusTags.add(masodikTip);
            }
            String elsoP = tagsString.substring(2, 5);
            if (elsoP != '000') {
              videoNameTags.add(elsoP);
            }
            String masodikP = tagsString.substring(5, 8);
            if (masodikP != '000') {
              videoNameTags.add(masodikP);
            }
            videoRatingTag = tagsString.substring(8, 9);
          }
        }

        if (idopont != "" && (idopont.compareTo("20200723") < 0 ||
            idopont.compareTo("20210307") > 0 || idopont.startsWith("2019")) &&
            !idopont.startsWith("20210323") &&
            idopont.compareTo("20210523") > 0) {
          // print('4444444 recentMeccsekString ' + recentMeccsekString);
          if (recentMeccsekString == "") {
            recentMeccsekString += idopont+"_"+meccs;
          } else if (!recentMeccsekString.contains(meccs)) {
            recentMeccsekString = idopont+"_"+meccs + ";" + recentMeccsekString;
          }
          print('set recentmeccsek '+recentMeccsekString);
          if (filterElem == null) {
            print('4444444 e ');
            if (!videoElem.name.contains("merged") &&
                !videoElem.name.contains("TEST1-TEST2") &&
                !videoElem.name.contains("U9-Sz")) {
              print('4444444 filterElem == null videoElem.name ' +
                  videoElem.name.toString());
              listOfVideos.payload.videos.add(videoElem);
            }
          } else {
            bool kemTipus = true;
            bool kemCsapat = true;
            bool kemJatekos = true;
            bool kemIdo = true;
            bool kemRating = true;
            print('4444444 rating ');
            if (filterElem.rating.contains('0')) {
              kemRating = false;
              if (videoRatingTag == "" && filterElem.rating[0] == '1') {
                kemRating = true;
              } else if (videoRatingTag != "") {
                int idx = int.parse(videoRatingTag);
                if (filterElem.rating[idx] == '1') {
                  kemRating = true;
                }
              }
            }
            if (filterElem.helyzettipusok != null &&
                filterElem.helyzettipusok.length > 0) {
              kemTipus = false;
              for (String tipus in filterElem.helyzettipusok) {
                if (videoTipusTags.contains(tipus)) {
                  kemTipus = true;
                }
              }
            }

            if (filterElem.csapatok != null && filterElem.csapatok.length > 0) {
              kemCsapat = false;
              for (String csapat in filterElem.csapatok) {
                if (videoElem.name.contains(csapat)) {
                  kemCsapat = true;
                }
              }
            }
            if (videoElem.name.contains("TEST1-TEST2")) {
              kemCsapat = false;
            }

            print('filter:::::::::' + (filterElem.jatekosok == null ||
                filterElem.jatekosok.length == 0 ? "n" : filterElem.jatekosok
                .first));
            print('videoNameTags:::::::::' +
                (videoNameTags == null || videoNameTags.length == 0
                    ? "n"
                    : videoNameTags.first));
            if (filterElem.jatekosok != null &&
                filterElem.jatekosok.length > 0) {
              kemJatekos = false;
              for (String jatekos in filterElem.jatekosok) {
                if (videoNameTags.contains(jatekos)) {
                  kemJatekos = true;
                }
              }
            }

            if (kemTipus && kemCsapat && kemJatekos && kemIdo && kemRating) {
              print('ADDDDDDDED  videoElem.name ' + videoElem.name.toString());

              listOfVideos.payload.videos.add(videoElem);
            }
          }
        }
      }
      }
      if (defaultFilter!=null && defaultFilter=="last_match") {
        print('set recentmeccsek');
        prefs.setString(
            'recentMeccsek',
            recentMeccsekString
        );
      }
      int i = 0;
      bool kem = false;
      VideoModel videoModel = new VideoModel();
      List<String>  filteredIds = <String>[];
      print('GETVIDEOS IDOMERES 2 '+DateTime.now().toString());
      for (VideoItemElem videoElem in listOfVideos.payload.videos){
        filteredIds.add(videoElem.id);
        if (i>=(0+(page-1)*10) && i<(0+(page-1)*10+10) ) {
          kem  = true;
          Video v = new Video();
          String usedUrl = videoElem.url;
          try {
            if (videoElem.files != null&&videoElem.files.length>0) {
              videoElem.files.sort((a, b) => b.size.compareTo(a.size));
              videoElem.files.removeWhere((element) => element.quality == "hls");
              // videoElem.files.forEach((element) {
              //   print('Q:'+element.quality+'  2SIZE::: '+element.size.toString());
              // });
              if (qualitySelected == "HD_1080p" && videoElem.files.length > 0 && (videoElem.files[ 0].quality != "hls")) {
                usedUrl = videoElem.files[0].link;
              } else
              if (qualitySelected == "HD_720p" && videoElem.files.length > 1 && (videoElem.files[ 1].quality != "hls")) {
                usedUrl = videoElem.files[1].link;
              } else
              if (qualitySelected == "SD_540p" && videoElem.files.length > 2 && (videoElem.files[ 2].quality != "hls")) {
                usedUrl = videoElem.files[2].link;
              } else
              if (qualitySelected == "SD_360p" && videoElem.files.length > 3 && (videoElem.files[ 3].quality != "hls")) {
                usedUrl = videoElem.files[3].link;
              } else
              if (qualitySelected == "SD_240p" && videoElem.files.length > 4 && (videoElem.files[ 4].quality != "hls")) {
                usedUrl = videoElem.files[4].link;
              } else if (videoElem.files[ videoElem.files.length-1].quality != "hls"){
                usedUrl = videoElem.files[ videoElem.files.length-1].link;
              }
            }
          }catch(e){
            print('GEBASZZZZZZZZZZZZZZZZZZZZZZZ 2');
            usedUrl = videoElem.url;
          }
          v.url = usedUrl;
          print('1 URL VEGLEGES :'+v.url);
          v.videoId = int.parse(videoElem.id);
          List<String> splitArray = videoElem.name.split("_");
          String meccs = "-";
          String idopont = "";
          if(splitArray.length>0){
            meccs = splitArray[splitArray.length-1].substring(0,splitArray[splitArray.length-1].lastIndexOf("."));
            idopont = splitArray[0].split("-")[0];

          }
          v.description = meccs /*+", "+idopont[0]+idopont[1]+idopont[2]+idopont[3]+"."+idopont[4]+idopont[5]+"."+idopont[6]+idopont[7]*/;

          v.username = "";
          if (splitArray.length >= 4) {
            v.username += getTypeTags(splitArray[2])+"    "+getNameTags(splitArray[2], myPlayers)+" ";
            v.description +=  "    "+getRatingTags(splitArray[2]);
          } else
          if (splitArray[1] == "GOAL") {
            v.username += "#gól";
            v.description +=  "    "+"0";
          } else {
            v.username += "#gólhelyzet";
            v.description +=  "    "+"0";
          }
          if (videoElem.thumbnail!=null && videoElem.thumbnail!=""){
            v.videoThumbnail = videoElem.thumbnail;
          }
          // if (videoModel.videos.length == 0) {
          //   v.url = "https://vod-progressive.akamaized.net/exp=1643449354~acl=%2Fvimeo-prod-skyfire-std-us%2F01%2F4183%2F15%2F395916870%2F1683265045.mp4~hmac=710f80fd18fcb5fca14d5e994bce49ac744e4b94da5660fe9c7fef758e2ae7d2/vimeo-prod-skyfire-std-us/01/4183/15/395916870/1683265045.mp4";
          // } else if (videoModel.videos.length == 1) {
          //   v.url = "https://player.vimeo.com/progressive_redirect/playback/395916870/rendition/720p/720p.mp4?loc=external&signature=a2f5cdf6e274b895b5d934679ceea5db9b1cd713667ffc54af200aee99e0f12a";
          //   } else if (videoModel.videos.length == 2) {
          //     v.url = "https://vod-progressive.akamaized.net/exp=1643412118~acl=%2Fvimeo-prod-skyfire-std-us%2F01%2F3336%2F15%2F391682566%2F1658608666.mp4~hmac=ff60e7f67a95af0bda174f11841e8903ef1d6605f87f1961409c8c5e6d56045d/vimeo-prod-skyfire-std-us/01/3336/15/391682566/1658608666.mp4";
          //   } else if (videoModel.videos.length == 3) {
          //     v.url = "https://vod-progressive.akamaized.net/exp=1643412199~acl=%2Fvimeo-prod-skyfire-std-us%2F01%2F3358%2F15%2F391790599%2F1659184628.mp4~hmac=b41207063597d8534d6539e38b3dd8e1fe3310a1297c8cc633a60bed0c857b02/vimeo-prod-skyfire-std-us/01/3358/15/391790599/1659184628.mp4";
          //   } else if (videoModel.videos.length == 4) {
          //     v.url = "https://vod-progressive.akamaized.net/exp=1643412255~acl=%2Fvimeo-prod-skyfire-std-us%2F01%2F3357%2F15%2F391789065%2F1659176798.mp4~hmac=2cfaf9a2a81ff90ec0fa96cdaeb28fa05ba4965e727c5d7eb7049b1b553557fe/vimeo-prod-skyfire-std-us/01/3357/15/391789065/1659176798.mp4";
          //   }

          print('ADDDDDDDED v videoElem.name '+videoElem.name.toString());
          v.videoElem = videoElem;

          videoModel.videos.add(v);
          print('4444444 add '+v.url.toString());

        }
        i++;
      }
      print('GETVIDEOS IDOMERES 3 '+DateTime.now().toString());
      print('ppp filterids SET '+filteredIds.length.toString());
      await SharedPreferencesHelper.setFilteredIds(filteredIds);
      if (callBackForFilteredLength!=null){
        print('callBackForFilteredLength 1 ');
        callBackForFilteredLength();
      }
      // SharedPreferencesHelper.getFilteredIds().then((v) {
      //
      //   print('ppp filterids SETTED '+filteredIds.length.toString());
      //
      // });
      // print('ppp SharedPreferencesHelper.setFilteredIds ssdsd '+filteredIds.length.toString());
      if (kem) {
        if (page > 1) {
          videosData.value.videos.addAll(videoModel.videos);
        } else {
          videosData.value = null;
          videosData.notifyListeners();
          videosData.value = videoModel;
        }
        videosData.notifyListeners();
      }
      print('GETVIDEOS IDOMERES END '+DateTime.now().toString());
      return videosData.value;
    } else {
      print('333333 BR videos ' + response.statusCode.toString());
      throw Exception(response.statusCode.toString()+'<statuscode');
    }

  } on TimeoutException catch (_) {
    log('Timeout??? ');
    throw Exception('Timeout');
    // A timeout occurred.
  } on Exception catch (_) {
    log('Exception?????'+_.toString());
    throw Exception(_.toString());
    // A timeout occurred.
  } catch (exception){
    log('SEVERHIBAAA');
    log('SEVERHIBAAA:'+exception.toString());
    throw Exception(exception.toString());
  }


  return null;


}


Map<String, String> myTypes = {'g': 'gól',
  'h': 'helyzet',
  'c': 'csel/szerelés',
  'v': 'védés',
  'e': 'elemzésre',
  'o': 'oktatóvideó'};
String getTypeTags(String tagInfo) {
  String description = " ";

  description = "";

  String tags = "";

    if (tagInfo.length >= 9) {
      String elsoT = tagInfo.substring(0, 1);
      if (elsoT != "0") {
        tags=tags+"#"+myTypes[elsoT]+"  ";
      }
      String masodikT = tagInfo.substring(1,2);
      if (masodikT != "0") {
        tags=tags+"#"+myTypes[masodikT]+"  ";
      }

    }
  if (tags=="") {
    tags += "#type";
  }
  description +=tags;
  return description;
}
String getNameTags(String tagInfo,Map<String, MyPlayerElem> myPlayers) {
  String description = " ";

  description = "";

  String tags = "";

    if (tagInfo.length >= 9) {
      String elsoP = tagInfo.substring(2,5);
      if (elsoP != "000" && myPlayers!=null && myPlayers.containsKey(elsoP)) {
        tags=tags+"#"+myPlayers[elsoP].name+"  ";
      }
      String masodikP = tagInfo.substring(5,8);
      if (masodikP != "000" &&myPlayers!=null && myPlayers.containsKey(masodikP)) {
        tags=tags+"#"+myPlayers[masodikP].name+"  ";
      }
    }
  if (tags=="") {
    tags += "#player";
  }
  description +=tags;
  return description;
}
String getRatingTags(String tagInfo) {
  String description = " ";

  description = "";

  String tags = "";

    if (tagInfo.length >= 9) {

      String r = tagInfo.substring(8,9);
      return r;
    }
  return "0";
}

Future<VideoModel> getFollowingUserVideos(page) async {
  print("getFollowingUserVideos");
  Uri uri = Helper.getUri('get-videos');
  uri = uri.replace(queryParameters: {
    "page_size": '10',
    "page": page.toString(),
    "login_id": userRepo.currentUser.value.userId == null ? '0' : userRepo.currentUser.value.userId.toString(),
    "following": '1',
  });
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'USER': '${GlobalConfiguration().get('api_user')}',
      'KEY': '${GlobalConfiguration().get('api_key')}',
    };
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      print("json.decode(response.body)['data']");
      print(json.encode(VideoModel.fromJson(json.decode(response.body)['data']).videos));
      if (jsonData['status'] == 'success') {
        if (page > 1) {
          followingUsersVideoData.value.videos.addAll(VideoModel.fromJson(json.decode(response.body)['data']).videos);
        } else {
          followingUsersVideoData.value = null;
          followingUsersVideoData.notifyListeners();
          followingUsersVideoData.value = VideoModel.fromJson(json.decode(response.body)['data']);
        }
        followingUsersVideoData.notifyListeners();
        return followingUsersVideoData.value;
      }
    }
  } catch (e) {
    print("ERRORSSS: " + e.toString());
    VideoModel.fromJson({});
  }
}

Future<bool> updateLike(int videoId) async {
  Uri uri = Helper.getUri('video-like');
  uri = uri.replace(queryParameters: {
    "user_id": userRepo.currentUser.value.userId.toString(),
    "app_token": userRepo.currentUser.value.token,
    "video_id": videoId.toString()
  });

  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'USER': '${GlobalConfiguration().get('api_user')}',
      'KEY': '${GlobalConfiguration().get('api_key')}',
    };
    var resposne = await http.post(uri, headers: headers);
    return true;
  } catch (e) {
    print(e.toString());
    return false;
  }
}

Future<String> followUnfollowUser(Video videoObj) async {
  print("followUnfollowUser video repo");
  Uri url = Helper.getUri('follow-unfollow-user');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'USER': '${GlobalConfiguration().get('api_user')}',
    'KEY': '${GlobalConfiguration().get('api_key')}',
  };
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: headers,
    body: json.encode({
      "follow_by": userRepo.currentUser.value.userId.toString(),
      "follow_to": videoObj.userId.toString(),
      "app_token": userRepo.currentUser.value.token
    }),
  );

  if (response.statusCode == 200) {
    print(json.encode(json.decode(response.body)));
    return json.encode(json.decode(response.body));
  } else {
    throw new Exception(response.body);
  }
}

Future<String> submitReport(Video videoObj, selectedType, description) async {
  Uri url = Helper.getUri('submit-report');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'USER': '${GlobalConfiguration().get('api_user')}',
    'KEY': '${GlobalConfiguration().get('api_key')}',
  };
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: headers,
    body: json.encode({
      "user_id": userRepo.currentUser.value.userId.toString(),
      "video_id": videoObj.videoId.toString(),
      "app_token": userRepo.currentUser.value.token,
      "type": selectedType,
      "description": description
    }),
  );

  if (response.statusCode == 200) {
    print(json.encode(json.decode(response.body)));
    return json.encode(json.decode(response.body));
  } else {
    throw new Exception(response.body);
  }
}

Future<String> incVideoViews(Video videoObj) async {
  String userVideoId = userRepo.currentUser.value.userId != null ? userRepo.currentUser.value.userId.toString() : "";
  String userVideo = videoObj.videoId.toString() + userVideoId;
  if (!watchedVideos.value.contains(userVideo)) {
    watchedVideos.value.add(userVideo);
    watchedVideos.notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uniqueToken = await prefs.getString("unique_id");
    print("uniqueToken $uniqueToken");
    Uri url = Helper.getUri('video-views');
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'USER': '${GlobalConfiguration().get('api_user')}',
      'KEY': '${GlobalConfiguration().get('api_key')}',
    };
    Map<String, dynamic> data = {};
    data["unique_token"] = uniqueToken;
    if (userRepo.currentUser.value.userId != null) {
      data["user_id"] = userRepo.currentUser.value.userId;
    }

    data["video_id"] = videoObj.videoId.toString();
    print("body Data");
    print(data);
    final client = new http.Client();
    final response = await client.post(
      url,
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      print(json.decode(response.body).toString());
      if (!homeCon.value.showFollowingPage.value) {
        videosData.value.videos.elementAt(homeCon.value.swiperIndex).totalViews = json.decode(response.body)['total_views'];
      } else {
        followingUsersVideoData.value.videos.elementAt(homeCon.value.swiperIndex2).totalViews = json.decode(response.body)['total_views'];
      }
      return json.encode(
        json.decode(response.body),
      );
    } else {
      throw new Exception(response.body);
    }
  }
}

Future<String> getWatermark() async {
  Uri uri = Helper.getUri('get-watermark');
  String watermark = "";
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'USER': '${GlobalConfiguration().get('api_user')}',
      'KEY': '${GlobalConfiguration().get('api_key')}',
    };
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      print("Watermark $jsonData");
      if (jsonData['status'] == 'success') {
        watermark = jsonData['watermark'];
      }
    }
  } catch (e) {
    print(e.toString());
  }
  return watermark;
}
