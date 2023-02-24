import 'package:pedalirurali/Constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:pedalirurali/model/Post.dart';
import 'package:share/share.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class Utils {
  static final DateFormat formatter = DateFormat('dd/MM/yyyy');
  static final DateFormat formatter2 = DateFormat('d MMM yyyy');

  static String dateFormat(String d) {
    String rs = formatter2.format(DateTime.tryParse(d));
    if (rs != null) {
      rs = rs.toUpperCase();
      rs = rs.replaceFirst("JAN", "GEN")
             .replaceFirst("MAY", "MAG")
             .replaceFirst("JUN", "GIU")
             .replaceFirst("JUL", "LUG")
             .replaceFirst("AUG", "AGO")
             .replaceFirst("SEP", "SET")
             .replaceFirst("OCT", "OTT")
             .replaceFirst("DEC", "DIC");
    }
    return rs;
  }


  static void navigateTo(
      BuildContext context, String route, Object obj, Function onValue) {
    if (onValue != null)
      Navigator.pushNamed(context, route, arguments: obj)
          .then((value) => onValue(value));
    else
      Navigator.pushNamed(context, route, arguments: obj);
  }

  static void backToHome(context) {
    Navigator.pop(context);
  }

  static void appReview() async {
    StoreRedirect.redirect(androidAppId: APP_ANDROID_ID);
  }

  static Future<void> launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false
          //headers: <String, String>{'my_header_key': 'my_header_value'},
          );
    } else {
      throw 'Impossibile raggiungere la pagina $url';
    }
  }

  static void share(String text) {
    Share.share(text);
  }

  static void sharePost(Post post) {
    String text = "Ciao, ho trovato questo su Pedali Rurali: ";
    text = text + post.title + " " + post.link;
    share(text);
  }
}
