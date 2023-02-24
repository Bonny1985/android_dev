import 'package:app01/service/app_service.dart';
import 'package:app01/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:app01/router/route_utils.dart';
import 'package:provider/provider.dart';
import 'package:simple_logger/simple_logger.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final logger = SimpleLogger();
  late AppService _appService;
  late AuthService _authService;

  @override
  void initState() {
    _appService = Provider.of<AppService>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);
    onStartUp();
    super.initState();
  }

  void onStartUp() async {
    await _appService.onAppStart(_authService);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppPage.splash.toTitle),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
