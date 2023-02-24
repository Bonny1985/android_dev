import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:pedalirurali/Constants.dart';
import 'package:pedalirurali/Utils.dart';
import 'package:pedalirurali/model/Metadata.dart';
import 'package:pedalirurali/model/Post.dart';
import 'package:pedalirurali/provider/MetadataProvider.dart';

class PostWidget extends StatefulWidget {
  final Post post;

  const PostWidget({Key key, @required this.post}) : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  @override
  Widget build(BuildContext context) {
    Widget w;
    switch (widget.post.type) {
      case PostTypes.events:
        w = EventWidget(post: widget.post);
        break;
      case PostTypes.permanent:
        w = PermanentWidget(post: widget.post);
        break;
      default:
        w = Container();
    }
    return w;
  }
}

class PermanentWidget extends StatefulWidget {
    final Post post;

  const PermanentWidget({Key key, @required this.post}) : super(key: key);
  @override
  _PermanentWidgetState createState() => _PermanentWidgetState();
}

class _PermanentWidgetState extends State<PermanentWidget> {
 Post _post;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    print("init permanent post: " + _post.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       // resizeToAvoidBottomPadding: false,
        body: SingleChildScrollView(child: getBody(context)),
        appBar: AppBar(
          title: Text("Percorsi permanenti"),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                    onTap: () => Utils.sharePost(_post),
                    child: Icon(Icons.share, size: 26.0)))
          ]
        )
    );
  }

  Widget getBody(BuildContext context) {
    Widget _title = Padding(
        padding: EdgeInsets.only(bottom: 8, top: 6),
        child: HtmlWidget(_post.title,
            webView: false,
            textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)));

    Widget _body = HtmlWidget(_post.content, webView: false);

    Metadata loc = MetadataProvider()
        .getSigneFromCache(MetadataTypes.locations, _post.locationId);
    Metadata org = MetadataProvider()
        .getSigneFromCache(MetadataTypes.organizer, _post.organizerId);
    List<Metadata> cats = List();
    for (String cid in _post.categories) {
      Metadata tmp =
          MetadataProvider().getSigneFromCache(MetadataTypes.categories, cid);
      if (!Metadata.unknown().equals(tmp)) {
        cats.add(tmp);
      }
    }

    //print(_post.categories);
    //print(cats);

    Widget _img = Container(
        margin: const EdgeInsets.only(bottom: 6),
        child: Image.network(_post.thumbnail));

    Widget _item(IconData icon, String txt) {
      return Padding(
          padding: EdgeInsets.only(bottom: 6),
          child: Row(children: [
            Icon(icon, size: 18, color: COLOR_SECONDARY),
            Text("  " + txt, style: TextStyle(fontSize: 16))
          ]));
    }


    Widget _eventBtn = FlatButton.icon(
      label: Text("Sito Ufficiale"),
      color: COLOR_SECONDARY,
      icon: Icon(Icons.web),
      textColor: Colors.white,
      onPressed: () => Utils.launchURL(_post.eventLink)
    );

    List<Widget> _attrs = <Widget>[
      Row(children: <Widget>[_item(Icons.place, loc.name)]),
      Row(children: <Widget>[_item(Icons.category, cats.map((e) => e.name).join(", "))]),
      Row(children: <Widget>[_item(Icons.home, org.name)]),
      _eventBtn
    ];

    return Padding(
        padding: EdgeInsets.all(6),
        child: Column(children: [
          _title,
          _img,
          Divider(),
          Column(children: _attrs),
          Divider(),
          _body,
          SizedBox(height: 60)
        ]));
  }
}

class EventWidget extends StatefulWidget {
  final Post post;

  const EventWidget({Key key, @required this.post}) : super(key: key);
  @override
  _EventWidgetState createState() => _EventWidgetState();
}

class _EventWidgetState extends State<EventWidget> {
  Post _post;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    print("init event post: " + _post.toString());
  }

  @override
  Widget build(BuildContext context) {
    String title = _post.favorite ? "I miei eventi" : "Eventi";
    return Scaffold(
      //  resizeToAvoidBottomPadding: false,
        body: SingleChildScrollView(child: getBody(context)),
        appBar: AppBar(
          title: Text(title),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                    onTap: () => setState(() => _post.toogleFavorite()),
                    child: Icon(_post.getFavoriteIcon(), size: 26.0))),
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                    onTap: () => Utils.sharePost(_post),
                    child: Icon(Icons.share, size: 26.0)))
          ],
        ),
        /*floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Utils.launchURL(_post.eventLink),
            label: Text('Registrati'),
            //icon: Icon(Icons.people),
            backgroundColor: COLOR_SECONDARY)*/
        );
  }

  Widget getBody(BuildContext context) {
    Widget _title = Padding(
        padding: EdgeInsets.only(bottom: 8, top: 6),
        child: HtmlWidget(_post.title,
            webView: false,
            textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)));

    Widget _body = HtmlWidget(_post.content, webView: false);

    Metadata loc = MetadataProvider()
        .getSigneFromCache(MetadataTypes.locations, _post.locationId);
    Metadata org = MetadataProvider()
        .getSigneFromCache(MetadataTypes.organizer, _post.organizerId);
    List<Metadata> cats = List();
    for (String cid in _post.categories) {
      Metadata tmp =
          MetadataProvider().getSigneFromCache(MetadataTypes.categories, cid);
      if (!Metadata.unknown().equals(tmp)) {
        cats.add(tmp);
      }
    }

    //print(_post.categories);
    //print(cats);

    Widget _img = Container(
        margin: const EdgeInsets.only(bottom: 6),
        child: Image.network(_post.thumbnail));

    Widget _item(IconData icon, String txt) {
      return Padding(
          padding: EdgeInsets.only(bottom: 6),
          child: Row(children: [
            Icon(icon, size: 18, color: COLOR_SECONDARY),
            Text("  " + txt, style: TextStyle(fontSize: 16))
          ]));
    }

    String dateStr = _post.startDate;
    if (_post.endDate != null && _post.endDate != _post.startDate) {
      dateStr = dateStr + " - " + _post.endDate;
    }
    String timeStr = "Giornata intera";
    if (!_post.allDay) {
      timeStr = _post.startTime + " - " + _post.endTime;
    }

    Widget _favoriteBtn = FlatButton.icon(
      //padding: EdgeInsets.symmetric(horizontal: 4),
      label: Text("Partecipo"),
      color: COLOR_SECONDARY,
      icon: Icon(_post.getFavoriteIcon()),
      textColor: Colors.white,
      onPressed: () => setState(() => _post.toogleFavorite())
    );

    Widget _eventBtn = FlatButton.icon(
      //padding: EdgeInsets.symmetric(horizontal: 4),
      label: Text("Sito Ufficiale"),
      color: COLOR_SECONDARY,
      icon: Icon(Icons.web),
      textColor: Colors.white,
      onPressed: () => Utils.launchURL(_post.eventLink)
    );

    List<Widget> _attrs = <Widget>[
      Row(children: <Widget>[_item(Icons.calendar_today, dateStr)]),
      Row(children: <Widget>[_item(Icons.access_time, timeStr)]),
      Row(children: <Widget>[_item(Icons.place, loc.name)]),
      Row(children: <Widget>[_item(Icons.category, cats.map((e) => e.name).join(", "))]),
      Row(children: <Widget>[_item(Icons.home, org.name)]),
      Row(children: <Widget>[
        Expanded(flex: 1, child: Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: _eventBtn)),
        Expanded(flex: 1, child: Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: _favoriteBtn)),
        ])
    ];

    return Padding(
        padding: EdgeInsets.all(6),
        child: Column(children: [
          _title,
          _img,
          Divider(),
          Column(children: _attrs),
          Divider(),
          _body,
          SizedBox(height: 60)
        ]));
  }
}
