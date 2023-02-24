import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;
import 'package:app01/model/openid_model.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isBusy = false;
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  String? _refreshToken;
  String? _accessToken;
  String? _idToken;
  UserInfo? _userInfo;

  final TextEditingController _authorizationCodeTextController =
      TextEditingController();
  final TextEditingController _accessTokenTextController =
      TextEditingController();
  final TextEditingController _accessTokenExpirationTextController =
      TextEditingController();

  final TextEditingController _idTokenTextController = TextEditingController();
  final TextEditingController _refreshTokenTextController =
      TextEditingController();

  final OpenIDConfiguration oic = OpenIDConfiguration(
      'myclient', 'https://iamcoll.bancaetica.it/auth/realms/TestQueryDesk');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Visibility(
                  visible: _isBusy,
                  child: const LinearProgressIndicator(),
                ),
                const SizedBox(height: 2),
                ElevatedButton(
                  child: const Text('Sign in with auto code exchange'),
                  onPressed: () => _signInWithAutoCodeExchange(),
                ),
                if (Platform.isIOS || Platform.isMacOS)
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ElevatedButton(
                      child: const Text(
                        'Sign in with auto code exchange using ephemeral session',
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () => _signInWithAutoCodeExchange(
                          preferEphemeralSession: true),
                    ),
                  ),
                ElevatedButton(
                  onPressed: _refreshToken != null ? _refresh : null,
                  child: const Text('Refresh token'),
                ),
                const SizedBox(height: 2),
                ElevatedButton(
                  onPressed: _idToken != null
                      ? () async {
                          await _endSession();
                        }
                      : null,
                  child: const Text('End session'),
                ),
                const SizedBox(height: 2),
                ElevatedButton(
                  onPressed: _idToken != null
                      ? () async {
                          await _oauthUserInfo();
                        }
                      : null,
                  child: const Text('User info'),
                ),
                const SizedBox(height: 2),
                const Text('authorization code'),
                TextField(
                  controller: _authorizationCodeTextController,
                ),
                const Text('access token'),
                TextField(
                  controller: _accessTokenTextController,
                ),
                const Text('access token expiration'),
                TextField(
                  controller: _accessTokenExpirationTextController,
                ),
                const Text('id token'),
                TextField(
                  controller: _idTokenTextController,
                ),
                const Text('refresh token'),
                TextField(
                  controller: _refreshTokenTextController,
                ),
                const Text('user info'),
                if (_userInfo != null) Text(_userInfo!.email!)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _endSession() async {
    try {
      _setBusyState();
      await _appAuth.endSession(EndSessionRequest(
          idTokenHint: _idToken,
          postLogoutRedirectUrl: oic.postLogoutRedirectUrl,
          serviceConfiguration: oic.serviceConfiguration));
      _clearSessionInfo();
    } catch (_) {}
    _clearBusyState();
  }

  void _clearSessionInfo() {
    setState(() {
      _authorizationCodeTextController.clear();
      _accessToken = null;
      _accessTokenTextController.clear();
      _idToken = null;
      _idTokenTextController.clear();
      _refreshToken = null;
      _refreshTokenTextController.clear();
      _accessTokenExpirationTextController.clear();
      _userInfo = null;
    });
  }

  Future<void> _refresh() async {
    try {
      _setBusyState();
      final TokenResponse? result = await _appAuth.token(TokenRequest(
          oic.clientId, oic.redirectUrl,
          refreshToken: _refreshToken, issuer: oic.issuer, scopes: oic.scopes));
      _processTokenResponse(result);
    } catch (_) {
      _clearBusyState();
    }
  }

  Future<void> _signInWithAutoCodeExchange(
      {bool preferEphemeralSession = false}) async {
    try {
      _setBusyState();

      // show that we can also explicitly specify the endpoints rather than getting from the details from the discovery document
      final AuthorizationTokenResponse? result =
          await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          oic.clientId,
          oic.redirectUrl,
          serviceConfiguration: oic.serviceConfiguration,
          scopes: oic.scopes,
          preferEphemeralSession: preferEphemeralSession,
        ),
      );

      // this code block demonstrates passing in values for the prompt parameter. in this case it prompts the user login even if they have already signed in. the list of supported values depends on the identity provider
      // final AuthorizationTokenResponse result = await _appAuth.authorizeAndExchangeCode(
      //   AuthorizationTokenRequest(_clientId, _redirectUrl,
      //       serviceConfiguration: _serviceConfiguration,
      //       scopes: _scopes,
      //       promptValues: ['login']),
      // );

      if (result != null) {
        _processAuthTokenResponse(result);
      }
    } catch (_) {
      _clearBusyState();
    }
  }

  void _clearBusyState() {
    setState(() {
      _isBusy = false;
    });
  }

  void _setBusyState() {
    setState(() {
      _isBusy = true;
    });
  }

  void _processAuthTokenResponse(AuthorizationTokenResponse response) {
    _clearBusyState();
    setState(() {
      _accessToken = _accessTokenTextController.text = response.accessToken!;
      _idToken = _idTokenTextController.text = response.idToken!;
      _refreshToken = _refreshTokenTextController.text = response.refreshToken!;
      _accessTokenExpirationTextController.text = response.accessTokenExpirationDateTime!.toIso8601String();
    });
  }

  void _processTokenResponse(TokenResponse? response) {
    _clearBusyState();
    setState(() {
      _accessToken = _accessTokenTextController.text = response!.accessToken!;
      _idToken = _idTokenTextController.text = response.idToken!;
      _refreshToken = _refreshTokenTextController.text = response.refreshToken!;
      _accessTokenExpirationTextController.text = response.accessTokenExpirationDateTime!.toIso8601String();
    });
  }

  Future<void> _oauthUserInfo() async {
    _setBusyState();

    final http.Response httpResponse = await http.get(
        Uri.parse(oic.userInfoEndpoint),
        headers: <String, String>{'Authorization': 'Bearer $_accessToken'});

    setState(() {
      if (httpResponse.statusCode == 200) {
        _userInfo = UserInfo.fromJson(jsonDecode(httpResponse.body));
      } else {
        _userInfo = null;
      }

      _clearBusyState();
    });
  }
}
