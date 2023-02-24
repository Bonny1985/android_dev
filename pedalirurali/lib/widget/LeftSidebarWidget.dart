import 'package:pedalirurali/Constants.dart';
import 'package:pedalirurali/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pedalirurali/model/PostsFilter.dart';

class LeftSidebarWidget extends StatefulWidget {
  @override
  _LeftSidebarWidgetState createState() => _LeftSidebarWidgetState();
}

class _LeftSidebarWidgetState extends State<LeftSidebarWidget> {
  
  Widget headerBody = ListTile(
     leading: Image(image: AssetImage(ASSET_LOGO_HEADER)),
     title: Text(APP_NAME, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22)),
     subtitle: Text(APP_MOTO, style: TextStyle(color: Colors.black, fontSize: 14))
  );

  Widget _createHeader() {
    return DrawerHeader(
        // margin: EdgeInsets.zero,
        // padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: COLOR_PRIMARY,
          border: Border( bottom: BorderSide(color: COLOR_SECONDARY, width: 2.0))
        ),
        child: ListView(children: [headerBody]));
  }

  Widget _createDrawerItem({IconData icon, String text, GestureTapCallback onTap}) {
    
    Widget lt =   ListTile(
      leading: Icon(icon), 
      title: Text(text),
      onTap: onTap
    );

    return lt;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[
      _createHeader(),
     /* _createDrawerItem(icon: Icons.favorite, text: 'I miei preferiti',
          onTap: () => Utils.navigateTo(context, ROUTE_POSTS, PostsFilter.favorite(), null)
      ),*/
      _createDrawerItem(icon: Icons.shop,text: 'Vai allo shop', 
          onTap: () => Utils.launchURL(SHOP_URL)
      ),
      _createDrawerItem(icon: Icons.share,text: 'Seguici su Facebook', 
          onTap: () => Utils.launchURL(FACEBOOK_URL)
      ),
      Divider(),
      _createDrawerItem(icon: Icons.thumb_up,text: 'Valutazione App', 
          onTap: () => Utils.appReview()
      ),
      _createDrawerItem(icon: Icons.info,text: 'Informazioni', 
          onTap: () => Utils.launchURL(INFO_URL)
      ),
      _createDrawerItem(icon: Icons.security, text: 'Informativa sulla privacy', 
          onTap: () => Utils.launchURL(PRIVACY_URL)
      )
      //_createDrawerItem(icon: Icons.message,text: 'Contattaci',)
    ]));
  }

  Widget _getInfoDialog() {
    return AlertDialog(
      elevation: 1.0,
      title: Text("Informazioni"),
      shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BORDER_RADIUS)
      ),
     // contentPadding: const EdgeInsets.all(4),
     /* titlePadding: EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 20
      ),
      contentPadding: EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 20
      ),*/
      content: Text("Sometime,we learn very well,because we want to it."),
      actions: [
        FlatButton(
          child: Text("Valutaci"),
          onPressed: () {
            Utils.backToHome(context);
            Utils.appReview();
          },
        ),
        FlatButton(
          child: Text("Chiudi"),
          onPressed: () => Utils.backToHome(context)
        )
      ]
    );
  }
}
