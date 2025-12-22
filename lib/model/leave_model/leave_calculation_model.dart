class LeaveCalculationModel {
  final double leaveAppliedFor;
  final double lwp;
  final int balance;

  LeaveCalculationModel({
    required this.leaveAppliedFor,
    required this.lwp,
    required this.balance,
  });

  factory LeaveCalculationModel.fromJson(Map<String, dynamic> json) {
    return LeaveCalculationModel(
      leaveAppliedFor:
          double.tryParse(json['leave_applied_for'].toString()) ?? 0,
      lwp: double.tryParse(json['lwp'].toString()) ?? 0,
      balance: int.tryParse(json['balance'].toString()) ?? 0,
    );
  }
}
