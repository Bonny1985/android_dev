import 'package:app01/service/app_service.dart';
import 'package:flutter/material.dart';
import 'package:app01/router/route_utils.dart';
import 'package:provider/provider.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appService = Provider.of<AppService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppPage.onBoarding.toTitle),
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Benvenuto"),
              ElevatedButton(
                onPressed: () {
                  appService.onboarding = true;
                },
                child: const Text("Continua"),
              )
            ]),
      ),
    );
  }
}
