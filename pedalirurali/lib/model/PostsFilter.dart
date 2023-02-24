import 'package:pedalirurali/model/Metadata.dart';
import 'package:pedalirurali/model/Post.dart';

class PostsFilter {
  Metadata category, location, month, year;
  bool favorite = false;
  PostTypes type;
  
  PostsFilter(PostTypes type, bool favorite) {
    _init();
    this.type = type;
    this.favorite = favorite;
  }
/*
  PostsFilter.def() {
    _init();
    favorite = false;
  }

  PostsFilter.favorite() {
    _init();
    favorite = true;
  }
*/
  void _init() {
    category = Metadata.def();
    location = Metadata.def();
    month = Metadata.def();
    year = Metadata.def();
    type = PostTypes.events;
  }

  bool equals(PostsFilter ps) =>
      ps.category.equals(this.category) &&
      ps.location.equals(this.location) &&
      ps.month.equals(this.month) &&
      ps.year.equals(this.year);

  @override
  String toString() =>
      "PostsFilter{ cat=" +
      category.toString() +
      ", loc=" +
      location.toString() +
      ", month=" +
      month.toString() +
      ", year=" +
      year.toString() +
      ", favorite=" +
      favorite.toString() +
      ", type=" +
      type.name +
      " }";
}
