import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:pedalirurali/Constants.dart';
import 'package:pedalirurali/Utils.dart';
import 'package:pedalirurali/model/Metadata.dart';
import 'package:pedalirurali/model/Post.dart';
import 'package:pedalirurali/provider/MetadataProvider.dart';

class PostCardWidget extends StatefulWidget {
  final Post post;

  const PostCardWidget({Key key, @required this.post}) : super(key: key);

  @override
  _PostCardWidgetState createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<PostCardWidget> {
  @override
  Widget build(BuildContext context) {
    Widget w;
    switch (widget.post.type) {
      case PostTypes.events:
        w = EventCard(post: widget.post);
        break;
      case PostTypes.permanent:
        w = PermanentCard(post: widget.post);
        break;
      default:
        w = Container();
    }
    return w;
  }
}

class PermanentCard extends StatefulWidget {
    final Post post;
  const PermanentCard({Key key, @required this.post}) : super(key: key);

  @override
  _PermanentCardState createState() => _PermanentCardState();
}

class _PermanentCardState extends State<PermanentCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Post _post = widget.post;
    double iconSize = 16.0;

    final Widget _bbar = ButtonBar(
      alignment: MainAxisAlignment.end,
      //mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
            iconSize: iconSize,
            icon: Icon(Icons.share),
            color: Colors.grey,
            onPressed: () => Utils.sharePost(_post)),
        IconButton(
            iconSize: iconSize,
            icon: Icon(_post.getFavoriteIcon()),
            color: Colors.pink,
            onPressed: () => setState(() => _post.toogleFavorite()))
      ],
    );

    Widget img = Container(child: Image.network(_post.thumbnail, width: 130.0));

    Metadata loc = MetadataProvider().getSigneFromCache(MetadataTypes.locations, _post.locationId);

    Card c = Card(
      shadowColor: COLOR_SECONDARY,
      margin: EdgeInsets.only(top: 12, bottom: 0, left: 14, right: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: img,
            title: Text(_post.title, style: TextStyle(fontWeight: FontWeight.bold)),
            //subtitle: Text('Music by Julie Gable. Lyrics by Sidney Stein.'),
            //trailing: Icon(Icons.more_vert)
            //isThreeLine: true
          ),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: HtmlWidget(_post.excerpt,
                  webView: false, textStyle: TextStyle())),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(children: <Widget>[
                /*Expanded(
                    flex: 1,
                    child: Row(children: [
                      Icon(Icons.calendar_today,
                          size: 12, color: COLOR_SECONDARY),
                      Text(" " + _post.startDate)
                    ])),*/
                Expanded(
                    flex: 1,
                    child: Row(children: [
                      Icon(Icons.place, size: 12, color: COLOR_SECONDARY),
                      Text(' ' + loc.name)
                    ]))
              ])),
          _bbar
        ],
      ),
    );

    return InkWell(
        splashColor: COLOR_SECONDARY.withAlpha(30),
        child: c,
        onTap: () => Utils.navigateTo(context, ROUTE_POST, _post, (_) => {}));
  }
}

class EventCard extends StatefulWidget {
  final Post post;
  const EventCard({Key key, @required this.post}) : super(key: key);

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Post _post = widget.post;
    double iconSize = 16.0;

    final Widget _bbar = ButtonBar(
      alignment: MainAxisAlignment.end,
      //mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
            iconSize: iconSize,
            icon: Icon(Icons.share),
            color: Colors.grey,
            onPressed: () => Utils.sharePost(_post)),
        IconButton(
            iconSize: iconSize,
            icon: Icon(_post.getFavoriteIcon()),
            color: Colors.pink,
            onPressed: () => setState(() => _post.toogleFavorite()))
      ],
    );

    Widget img = Container(
        // width: 130,
        // height: 115,
        //padding: EdgeInsets.only(top: 15),
        // margin: const EdgeInsets.only(top: 15),
        //padding: const EdgeInsets.all(10.0),
        //decoration:BoxDecoration(border: Border.all(color: Colors.grey)),
        child: Image.network(_post.thumbnail, width: 130.0));

    Metadata loc = MetadataProvider().getSigneFromCache(MetadataTypes.locations, _post.locationId);

    Card c = Card(
      shadowColor: COLOR_SECONDARY,
      margin: EdgeInsets.only(top: 12, bottom: 0, left: 14, right: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: img,
            title: Text(_post.title, style: TextStyle(fontWeight: FontWeight.bold)),
            //subtitle: Text('Music by Julie Gable. Lyrics by Sidney Stein.'),
            //trailing: Icon(Icons.more_vert)
            //isThreeLine: true
          ),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: HtmlWidget(_post.excerpt,
                  webView: false, textStyle: TextStyle())),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(children: <Widget>[
                Expanded(
                    flex: 1,
                    child: Row(children: [
                      Icon(Icons.calendar_today,
                          size: 12, color: COLOR_SECONDARY),
                      Text(" " + _post.startDate)
                    ])),
                Expanded(
                    flex: 1,
                    child: Row(children: [
                      Icon(Icons.place, size: 12, color: COLOR_SECONDARY),
                      Text(' ' + loc.name)
                    ]))
              ])),
          _bbar
        ],
      ),
    );

    return InkWell(
        splashColor: COLOR_SECONDARY.withAlpha(30),
        child: c,
        onTap: () => Utils.navigateTo(context, ROUTE_POST, _post, (_) => {}));
  }
}
