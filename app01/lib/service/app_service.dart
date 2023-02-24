import 'dart:async';
import 'dart:convert';
import 'package:app01/model/openid_model.dart';
import 'package:app01/service/auth_service.dart';
import 'package:app01/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:simple_logger/simple_logger.dart';

// ignore: non_constant_identifier_names
String LOGIN_KEY = "LOGIN_KEY";
// ignore: non_constant_identifier_names
String ONBOARD_KEY = "ONBOARD_KEY";
// ignore: non_constant_identifier_names
String CREDENTIAL_KEY = "CREDENTIAL_KEY";
// ignore: non_constant_identifier_names
String USERINFO_KEY = "USERINFO_KEY";

class AppService with ChangeNotifier {
  final logger = SimpleLogger();
  late final FlutterSecureStorage secureStorage;

  bool _loginState = false;
  bool _initialized = false;
  bool _onboarding = false;
  TokenInfo? _tokenInfo;
  UserInfo? _userInfo;
  bool _sessioExpired = false;

  AppService(this.secureStorage);

  bool get loginState => _loginState;
  bool get initialized => _initialized;
  bool get onboarding => _onboarding;
  String? get idToken => _tokenInfo?.idToken;
  String? get accessToken => _tokenInfo?.accessToken;
  String? get refreshToken => _tokenInfo?.refreshToken;
  UserInfo? get usetInfo => _userInfo;
  bool get sessioExpired => _sessioExpired;
  
  void setLoginState(LoginState loginState) {
    _loginState = loginState.state;

    secureStorage.write(key: LOGIN_KEY, value: boolToString(_loginState));
    if (_loginState) {
      _tokenInfo = loginState.tokenInfo;
      _userInfo = loginState.userInfo;
      if (_tokenInfo != null) {
        secureStorage.write(key: CREDENTIAL_KEY, value: _tokenInfo.toString());
      }
      if (_userInfo != null) {
        secureStorage.write(key: USERINFO_KEY, value: _userInfo.toString());
      }
    } else {
      _expired();
    }

    logger.info("setLoginState -> ${toString()}");
    notifyListeners();
  }

/*
  set loginState(bool state) {
    secureStorage.write(key: LOGIN_KEY, value: boolToString(state));
    _loginState = state;
    if (!state) {
      // user click on logOut
      _expired();
      //  logout(Credential.fromJson(_cred));
    }
    notifyListeners();
  }
*/
  set initialized(bool value) {
    _initialized = value;
    notifyListeners();
  }

  set onboarding(bool value) {
    secureStorage.write(key: ONBOARD_KEY, value: boolToString(value));
    _onboarding = value;
    notifyListeners();
  }

  void _expired() {
    _loginState = false;
    _tokenInfo = null;
    _userInfo = null;
 // _sessioExpired = true;
    secureStorage.delete(key: LOGIN_KEY);
    secureStorage.delete(key: CREDENTIAL_KEY);
    secureStorage.delete(key: USERINFO_KEY);
  }

  Future<void> onAppStart(AuthService auth) async {

    _sessioExpired = false;
    _onboarding = isTrue(await secureStorage.read(key: ONBOARD_KEY));
    _loginState = isTrue(await secureStorage.read(key: LOGIN_KEY));

    if (_loginState) {
      String? json = await secureStorage.read(key: CREDENTIAL_KEY);
      if (json != null) {
        _tokenInfo = TokenInfo.fromJson(jsonDecode(json));
      }

      try {
        _tokenInfo = await auth.refresh(refreshToken!);
        secureStorage.write(key: CREDENTIAL_KEY, value: _tokenInfo.toString());
      } catch (e) {
        logger.shout("Refresh token failed: ${e.toString()}");
        _sessioExpired = true;
        setLoginState(LoginState(false));
      }

      json = await secureStorage.read(key: USERINFO_KEY);
      if (json != null) {
        _userInfo = UserInfo.fromJson(jsonDecode(json));
      }
    }

    //_sessioExpired = _onboarding && !_loginState;

    _initialized = true;
    logger.info("onAppStart -> ${toString()}");
    notifyListeners();
  }

  @override
  String toString() {
    const String unknown = "unknown";
    String? ti = _tokenInfo != null
        ? _tokenInfo?.accessTokenExpirationDateTime?.toIso8601String()
        : unknown;
    String? ui = _userInfo != null ? _userInfo?.preferredUsername : unknown;
    String now = DateTime.now().toLocal().toIso8601String();
    String? isExp = _tokenInfo?.isExpired().toString();
    return "AppService {sessioExpired=$sessioExpired, initialized=$_initialized, loginState=$_loginState, onboarding=$_onboarding,  user=$ui, dt_exp=$ti, now=$now, isExpired=$isExp}";
  }
}
