import 'dart:async';
import 'package:app01/model/openid_model.dart';
import 'package:app01/service/app_service.dart';
import 'package:app01/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app01/router/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:simple_logger/simple_logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  SimpleLogger().setLevel(
    Level.INFO,
    // Includes  caller info, but this is expensive.
    includeCallerInfo: true
  );
  runApp(MyApp(secureStorage: secureStorage));
}

class MyApp extends StatefulWidget {
  final FlutterSecureStorage secureStorage;
  const MyApp({Key? key, required this.secureStorage}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final logger = SimpleLogger();
  late AppService appService;
  late AuthService authService;
  late StreamSubscription<LoginState> authSubscription;

  @override
  void initState() {
    appService = AppService(widget.secureStorage);
    authService = AuthService();
    authSubscription = authService.onAuthStateChange.listen(onAuthStateChange);
    super.initState();
  }

  void onAuthStateChange(LoginState loginState) {
    logger.info("onAuthStateChange -> $loginState");
    appService.setLoginState(loginState);
  }

  @override
  void dispose() {
    authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppService>(create: (_) => appService),
        Provider<AppRouter>(create: (_) => AppRouter(appService)),
        Provider<AuthService>(create: (_) => authService),
      ],
      child: Builder(
        builder: (context) {
          final GoRouter goRouter =
              Provider.of<AppRouter>(context, listen: false).router;
          return MaterialApp.router(
            title: "Router App",
            routeInformationParser: goRouter.routeInformationParser,
            routerDelegate: goRouter.routerDelegate,
          );
        },
      ),
    );
  }
}
