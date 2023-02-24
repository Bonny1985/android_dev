import 'dart:async';
import 'dart:convert';

import 'package:app01/model/openid_model.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:http/http.dart' as http;

/*
  Map<String, String> toMap() => {
        "token": token,
        "token_type_hint": tokenType == TokenType.accessToken
            ? "access_token"
            : "refresh_token",
      };
    try {
      await httpRetry(
        () => http.post(
          Uri.parse(request.configuration.revocationEndpoint!),
          body: request.toMap(),
          headers: {
            "Authorization": "Bearer ${request.token}",
          },
        ),
      );
*/

class AuthService {
  final logger = SimpleLogger();

  final StreamController<LoginState> _onAuthStateChange =
      StreamController.broadcast();

  Stream<LoginState> get onAuthStateChange => _onAuthStateChange.stream;

  final OpenIDConfiguration oic = OpenIDConfiguration(
      'myclient', '{baseUrl}/auth/realms/{realm}');

  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  Future<void> logIn() async {
    logger.info("Start login ...");

    final AuthorizationTokenResponse? result =
        await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(oic.clientId, oic.redirectUrl,
          serviceConfiguration: oic.serviceConfiguration,
          scopes: oic.scopes,
          preferEphemeralSession: false),
    );

    logger.info("Login end");

    if (result != null) {
      TokenInfo t = TokenInfo(result.accessToken, result.idToken,
          result.refreshToken, result.accessTokenExpirationDateTime);

      UserInfo? u = await userInfo(t.accessToken!);

      _onAuthStateChange.add(LoginState.logIn(true, t, u));
    } else {
      _onAuthStateChange.add(LoginState(false));
    }
  }

  Future<void> logOut(String idToken) async {
    logger.info("Start logout ...");

    await _appAuth.endSession(EndSessionRequest(
        idTokenHint: idToken,
        postLogoutRedirectUrl: oic.postLogoutRedirectUrl,
        serviceConfiguration: oic.serviceConfiguration));

    logger.info("Logout end");

    _onAuthStateChange.add(LoginState(false));
  }

  Future<UserInfo?> userInfo(String accessToken) async {
    logger.info("Start userInfo ...");
    final http.Response httpResponse = await http.get(
        Uri.parse(oic.userInfoEndpoint),
        headers: <String, String>{'Authorization': 'Bearer $accessToken'});
    logger.info("UserInfo end code = ${httpResponse.statusCode}");
    if (httpResponse.statusCode == 200) {
      return UserInfo.fromJson(jsonDecode(httpResponse.body));
    }
    return null;
  }

  Future<TokenInfo> refresh(String refreshToken) async {
    logger.info("Start refresh ...");

    final TokenResponse? result = await _appAuth.token(TokenRequest(
        oic.clientId, oic.redirectUrl,
        refreshToken: refreshToken, issuer: oic.issuer, scopes: oic.scopes));

    logger.info("refresh end");

    return TokenInfo(result?.accessToken, result?.idToken, result?.refreshToken,
        result?.accessTokenExpirationDateTime);
  }
}
