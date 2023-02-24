import 'package:pedalirurali/model/Post.dart';
import 'package:pedalirurali/model/PostsFilter.dart';
import 'package:pedalirurali/provider/MetadataProvider.dart';
import 'package:pedalirurali/provider/PostProvider.dart';
import 'package:pedalirurali/provider/UserProvider.dart';
import 'package:pedalirurali/widget/HomeWidget.dart';
import 'package:flutter/material.dart';
import 'package:pedalirurali/Constants.dart';
import 'package:pedalirurali/widget/PostWidget.dart';
import 'package:pedalirurali/widget/PostsWidget.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //PostProvider().reset();
  PostProvider().init();
  MetadataProvider().init();
  UserProvider().init();
  runApp(_MyApp());
}

class _MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(
          primaryColor: COLOR_PRIMARY,
          accentColor: COLOR_SECONDARY,
          visualDensity: VisualDensity.adaptivePlatformDensity),
      //home: HomeWidget(),
      initialRoute: "/",
      onGenerateRoute: (settings) {
        StatefulWidget sw;
        switch (settings.name) {
          case "/":
            {
              sw = HomeWidget();
            }
            break;
          case ROUTE_POSTS:
            {
              sw = PostsWidget(filter: settings.arguments as PostsFilter);
            }
            break;
          case ROUTE_POST:
            {
              sw = PostWidget(post: settings.arguments as Post);
            }
            break;
          default:
            {
              //log("Unknown route: " + settings.name);
            }
            break;
        }

        return MaterialPageRoute(builder: (context) {
          return sw;
        });
      }
    );
  } 
}
