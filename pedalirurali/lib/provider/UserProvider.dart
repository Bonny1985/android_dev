import 'package:pedalirurali/Constants.dart';
import 'package:pedalirurali/model/User.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

const String API_USR = "rest-api";
const String API_PWD = "KjAqnyDTE!nPGTGq.dJHHY89";

class UserProvider {
  static final UserProvider _singleton = UserProvider._internal();
  factory UserProvider() => _singleton;
  UserProvider._internal(); // private constructor
  User _cache;
  static const String USER_KEY = "user_key";
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> init() async {
     _setData(USER_KEY, null);
    _cache = null;
    String jsonUser = await _getData(USER_KEY);

    if (jsonUser == null) {
      _cache = User();
      _cache.id = Uuid().v5(Uuid.NAMESPACE_URL, APP_NAME);
      _cache.nickName = API_USR;
      _cache.pwd = API_PWD;
      _setData(USER_KEY, json.encode(_cache));
    } else {
      _cache = json.decode(jsonUser);
    }
   
    print(_cache.toString());
    
  }

  User getUser() => _cache;

  Future<void> _setData(String id, String data) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString(id, data);
  }

  Future<String> _getData(String id) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(id);
  }

  void _log(Set<String> ids) {
    //log("# Total of favorite posts: " + ids.length.toString());
    //ids.forEach((id) => log("# " + id));
  }
}
