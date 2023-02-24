class User {
  String id;
  String nickName;
  String pwd;

  Map<String, dynamic> toJson() => {
    'id': id, 
    'nickName': nickName, 
    'pwd': pwd
  };

  String getAuth() {
    return '$nickName:$pwd';
  }

  @override
  String toString() => "User{ id=" + id + ", nickname=" + nickName + " }";
}
