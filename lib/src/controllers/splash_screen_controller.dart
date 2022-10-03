
import 'package:Leuke/src/helpers/shared_pref.dart';
import 'package:Leuke/src/models/my_models.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../controllers/dashboard_controller.dart';
import '../repositories/video_repository.dart' as videoRepo;

import 'package:cloud_firestore/cloud_firestore.dart';
class SplashScreenController extends ControllerMVC {
  ValueNotifier<bool> processing = new ValueNotifier(true);
  DashboardController homeCon;
  String uniqueId;
  GlobalKey<ScaffoldState> scaffoldKey;
  IO.Socket socket;
  Map<String, dynamic> playersMapFromDbForRead = new Map<String, dynamic>();
  Map<String,MyPlayerElem> myPlayers;
  // String url = "${GlobalConfiguration().get('node_url')}";

  Map<String, dynamic> teamsMapFromDbForRead = new Map<String, dynamic>();

  Future<void> initializeVideos(String profilString) async {
    print('SPLASHHHHHHHHHHHHHHHHHHHHHHgetvideos1');
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    await SharedPreferencesHelper.setLastVideosResponse('');

    // String profilString= "1";
    String playersTableName = 'players_profil'+profilString;
    String teamsTableName = 'teams_profil'+profilString;
    // String playersTableName = 'playersszereda';
    if (profilString=='playersszereda'){
      playersTableName = 'playersszereda';
    }

    String myTeamsStringPrefix = "";
    if (playersTableName != 'playersszereda') {
      FirebaseFirestore.instance.collection(teamsTableName).get().then((
          QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((element) {
          setState(() {
            teamsMapFromDbForRead = element['teams'] as Map;
            teamsMapFromDbForRead.forEach((key, value) {
              myTeamsStringPrefix=myTeamsStringPrefix+teamsMapFromDbForRead[key]['name']+",";

            });
            if (myTeamsStringPrefix.length>1 && myTeamsStringPrefix[myTeamsStringPrefix.length-1]==","){
              myTeamsStringPrefix = myTeamsStringPrefix.substring(0, myTeamsStringPrefix.length-1);
            }
          });

          // SharedPreferencesHelper.setVideoMapForRead(videoMapFromDb);

        });
        // getPlayersFromDB(playersTableName, profilString);
        getPlayersFromDB(playersTableName, myTeamsStringPrefix);

      });
    } else {
      getPlayersFromDB(playersTableName, "FKCS2008,FKCS2009,FKCS2010,FKCS2011,FKCS2013,Nyaradszereda2009,Nyaradszereda2011,Nyaradszereda2013");
    }


  }

  void getPlayersFromDB(String playersTableName, String prefForSelProfil){

    FirebaseFirestore.instance.collection(playersTableName).get().then((QuerySnapshot querySnapshot) async {


      querySnapshot.docs.forEach((element) {


        setState(() {
          myPlayers = new Map<String, MyPlayerElem>();
          playersMapFromDbForRead = element['players'] as Map;
          myPlayers = new Map<String, MyPlayerElem>();
          playersMapFromDbForRead.forEach((key, value) {

            if (playersTableName == 'playersszereda') {
              if (!key.startsWith("1")) {
                myPlayers.putIfAbsent(
                    key, () =>
                    MyPlayerElem(playersMapFromDbForRead[key]['id'],
                        playersMapFromDbForRead[key]['name'],
                        key.substring(0, 1)));
              }
            } else {
              myPlayers.putIfAbsent(
                  key, () =>
                  MyPlayerElem(playersMapFromDbForRead[key]['id'],
                      playersMapFromDbForRead[key]['name'],
                      playersMapFromDbForRead[key]['team_id']));
            }

          });

        });

        // SharedPreferencesHelper.setVideoMapForRead(videoMapFromDb);

      });
      if (myPlayers!=null) {
        print('SPLASHHHHHHHHHHHHHHHHHHHHHH getVideos players');
        await videoRepo.homeCon.value.getVideos(myPlayers: myPlayers, selProfile:prefForSelProfil );
      } else {
        print('SPLASHHHHHHHHHHHHHHHHHHHHHH getVideos no players');
        await videoRepo.homeCon.value.getVideos( selProfile:prefForSelProfil);
      }
      print('SPLASHHHHHHHHHHHHHHHHHHHHHHgetvideos2');
      videoRepo.homeCon.notifyListeners();
    });
  }
  connectUserSocket() async {
    // print("connectUserSocket");
    // try {
    //   socket = IO.io(url, <String, dynamic>{
    //     'transports': ['websocket'],
    //     'autoConnect': true,
    //   });Play1
    //   socketRepo.clientSocket.value = socket;
    //   socketRepo.clientSocket.notifyListeners();
    //   socket.emit("user-id", userRepo.currentUser.value.userId);
    // } catch (e) {
    //   print("catch socket");
    //   print(e.toString());
    // }
  }

  Future<void> userUniqueId() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      uniqueId = (pref.getString('unique_id') == null)
          ? ""
          : pref.getString('unique_id');
      if (uniqueId == "") {
//        userRepo.userUniqueId().then((value) {
//          var jsonData = json.decode(value);
//          uniqueId = jsonData['unique_token'];
//        });
      }
    }
  }
}
