enum MetadataTypes { unknown, locations, organizer, categories, months, years }

class Metadata {
  String id;
  String name;

  Metadata.unknown() {
    this.id = "-1";
    this.name = "NP";
  }


  Metadata.def() {
    this.id = "-1";
    this.name = "Seleziona...";
  }

  Metadata(String id, String name) {
    this.id = id;
    this.name = name;
  }

  Metadata.simple(String id) {
    this.id = id;
    this.name = id;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
      };

  factory Metadata.fromJson(Map<String, dynamic> json) {
    Metadata m = Metadata.def();
    m.id = json["id"];
    m.name = json["name"];
    //print(m.toString());
    return m;
  }

  static List<Metadata> parseList(List<dynamic> list) {
    return list.map((i) => Metadata.fromJson(i)).toList();
  }

  @override
  String toString() => "Metadata{ id=" + this.id + ", name=" + this.name + " }";

  bool equals(Metadata md) => md != null ? md.id == this.id : false;
}
