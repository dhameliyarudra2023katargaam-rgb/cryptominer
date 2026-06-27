class AuthModel {
  bool? isSuccess;
  String? status;
  String? message;
  AuthData? data;

  AuthModel({this.isSuccess, this.status, this.message, this.data});

  AuthModel.fromJson(Map<String, dynamic> json) {
    if (json['success'] == false || 
        json['isSuccess'] == false || 
        json['status']?.toString().toLowerCase() == 'fail' || 
        json['status']?.toString().toLowerCase() == 'error') {
      isSuccess = false;
    } else {
      isSuccess = json['success'] == true || 
                  json['isSuccess'] == true || 
                  json['status']?.toString().toLowerCase() == 'success' ||
                  (json['accessToken'] != null || 
                   json['token'] != null || 
                   (json['message'] != null && 
                    !json['message'].toString().toLowerCase().contains('fail') && 
                    !json['message'].toString().toLowerCase().contains('error')));
    }
    status = json['status']?.toString();
    message = json['message'];
    if (json['data'] != null) {
      data = AuthData.fromJson(json['data']);
    } else if (json['accessToken'] != null || json['token'] != null || json['user'] != null) {
      data = AuthData.fromJson(json);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['success'] = isSuccess;
    dataMap['status'] = status;
    dataMap['message'] = message;
    if (data != null) {
      dataMap['data'] = data!.toJson();
    }
    return dataMap;
  }
}

class AuthData {
  String? token;
  String? refreshToken;
  UserModel? user;

  AuthData({this.token, this.refreshToken, this.user});

  AuthData.fromJson(Map<String, dynamic> json) {
    if (json['tokens'] != null && json['tokens']['access'] != null) {
      token = json['tokens']['access']['token']?.toString();
    } else {
      token = json['token']?.toString() ?? json['accessToken']?.toString();
    }
    if (json['tokens'] != null && json['tokens']['refresh'] != null) {
      refreshToken = json['tokens']['refresh']['token']?.toString();
    } else {
      refreshToken = json['refreshToken']?.toString();
    }
    user = json['user'] != null
        ? UserModel.fromJson(json['user'])
        : (json['email'] != null || json['_id'] != null ? UserModel.fromJson(json) : null);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['token'] = token;
    dataMap['refreshToken'] = refreshToken;
    if (user != null) {
      dataMap['user'] = user!.toJson();
    }
    return dataMap;
  }
}

class UserModel {
  String? sId;
  String? name;
  String? email;
  String? birthDate;
  bool? isMpinSet;
  String? createdAt;
  String? updatedAt;
  String? role;
  String? country;
  String? referralCode;
  String? userId;

  UserModel({
    this.sId,
    this.name,
    this.email,
    this.birthDate,
    this.isMpinSet,
    this.createdAt,
    this.updatedAt,
    this.role,
    this.country,
    this.referralCode,
    this.userId,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    birthDate = json['birthDate'] ?? json['birthdate'];
    isMpinSet = json['isMpinSet'] ?? json['hasMpin'] ?? json['isMpin'] ?? (json['mpin'] != null && json['mpin'].toString().isNotEmpty) ?? false;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    role = json['role']?.toString();
    country = json['country']?.toString();
    referralCode = json['referralCode']?.toString();
    userId = json['userId']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['_id'] = sId;
    dataMap['name'] = name;
    dataMap['email'] = email;
    dataMap['birthDate'] = birthDate;
    dataMap['isMpinSet'] = isMpinSet;
    dataMap['createdAt'] = createdAt;
    dataMap['updatedAt'] = updatedAt;
    dataMap['role'] = role;
    dataMap['country'] = country;
    dataMap['referralCode'] = referralCode;
    dataMap['userId'] = userId;
    return dataMap;
  }
}
