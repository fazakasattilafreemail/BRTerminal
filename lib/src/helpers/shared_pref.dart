import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPreferencesHelper {
  ///
  /// Instantiation of the SharedPreferences library
  ///
  static final String _kLastScreen= "lastScreen";
  static final String _kToken = "token";
  static final String _kUserId = "userid";
  static final String _kRoleId = "roleid";
  static final String _kFilter = "filter";
  static final String _kQuality = "quality";
  static final String _kRangeStart = "rangestart";
  static final String _kSelectedProfile = "selectedprofile";
  static final String _kRangeEnd = "rangeend";
  static final String _kLastVideosResponse = "lastvideosresponse";
  static final String _kShowMerge = "show_merge";
  static final String _kNeedPIN = "need_pin";
  static final String _kVideoMapForRead = "videoMapForRead";
  static final String _kVideoMap = "videoMap";
  static final String _kFilterMatches = "filtermatches";
  static final String _kDeepLinkIds = "deeplinkids";
  static final String _kDeepLink = "deeplink";
  static final String _kDeepLinkProfile = "deeplinkprofile";
  static final String _kFilterNames = "filternames";
  static final String _kFilterTeams = "filterteams";
  static final String _kFilteredIds = "filteredids";
  static final String _kFilterTypes = "filtertypes";
  static final String _kFilterRating = "filterrating";
  static final String _kLanguageCode = "language";

  /// ------------------------------------------------------------
  /// Method that returns the user language code, 'en' if not set
  /// ------------------------------------------------------------
  static Future<String> getLanguageCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_kLanguageCode) ?? 'en';
  }

  /// ----------------------------------------------------------
  /// Method that saves the user language code
  /// ----------------------------------------------------------
  static Future<bool> setLanguageCode(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_kLanguageCode, value);
  }
  static Future<String> getLastScreen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_kLastScreen) ?? '';
  }

  /// ----------------------------------------------------------
  /// Method that saves the user decision on sorting order
  /// ----------------------------------------------------------
  static Future<bool> setLastScreen(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_kLastScreen, value);
  }
  static Future<String> getDeepLinkProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_kDeepLinkProfile) ?? '';
  }

  /// ----------------------------------------------------------
  /// Method that saves the user decision on sorting order
  /// ----------------------------------------------------------
  static Future<bool> setDeepLinkProfile(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_kDeepLinkProfile, value);
  }

  /// ------------------------------------------------------------
  /// Method that returns the user decision on sorting order
  /// ------------------------------------------------------------
  static Future<String> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_kToken) ?? '';
  }

  /// ------------------------------------------------------------
  /// Method that returns the user decision on sorting order
  /// ------------------------------------------------------------
  static Future<List<String>> getTokenAndUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> st = new List<String>();
    st.add( prefs.getString(_kToken) ?? '');
    st.add( prefs.getString(_kUserId) ?? '');
    return st;
  }

  /// ----------------------------------------------------------
  /// Method that saves the user decision on sorting order
  /// ----------------------------------------------------------
  static Future<bool> setToken(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_kToken, value);
  }
  static Future<String> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_kUserId) ?? '';
  }
  static Future<bool> setUserId(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_kUserId, value==null?'':value.toString());
  }

  static Future<String> getRoleId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_kRoleId) ?? '';
  }
  static Future<bool> setRoleId(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_kRoleId, value==null?'':value.toString());
  }

  static Future<String> getFilter() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_kFilter) ?? '';
  }
  static Future<bool> setFilter(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_kFilter, value);
  }
  static Future<String> getQuality() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_kQuality) ?? 'HD_720p';
  }
  static Future<bool> setQuality(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_kQuality, value);
  }
  static Future<String> getRangeStart() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_kRangeStart) ?? '';
  }
  static Future<bool> setRangeStart(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_kRangeStart, value);
  }
  static Future<String> getRangeEnd() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_kRangeEnd) ?? '';
  }
  static Future<bool> setSelectedProfile(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_kSelectedProfile, value);
  }
  static Future<String> getSelectedProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_kSelectedProfile) ?? '-1';
  }
  static Future<bool> setDeepLink(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_kDeepLink, value);
  }
  static Future<String> getDeepLink() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_kDeepLink) ?? "";
  }
  static Future<bool> setRangeEnd(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_kRangeEnd, value);
  }
  static Future<String> getLastVideosResponse() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_kLastVideosResponse) ?? '';
  }
  static Future<bool> setLastVideosResponse(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_kLastVideosResponse, value);
  }
  static Future<bool> getShowMergeDialog() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_kShowMerge) ?? false;
  }
  static Future<bool> setShowMerge(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setBool(_kShowMerge, value);
  }
  static Future<bool> getNeedPIN() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_kNeedPIN) ?? true;
  }
  static Future<bool> setNeedPIN(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setBool(_kNeedPIN, value);
  }

  static Future< Map<String, dynamic>> getVideoMap() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String videoMapJson = prefs.getString(_kVideoMap) ?? '';
    if (videoMapJson==null || videoMapJson == ''){
      Map<String, dynamic> videoMap= new Map<String,dynamic>();
      return videoMap;
    } else {
      Map<String, dynamic> videoMap= json.decode(videoMapJson);
      return videoMap;
    }

  }

  static Future<bool> setVideoMap(Map<String, dynamic> value) async {
    String videoMapJson= json.encode(value);
    print('jsooooon::::'+videoMapJson);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print('setVideoMap1::::');

    return prefs.setString(_kVideoMap, videoMapJson);
  }
  static Future< Map<String, dynamic>> getVideoMapForRead() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String videoMapJson = prefs.getString(_kVideoMapForRead) ?? '';
    if (videoMapJson==null || videoMapJson == ''){
      Map<String, dynamic> videoMap= new Map<String,dynamic>();
      return videoMap;
    } else {
      Map<String, dynamic> videoMap= json.decode(videoMapJson);
      return videoMap;
    }

  }

  static Future<bool> setVideoMapForRead(Map<String, dynamic> value) async {
    String videoMapJson= json.encode(value);
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_kVideoMapForRead, videoMapJson);
  }
  static Future< List<String>> getFilterMatches() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> l = prefs.getStringList(_kFilterMatches) ?? <String>[];
    return l;

  }

  static Future<bool> setFilterMatches( List<String> value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setStringList(_kFilterMatches, value);
  }
  static Future< List<String>> getDeepLinkIds() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> l = await prefs.getStringList(_kDeepLinkIds) ?? <String>[];
    return l;

  }

  static Future<bool> setDeepLinkIds( List<String> value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return await prefs.setStringList(_kDeepLinkIds, value);
  }
  static Future< List<String>> getFilterNames() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> l = prefs.getStringList(_kFilterNames) ??  <String>[];
    return l;

  }

  static Future<bool> setFilterNames( List<String> value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setStringList(_kFilterNames, value);
  }
  static Future< List<String>> getFilterTeams() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> l = prefs.getStringList(_kFilterTeams) ??  <String>[];
    return l;

  }

  static Future<bool> setFilterTeams( List<String> value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setStringList(_kFilterTeams, value);
  }
  static Future< List<String>> getFilteredIds() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> l = prefs.getStringList(_kFilteredIds) ??  <String>[];
    return l;

  }

  static Future<bool> setFilteredIds( List<String> value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setStringList(_kFilteredIds, value);
  }
  static Future< List<String>> getFilterTypes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> l = prefs.getStringList(_kFilterTypes) ??  new List<String>();
    return l;

  }

  static Future<bool> setFilterTypes( List<String> value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setStringList(_kFilterTypes, value);
  }
  static Future< List<String>> getFilterRating() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> l = prefs.getStringList(_kFilterRating) ??  <String>['1','1','1','1','1'];
    return l;

  }

  static Future<bool> setFilterRating( List<String> value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setStringList(_kFilterRating, value);
  }
}