import 'package:app01/service/app_service.dart';
import 'package:app01/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:app01/router/route_utils.dart';
import 'package:provider/provider.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  bool _isBusy = false;
  bool _isSessionExp = false;

  @override
  void initState() {
    _isBusy = false;
    super.initState();
  }

  @override
  void dispose() {
    _isBusy = false;
    super.dispose();
  }

  void _clearBusyState() {
    setState(() {
     _isSessionExp = _isBusy = false;
    });
  }

  void _setBusyState() {
    setState(() {
      // al primo click nascondo testo
      _isSessionExp = false;
      _isBusy = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    setState(() {
      // se true il testo appare solo la prima volta
      // che si carica il widget
      _isSessionExp = Provider.of<AppService>(context/*, listen: false*/).sessioExpired;
    });

    return Scaffold(
        appBar: AppBar(
          title: Text(AppPage.login.toTitle),
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
              const SizedBox(height: 10),
              Visibility(
                visible: _isBusy,
                child: const CircularProgressIndicator(),
              ),
              const SizedBox(height: 20),
              if (_isSessionExp)const Text("Session scaduta"),
              const SizedBox(height: 10),
              ElevatedButton(
                  onPressed: () {
                    if (!_isBusy) {
                      _setBusyState();
                      authService
                          .logIn()
                          .then((value) => _clearBusyState())
                          .onError((error, stackTrace) => _clearBusyState());
                    }
                  },
                  child: const Text("Log in"))
            ])));
  }
}

/*
class LogInPage extends StatelessWidget {

  const LogInPage({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(APP_PAGE.login.toTitle),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {

            authService.logIn();
          },
          child: const Text(
            "Log in"
          ),
        ),
      ),
    );
  }
}
*/