// ignore: file_names
import 'dart:convert';
import 'package:flutter_appauth/flutter_appauth.dart';

class OpenIDConfiguration {
  /// myclient
  late final String _clientId;

  String get clientId => _clientId;

  /// https://iamcoll.bancaetica.it/auth/realms/TestQueryDesk
  late final String _issuer;

  String get issuer => _issuer;

  /// com.duendesoftware.demo:/oauthredirect
  late final String redirectUrl = 'com.duendesoftware.demo:/oauthredirect';
  
  final String postLogoutRedirectUrl = 'com.duendesoftware.demo:/';

  final List<String> scopes = <String>[
    'openid',
    'profile',
    'email',
    //'offline_access'
  ];

  late final String discoveryUrl = '$_issuer/.well-known/openid-configuration';
  late final String userInfoEndpoint = '$_issuer/protocol/openid-connect/userinfo';
  late final String authorizationEndpoint ='$_issuer/protocol/openid-connect/auth';
  late final String tokenEndpoint = '$_issuer/protocol/openid-connect/token';
  late final String endSessionEndpoint ='$_issuer/protocol/openid-connect/logout';

  ///https://auth0.com/docs/secure/tokens/refresh-tokens/revoke-refresh-tokens
  late final String revokeEndpoint = '$_issuer/protocol/openid-connect/revoke';

  ///http://localhost:8081/auth/realms/TestQueryDesk/clients-registrations/openid-connect
  late final String registrationEndpoint = '$_issuer/clients-registrations/openid-connect';

  OpenIDConfiguration(String clientId, issuer) {
    _clientId = clientId;
    _issuer = issuer;
  }

  @override
  String toString() {
    return "{clientId=$_clientId, issuer=$_issuer, redirectUrl=$redirectUrl, postLogoutRedirectUrl=$postLogoutRedirectUrl, userInfoEndpoint=$userInfoEndpoint}";
  }

  AuthorizationServiceConfiguration get serviceConfiguration =>
      AuthorizationServiceConfiguration(
          authorizationEndpoint: authorizationEndpoint,
          tokenEndpoint: tokenEndpoint,
          endSessionEndpoint: endSessionEndpoint);
}

class UserInfo {
  String? sub;
  bool? emailVerified;
  String? name;
  String? preferredUsername;
  String? givenName;
  String? familyName;
  String? email;

  UserInfo(
      {this.sub,
      this.emailVerified,
      this.name,
      this.preferredUsername,
      this.givenName,
      this.familyName,
      this.email});

  UserInfo.fromJson(Map<String, dynamic> json) {
    sub = json['sub'];
    emailVerified = json['email_verified'];
    name = json['name'];
    preferredUsername = json['preferred_username'];
    givenName = json['given_name'];
    familyName = json['family_name'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sub'] = sub;
    data['email_verified'] = emailVerified;
    data['name'] = name;
    data['preferred_username'] = preferredUsername;
    data['given_name'] = givenName;
    data['family_name'] = familyName;
    data['email'] = email;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class TokenInfo {
  String? accessToken;
  String? idToken;
  String? refreshToken;
  DateTime? accessTokenExpirationDateTime;

  TokenInfo(this.accessToken, this.idToken, this.refreshToken,
      this.accessTokenExpirationDateTime);

  bool isExpired(){
    return accessTokenExpirationDateTime != null
      ? DateTime.now().toUtc().isAfter(accessTokenExpirationDateTime!.toUtc())
      : true;
  }

  TokenInfo.fromJson(Map<String, dynamic> json) {
    //try {
      accessToken = json['accessToken'];
      idToken = json['idToken'];
      refreshToken = json['refreshToken'];
      int microsecondsSinceEpoch = json['accessTokenExpirationDateTime'];
      accessTokenExpirationDateTime =
          DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch);
    //} catch (e) {
    //  SimpleLogger().log(Level.WARNING, e.toString());
    //}
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['accessToken'] = accessToken;
    data['idToken'] = idToken;
    data['refreshToken'] = refreshToken;
    data['accessTokenExpirationDateTime'] =
        accessTokenExpirationDateTime?.microsecondsSinceEpoch;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class LoginState {
  late TokenInfo? tokenInfo;
  late bool state;
  UserInfo? userInfo;
  LoginState(this.state);
  LoginState.logIn(this.state, this.tokenInfo, this.userInfo);
  @override
  String toString() {
    return "LoginState {state=$state}";
  }
}
