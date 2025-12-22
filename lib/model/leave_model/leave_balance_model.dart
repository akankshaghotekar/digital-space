class LeaveBalanceModel {
  final int balance;

  LeaveBalanceModel({required this.balance});

  factory LeaveBalanceModel.fromJson(Map<String, dynamic> json) {
    return LeaveBalanceModel(
      balance: int.tryParse(json['balance'].toString()) ?? 0,
    );
  }
}
