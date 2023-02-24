import 'package:app01/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:app01/router/route_utils.dart';
import 'package:provider/provider.dart';

import '../service/app_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({ Key? key }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);  
    final appService = Provider.of<AppService>(context);  
    String? email = appService.usetInfo?.email;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppPage.home.toTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (email!=null)Text(email),
            ElevatedButton(
              onPressed: () {
                authService.logOut(appService.idToken!);
              },
              child: const Text(
                "Log out"
              ),
            ),
           /* TextButton(
              onPressed: () {
                GoRouter.of(context).goNamed(APP_PAGE.error.toName, extra: "Erro from Home");
              },
              child: const Text(
                "Show Error"
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}