class UserModel {
  final String userSrNo;
  final String name;

  UserModel({required this.userSrNo, required this.name});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userSrNo: json['usersrno']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}
