import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pedalirurali/Utils.dart';
import 'package:pedalirurali/provider/PostProvider.dart';

enum PostTypes { unknown, events, permanent }

extension PostTypesExtension on PostTypes {
  String get name {
    switch (this) {
      case PostTypes.events:
        return 'events';
      case PostTypes.permanent:
        return 'permanent';
      default:
        return 'unknown';
    }
  }
}

PostTypes parsePostType(String name) {
  String tmp = name != null ? name.trim() : name;
  switch (tmp) {
    case 'events':
      return PostTypes.events;
    case 'permanent':
      return PostTypes.permanent;
    default:
      return PostTypes.unknown;
  }
}

class Post {
  int id;
  String title;
  String content;
  String excerpt;
  String thumbnail;
  String link;
  bool favorite = false;
  List<String> categories = List();
  PostTypes type = PostTypes.unknown;

  String locationId, organizerId;
  String eventLink;
  String startDate, endDate, startTime, endTime;
  bool allDay;
  int favoritesCount = 0;

  Post();

  void toogleFavorite() {
    this.favorite = !this.favorite;
    PostProvider().toogleFavorite(this);
  }

  IconData getFavoriteIcon() {
    return favorite ? Icons.favorite : Icons.favorite_border;
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    Post p = Post();
    //p.type = type;
    p.id = json["id"];
    p.link = json["link"];
    p.type = parsePostType(json["type"] ?? "");
    p.favorite = PostProvider().isFavorite(p);

    switch (p.type) {
      case PostTypes.events:
        p.title = json["title"];
        p.content = json["content"];
        p.excerpt = json["excerpt"];
        p.thumbnail = json["thumbnail"];
        p.locationId = json["location_id"];
        p.organizerId = json["organizer_id"];
        p.eventLink = json["event_link"];
        p.startDate = Utils.dateFormat(json["start_date"]);
        p.endDate = Utils.dateFormat(json["end_date"]);
        if (json["categories"] != null) {
          for (var item in json["categories"]) {
            p.categories.add(item);
          }
        }
        p.startTime = json["start_time"];
        p.endTime = json["end_time"];
        p.allDay =
            json["allday"] != null && json["allday"].toString().trim() == "1";
        p.favoritesCount = json["favorites"];
        break;
      case PostTypes.permanent:
        p.title = json["title"];
        p.content = json["content"];
        p.excerpt = json["excerpt"];
        p.thumbnail = json["thumbnail"];
        p.locationId = json["location_id"];
        p.organizerId = json["organizer_id"];
        p.eventLink = json["event_link"];
        p.startDate = Utils.dateFormat(json["start_date"]);
        p.endDate = Utils.dateFormat(json["end_date"]);
        if (json["categories"] != null) {
          for (var item in json["categories"]) {
            p.categories.add(item);
          }
        }
        p.startTime = json["start_time"];
        p.endTime = json["end_time"];
        p.allDay =
            json["allday"] != null && json["allday"].toString().trim() == "1";
        break;
      default:
        break;
    }

    final ExcerptMaxWords = 25;

    if (p.excerpt != null) {
      List<String> s = p.excerpt.split(" ");
      if (s.length > ExcerptMaxWords) {
        List<String> s2 = new List();
        for (var i = 0; i < ExcerptMaxWords; i++) {
          s2.add(s[i]);
        }
        p.excerpt = s2.join(" ") + " ...</p>";
        s = s2 = null;
      }
    }
/*
    List<dynamic> cats = json["categories"];
    if (cats != null) {
      cats.forEach((c) => p.categories.add(c.toString()));
    }
    cats = null;
    Cat.Ages.forEach((a) {
      if (p.categories.contains(a.id)) {
        p.age = a.title;
      }
    });
*/
    return p;
  }

  static List<Post> parseList(List<dynamic> list) {
    return list.map((i) => Post.fromJson(i)).toList();
  }

  @override
  String toString() =>
      "Post{ id=" + id.toString() + ", type=" + type.name + " }";
}
