class PasswordModel{
  String id;
  String uid;
  String? site;
  String? username;
  String? password;
  String? faviconUrl;
  String? note;
  
  PasswordModel({ required this.id, required this.uid, required this.site, required this.username, required this.password, this.faviconUrl, this.note });

  factory PasswordModel.fromMap(Map<String, dynamic> map) {
    return PasswordModel(
      id: map["id"],
      uid: map["uid"],
      site: map["site"],
      username: map["username"],
      password: map["password"],
      faviconUrl: map["faviconUrl"],
      note: map["note"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "uid": uid,
      "site": site,
      "username": username,
      "password": password,
      "faviconUrl": faviconUrl,
      "note": note
    };
  }

}