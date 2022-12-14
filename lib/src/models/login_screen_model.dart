class LoginScreenModel {
  String status;
  LoginScreenData data;

  LoginScreenModel({this.data, this.status});

  factory LoginScreenModel.fromJson(Map<String, dynamic> json) {
    return LoginScreenModel(
      data: json['data'] != null ? LoginScreenData.fromJSON(json['data']) : null,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class LoginScreenData {
  int userId;
  String logo;
  String title;
  bool appleLogin;
  bool fbLogin;
  bool googleLogin;
  String description;
  String privacyPolicy;

  LoginScreenData();

  LoginScreenData.fromJSON(Map<String, dynamic> json) {
    try {
      logo = json['logo'];
      title = json['title'];
      appleLogin = json['appleLogin'] != null
          ? json['appleLogin'] == 1
              ? true
              : false
          : false;
      fbLogin = json['fbLogin'] != null
          ? json['fbLogin'] == 1
              ? true
              : false
          : false;
      googleLogin = json['googleLogin'] != null
          ? json['googleLogin'] == 1
              ? true
              : false
          : false;
      description = json['description'];
      privacyPolicy = json['privacyPolicy'];
    } catch (e) {
      print(e);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['logo'] = this.logo;
    data['title'] = this.title;
    data['fbLogin'] = this.fbLogin;
    data['googleLogin'] = this.googleLogin;
    data['description'] = this.description;
    data['privacyPolicy'] = this.privacyPolicy;

    return data;
  }

  Map toMap() {
    var data = new Map<String, dynamic>();
    data['logo'] = this.logo;
    data['title'] = this.title;
    data['fbLogin'] = this.fbLogin;
    data['googleLogin'] = this.googleLogin;
    data['description'] = this.description;
    data['privacyPolicy'] = this.privacyPolicy;

    return data;
  }
}
