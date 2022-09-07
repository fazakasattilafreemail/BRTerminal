import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../helpers/helper.dart';
import '../models/hash_videos_model.dart';
import '../repositories/user_repository.dart' as userRepo;

ValueNotifier<HashVideosModel> hashData = new ValueNotifier(HashVideosModel());

Future<HashVideosModel> getData(page, searchKeyword) async {
  print("hash-tag-videos");
  print(userRepo.currentUser.value.userId.toString());
  print(userRepo.currentUser.value.token);
  Uri uri = Helper.getUri('hash-tag-videos');
  uri = uri.replace(queryParameters: {
    'user_id': userRepo.currentUser.value.userId.toString(),
    "app_token": userRepo.currentUser.value.token,
    'page': page.toString(),
    'search': searchKeyword
  });
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'USER': '${GlobalConfiguration().get('api_user')}',
      'KEY': '${GlobalConfiguration().get('api_key')}',
    };
    var response = await http.post(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        if (page > 1) {
          hashData.value.videos.addAll(
              HashVideosModel.fromJson(json.decode(response.body)['data'])
                  .videos);
        } else {
          hashData.value =
              HashVideosModel.fromJson(json.decode(response.body)['data']);
        }
        hashData.notifyListeners();
        return hashData.value;
      }
    }
  } catch (e) {
    print(e.toString());
    HashVideosModel.fromJson({});
  }
}

Future<String> getAds() async {
  Uri uri = Helper.getUri('get-ads');
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'USER': '${GlobalConfiguration().get('api_user')}',
      'KEY': '${GlobalConfiguration().get('api_key')}',
    };
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        return json.encode(json.decode(response.body));
      }
    }
  } catch (e) {
    print(e.toString());
    HashVideosModel.fromJson({});
  }
}
