import 'dart:collection';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:pedalirurali/Constants.dart';
import 'package:pedalirurali/model/Metadata.dart';
import 'package:pedalirurali/model/Post.dart';
import 'package:pedalirurali/model/PostsFilter.dart';
import 'package:pedalirurali/provider/PostProvider.dart';
import 'package:pedalirurali/widget/MetadataDropdownWidget.dart';
import 'package:pedalirurali/widget/PostCardWidget.dart';

class PostsWidget extends StatefulWidget {
  final PostsFilter filter;
  const PostsWidget({Key key, @required this.filter}) : super(key: key);

  @override
  _PostsState createState() => _PostsState();
}

class _PostsState extends State<PostsWidget>
    with AutomaticKeepAliveClientMixin<PostsWidget> {
  PostsFilter _filter;
  bool _hasMore;
  int _pageNumber;
  bool _error;
  bool _loading;
  final int _defaultPerPageCount = 10;
  List<Post> _posts;
  final int _nextPageThreshold = 5;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    resetPosts(widget.filter);
    fetchPosts();
  }

  void resetPosts(PostsFilter pf) {
    _filter = pf;
    print("PostsWidget init: " + _filter.toString());
    _hasMore = true;
    _pageNumber = 1;
    _error = false;
    _loading = true;
    _posts = [];
  }

  bool _isFavorite() {
    return _filter.favorite == true;
  }

  @override
  Widget build(BuildContext context) {
    FloatingActionButton filterBtn = FloatingActionButton.extended(
        onPressed: () {
          _showPostFilter(context);
        },
        label: Text('Filtra'),
        icon: Icon(Icons.search),
        backgroundColor: COLOR_SECONDARY);

    return Scaffold(
        //appBar: _isFavorite() ? AppBar(title:  Text("I miei preferiti")) : null,
        body: getBody(context),
        floatingActionButton: !_isFavorite() ? filterBtn : null);
  }

  Widget getBody(BuildContext context) {
    if (_posts.isEmpty) {
      if (_loading) {
        return LandingWidget();
      } else if (_error) {
        return Center(
            child: InkWell(
          onTap: () {
            setState(() {
              _loading = true;
              _error = false;
              fetchPosts();
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(LOAD_ERR_MSG),
          ),
        ));
      }
    } else {
      return ListView.builder(
          itemCount: _posts.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            //print("index="+index.toString()+", _posts.length="+_posts.length.toString());
            if (index == _posts.length - _nextPageThreshold) {
              //if(!this.mounted) {
              fetchPosts();
              //}
            }
            if (index == _posts.length) {
              if (_error) {
                return Center(
                    child: InkWell(
                  onTap: () {
                    setState(() {
                      _loading = true;
                      _error = false;
                      fetchPosts();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(LOAD_ERR_MSG),
                  ),
                ));
              } else {
                return Center(
                    child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircularProgressIndicator(),
                ));
              }
            }

            final Post _post = _posts[index];

            if (_isFavorite()) _post.favorite = true;

            return PostCardWidget(post: _post);
          });
    }

    Text empty = Text(_isFavorite()
        ? "La tua lista dei preferiti è ancora vuota"
        : "Ops! Nessun elemento trovato");

    return Center(
        child: Column(children: [
      Padding(
          child: empty,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 36)),
      Icon(Icons.sentiment_dissatisfied, size: 50, color: COLOR_RED)
    ]));
  }

  Future<void> fetchPosts() async {
    print("fetchPosts");
    try {
      String apiRoot = WP_REST_API_URL + "/pr/v1/events/list";

      final HashMap params = HashMap<String, String>();

      //params["_embed"] = ""; // per caricare le immagini dei post
      params["per_page"] = _defaultPerPageCount.toString();
      params["page"] = _pageNumber.toString();

      if (_isFavorite()) {
        Set<String> ids = await PostProvider().getFavoriteIDs();
        //non ritornerà nessun post perché postID > 0
        if (ids.isEmpty) {
          ids.add("0");
        }
        params["favorite"] = '1';
        params["include"] = ids.join(",");
      } else {
        params["type"] = _filter.type.name;
        params["favorite"] = '0';
        params["category"] = _filter.category.id.toString();
        params["location"] = _filter.location.id.toString();
        params["month"] = _filter.month.id.toString();
        params["year"] = _filter.year.id.toString();
      }

      final String url = apiRoot +
          '?' +
          params.entries.map((it) => it.key + "=" + it.value).join("&");

      print("Start http URL=$url");
      final response = await http.get(url);
      //print("End http statusCode=" + response.statusCode.toString());
      // print(response.body.toString());
      switch (response.statusCode) {
        case 200:
          {
            List<Post> fetchedPosts =
                Post.parseList(json.decode(response.body));
            // print("Post retrived=" + fetchedPosts.length.toString());
            //fetchedPosts.forEach((i) => log(i.title.toString()))
            if (this.mounted)
              setState(() {
                _hasMore = fetchedPosts.length == _defaultPerPageCount;
                _loading = false;
                _pageNumber = _pageNumber + 1;
                _posts.addAll(fetchedPosts);
              });
          }
          break;
        case 400:
          {
            if (this.mounted)
              setState(() {
                _hasMore = false;
                _loading = false;
              });
          }
          break;
        default:
          {
            throw "WP response error: " + response.statusCode.toString();
          }
        //break;
      }
    } catch (e, stacktrace) {
      print("ERROR: fetchPosts method error");
      print("ERROR: " + e.toString());
      print(stacktrace);
      if (this.mounted)
        setState(() {
          _loading = false;
          _error = true;
        });
    }
  }

  void _showPostFilter(context) {
    FilterWidget fw = FilterWidget(
        filter: _filter,
        onChanged: (PostsFilter newFilter) {
          //TODO da capire scope
          //print("_showPostFilter old: " + _filter.toString());
          //print("_showPostFilter new: " + newFilter.toString());
          //if (!newFilter.equals(_filter)) {
          setState(() {
            resetPosts(newFilter);
            fetchPosts();
          });
          //}
        });

    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return fw;
        });
  }
}

class LandingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget _img = Container(
        //margin: const EdgeInsets.only(bottom: 6),
        child: Image(image: AssetImage(ASSET_LOGO_HEADER), width: 200));

    return Center(
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(children: [
              SizedBox(height: 10),
              _img,
              SizedBox(height: 10),
              Text(APP_NAME, style: TextStyle(fontSize: 22.0)),
              SizedBox(height: 10),
              Text(APP_MOTO, style: TextStyle(fontSize: 18.0)),
              SizedBox(height: 16),
              CircularProgressIndicator()
            ])));
  }
}

class FilterWidget extends StatefulWidget {
  final PostsFilter filter;
  final ValueChanged<PostsFilter> onChanged;

  FilterWidget({Key key, @required this.filter, @required this.onChanged})
      : super(key: key);

  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  PostsFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.filter;
  }

  @override
  Widget build(BuildContext context) {
    Widget categoryDrw = MetadataDropdownWidget2(
        mdType: MetadataTypes.categories,
        onChanged: (Metadata md) {
          _filter.category = md;
        },
        label: "Categoria:",
        selected: _filter.category);

    Widget locationDrw = MetadataDropdownWidget2(
        mdType: MetadataTypes.locations,
        onChanged: (Metadata md) {
          _filter.location = md;
        },
        label: "Luogo:",
        selected: _filter.location);

    Widget monthsDrw = MetadataDropdownWidget2(
        mdType: MetadataTypes.months,
        onChanged: (Metadata md) {
          _filter.month = md;
          if (_filter.year.equals(Metadata.def())) {
            String y = new DateTime.now().year.toString();
            _filter.year = Metadata(y, y);
          }
        },
        label: "Mese:",
        selected: _filter.month);

    Widget yearsDrw = MetadataDropdownWidget2(
        mdType: MetadataTypes.years,
        onChanged: (Metadata md) {
          _filter.year = md;
        },
        label: "Anno:",
        selected: _filter.year);

    Widget filterBtn = FlatButton(
      color: COLOR_SECONDARY,
      textColor: Colors.white,
      //disabledColor: Colors.grey,
      //disabledTextColor: Colors.black,
      //padding: EdgeInsets.all(8.0),
      //splashColor: Colors.blueAccent,
      onPressed: () {
        print("FilterWidget onChange: " + _filter.toString());
        widget.onChanged(_filter);
        Navigator.pop(context);
      },
      child: Text("Filtra"),
    );

    List<Widget> children = <Widget>[];

    if (_filter.type == PostTypes.events) {
      children.add(monthsDrw);
      children.add(yearsDrw);
    }

    children.add(categoryDrw);
    children.add(locationDrw);
    children.add(Padding(
        padding: EdgeInsets.all(16.0),
        child: SizedBox(width: double.infinity, child: filterBtn)));

    return Container(child: new Wrap(children: children));
  }
}
