class PasswordModel{
  String? id;
  String? site;
  String? username;
  String? password;
  String? note;
  
  PasswordModel({ required this.id, required this.site, required this.username, required this.password, this.note });

  factory PasswordModel.fromMap(Map<String, dynamic> map) {
    return PasswordModel(
      id: map["id"],
      site: map["site"],
      username: map["username"],
      password: map["password"],
      note: map["note"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "site": site,
      "username": username,
      "password": password,
      "note": note
    };
  }

}