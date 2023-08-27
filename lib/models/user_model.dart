class UserModel {
  String id;
  String name;
  String email;
  String? profile;
  String? pushToken;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profile = "",
    this.pushToken = "",
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      profile: map['profile'],
      pushToken: map['push_token'],
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['profile'] = profile;
    data['push_token'] = pushToken;
    return data;
  }
}
