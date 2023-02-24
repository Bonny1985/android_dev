import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pedalirurali/Constants.dart';
import 'package:pedalirurali/model/Post.dart';
import 'package:pedalirurali/model/User.dart';
import 'package:pedalirurali/provider/UserProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostProvider {
  final String favoriteKey = "favorite_post";
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  static final PostProvider _singleton = PostProvider._internal();
  factory PostProvider() => _singleton;
  PostProvider._internal(); // private constructor

  List<String> _cache = List();

  Future<void> init() async {
    _cache.clear();
    _cache.addAll(await getFavoriteIDs());
    print("## Init Favorites cache: " + _cache.toString());
  }

  bool isFavorite(Post post) {
    //print("## Favorites: " + _cache.toString());
    //print("is favorite post="+post.id.toString()+" : "+_cache.contains(post.id.toString()).toString());
    return _cache.contains(post.id.toString());
  }

  Future<Set<String>> getFavoriteIDs() async {
    final SharedPreferences prefs = await _prefs;
    List<String> ids = prefs.getStringList(favoriteKey);
    if (ids == null) ids = List();
    //_log(ids.toSet());
    return ids.toSet();
  }

  Future<void> toogleFavorite(Post post) async {
    final SharedPreferences prefs = await _prefs;
    Set<String> ids = await getFavoriteIDs();
    final String id = post.id.toString();
    if (post.favorite) {
      //log("set favorite: " + id);
      ids.add(id);
    } else {
      //log("set not favorite: " + id);
      ids.remove(id);
    }
    prefs.setStringList(favoriteKey, ids.toList());
    init();
    _remoteToogleFavorite(post);
  }

  Future<void> _remoteToogleFavorite(Post post) async {
    User u = UserProvider().getUser();
    // set up POST request arguments
    final String url =
        WP_REST_API_URL + '/pr/v1/events/favorite?pid=${post.id}&uid=${u.id}';
    final String basicAuth = 'Basic ' + base64Encode(utf8.encode(u.getAuth()));
    //print(url);
    //print(basicAuth);
    try {
      if (post.favorite) {
        http.post(url, headers: {"Authorization": basicAuth});
      } else {
        http.delete(url, headers: {"Authorization": basicAuth});
      }
    } catch (e, stacktrace) {
      print("ERROR: _remoteToogleFavorite method error");
      print("ERROR: " + e.toString());
      print(stacktrace);
    }
  }

  Future<void> reset() async {
    final SharedPreferences prefs = await _prefs;
    Set<String> ids = await getFavoriteIDs();
    _log(ids);
    prefs.setStringList(favoriteKey, List());
    init();
  }

  void _log(Set<String> ids) {
    //log("# Total of favorite posts: " + ids.length.toString());
    //ids.forEach((id) => log("# " + id));
  }
}
