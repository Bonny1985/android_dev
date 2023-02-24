import 'package:pedalirurali/Constants.dart';
import 'package:pedalirurali/model/Metadata.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MetadataProvider {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static final MetadataProvider _singleton = MetadataProvider._internal();

  factory MetadataProvider() => _singleton;

  MetadataProvider._internal(); // private constructor

  Map<MetadataTypes, List<Metadata>> _cache = Map();

  List<Metadata> getFromCache(MetadataTypes mt) {
    List<Metadata> rs = List();
    rs.addAll(_cache[mt]);
    return rs;
  }

  Metadata getSigneFromCache(MetadataTypes mt, String id)  {
    return _cache[mt].singleWhere((element) => element.id == id, orElse: ()=> Metadata.unknown());
  }

  Future<void> _setData(String id, String data) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString(id, data);
  }

  Future<String> _getData(String id) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(id);
  }

  Future<void> setMetadataList(String id, List<Metadata> data) async {
    if (id != null) {
      String rs = "[]";
      if (data != null) {
        rs = json.encode(data);
      }
      //print("Update data id: $id with value: $rs");
      _setData(id, rs);
    }
  }

  Future<Map<MetadataTypes, List<Metadata>>> getMetadatamap(
      MetadataTypes mdType) async {
    Map<MetadataTypes, List<Metadata>> map = Map();
    for (MetadataTypes i in MetadataTypes.values) {
      map[i] = await getMetadataList(i);
    }
    return map;
  }

  Future<List<Metadata>> getMetadataList(MetadataTypes mdType) async {
    if (mdType == MetadataTypes.months) {
      return [
        Metadata.def(),
        Metadata("01", "Gennaio"),
        Metadata("02", "Febbraio"),
        Metadata("03", "Marzo"),
        Metadata("04", "Aprile"),
        Metadata("05", "Maggio"),
        Metadata("06", "Giugno"),
        Metadata("07", "Luglio"),
        Metadata("08", "Agosto"),
        Metadata("09", "Settembre"),
        Metadata("10", "Ottobre"),
        Metadata("11", "Novembre"),
        Metadata("12", "Dicembre")
      ];
    }

    if (mdType == MetadataTypes.years) {
      List<Metadata> years = [];
      years.add(Metadata.def());
      int currentYear = new DateTime.now().year;
      for (int i = currentYear; i < currentYear + 5; i++) {
        years.add(Metadata.simple(i.toString()));
      }
      return years;
    }

    return _getMetadataList(mdType.toString());
  }

  Future<List<Metadata>> _getMetadataList(String id) async {
    List<Metadata> rs = [];
    String data = await _getData(id);
    if (data != null && data.length > 0) {
      rs.addAll(Metadata.parseList(json.decode(data)));
    }
    return rs;
  }

  Future<void> init() async {
    _cache.clear();
    for (MetadataTypes i in MetadataTypes.values) {
      _cache[i] = await getMetadataList(i);
    }
    _load(MetadataTypes.categories, '/pr/v1/events/categories');
    _load(MetadataTypes.locations, '/pr/v1/events/locations');
    _load(MetadataTypes.organizer, '/pr/v1/events/organizer');
  }

  Future<void> _load(MetadataTypes mdType, String relativeUrl) async {
    final String url = WP_REST_API_URL + relativeUrl;
    try {
      // print("Start http URL=$URL");
      final response = await http.get(url);
      // print("End http URL=$URL statusCode=" + response.statusCode.toString());

      switch (response.statusCode) {
        case 200:
          {
            List<Metadata> list =
                Metadata.parseList(json.decode(response.body));
            MetadataProvider().setMetadataList(mdType.toString(), list);
            _cache[mdType] = list;
          }
          break;
        default:
          {
            throw "WP response error: " + response.statusCode.toString();
          }
        //break;
      }
    } catch (e, stacktrace) {
      print("ERROR: http = " + url);
      print("ERROR: " + e.toString());
      print(stacktrace);
    }
  }
}
