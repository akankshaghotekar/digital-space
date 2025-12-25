import 'dart:convert';
import 'dart:io';
import 'package:digital_space/model/attendence_model/attendance_report_model.dart';
import 'package:digital_space/model/attendence_model/attendance_status_model.dart';
import 'package:digital_space/model/dsi/dsi_model.dart';
import 'package:digital_space/model/holiday_model/holiday_model.dart';
import 'package:digital_space/model/leave_model/leave_balance_model.dart';
import 'package:digital_space/model/leave_model/leave_calculation_model.dart';
import 'package:digital_space/model/leave_model/leave_view_model.dart';
import 'package:digital_space/model/progress/progress_status_model.dart';
import 'package:digital_space/model/project_model/project_model.dart';
import 'package:digital_space/model/service_ticket_model.dart/service_ticket_model.dart';
import 'package:digital_space/model/task_model/task_model.dart';
import 'package:digital_space/model/user_model/user_model.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiService {
  /// Generic POST (query params style – same as previous app)
  static Future<Map<String, dynamic>> _postRequest(
    String url,
    Map<String, String> params,
  ) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: params);
      final response = await http.post(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json is Map<String, dynamic>) {
          return json;
        }
      }
      return {'status': 1, 'message': 'Server error'};
    } catch (e) {
      return {'status': 1, 'message': 'Network error: $e'};
    }
  }

  /// Login API
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    return await _postRequest(ApiConfig.loginUrl, {
      'username': username,
      'password': password,
    });
  }

  /// Get Attendance Status
  static Future<AttendanceStatusModel?> getAttendanceStatus(
    String userSrNo,
  ) async {
    final res = await _postRequest(ApiConfig.getAttendanceStatus, {
      'usersrno': userSrNo,
    });

    if (res['status'] == 0) {
      return AttendanceStatusModel.fromJson(res);
    }
    return null;
  }

  /// Mark Attendance
  static Future<bool> markAttendance({
    required String userSrNo,
    required String employeeSrNo,
    required String billDate,
    required String inOut,
    required String lat,
    required String lng,
  }) async {
    final res = await _postRequest(ApiConfig.markAttendance, {
      'usersrno': userSrNo,
      'employeesrno': employeeSrNo,
      'bill_date': billDate,
      'in_out': inOut,
      'lat': lat,
      'lng': lng,
    });

    return res['status'] == 0;
  }

  /// Attendance Report
  static Future<List<AttendanceReportModel>> getAttendanceReport({
    required String userSrNo,
    required String fromDate,
    required String toDate,
  }) async {
    final res = await _postRequest(
      "${ApiConfig.baseUrl}get_attendance_report.php",
      {'usersrno': userSrNo, 'from_date': fromDate, 'to_date': toDate},
    );

    if (res['status'] == 0 && res['data'] != null) {
      return (res['data'] as List)
          .map((e) => AttendanceReportModel.fromJson(e))
          .toList();
    }
    return [];
  }

  /// Attendance Regularize
  static Future<Map<String, dynamic>> addAttendanceRegularize({
    required String srno,
    required String comments,
  }) async {
    return await _postRequest(ApiConfig.addattendanceRegularize, {
      "srno": srno,
      "comments": comments,
    });
  }

  /// Apply Leave
  static Future<Map<String, dynamic>> applyLeave({
    required String fromDate,
    required String toDate,
    required String userSrNo,
    required String halfDay,
    required String reason,
    required String lwp,
    required String balance,
  }) async {
    return await _postRequest(ApiConfig.applyLeave, {
      'leave_from_date': fromDate,
      'leave_to_date': toDate,
      'usersrno': userSrNo,
      'half_day': halfDay,
      'reason': reason,
      'lwp': lwp,
      'balance': balance,
    });
  }

  /// View Leaves
  static Future<List<LeaveViewModel>> viewLeaves({
    required String fromDate,
    required String toDate,
    required String userSrNo,
  }) async {
    final res = await _postRequest(ApiConfig.leavesView, {
      'leave_from_date': fromDate,
      'leave_to_date': toDate,
      'usersrno': userSrNo,
    });

    if (res['status'] == 0 && res['data'] != null) {
      return (res['data'] as List)
          .map((e) => LeaveViewModel.fromJson(e))
          .toList();
    }
    return [];
  }

  /// Get Leave Balance
  static Future<LeaveBalanceModel?> getLeaveBalance(String userSrNo) async {
    final res = await _postRequest(ApiConfig.getLeavesBalance, {
      'usersrno': userSrNo,
    });

    if (res['status'] == 0) {
      return LeaveBalanceModel.fromJson(res);
    }
    return null;
  }

  /// Calculate Leave
  static Future<LeaveCalculationModel?> calculateLeave({
    required String fromDate,
    required String toDate,
    required String userSrNo,
    required String halfDay,
  }) async {
    final res = await _postRequest(ApiConfig.getLeavesCalculated, {
      'leave_from_date': fromDate,
      'leave_to_date': toDate,
      'usersrno': userSrNo,
      'half_day': halfDay,
    });

    if (res['status'] == 0) {
      return LeaveCalculationModel.fromJson(res);
    }
    return null;
  }

  static Future<bool> addTask({
    required String usersrno,
    required String employeesrno,
    required String fromUsersrno,
    required String taskName,
    required String taskDetail,
    required String taskPriority,
  }) async {
    final res = await _postRequest(ApiConfig.addTask, {
      "usersrno": usersrno,
      "employeesrno": employeesrno,
      "from_usersrno": fromUsersrno,
      "task_name": taskName,
      "task_detail": taskDetail,
      "task_priority": taskPriority,
    });

    return res["status"] == 0;
  }

  static Future<List<TaskModel>> viewTasks({
    required String usersrno,
    required String employeesrno,
    String? fromDate,
    String? toDate,
  }) async {
    final Map<String, String> body = {
      "usersrno": usersrno,
      "employeesrno": employeesrno,
    };

    /// Add dates ONLY if selected
    if (fromDate != null && toDate != null) {
      body["from_date"] = fromDate;
      body["to_date"] = toDate;
    }

    final res = await _postRequest(ApiConfig.viewTask, body);

    if (res["status"] == 0 && res["data"] != null) {
      return (res["data"] as List).map((e) => TaskModel.fromJson(e)).toList();
    }
    return [];
  }

  static Future<bool> addDsi({
    required String usersrno,
    required String employeesrno,
    required String title,
    required String description,
    required String link,
    required String relatedTo,
    File? imageFile,
  }) async {
    final uri = Uri.parse(ApiConfig.addDsi);

    final request = http.MultipartRequest('POST', uri);

    request.fields.addAll({
      "usersrno": usersrno,
      "employeesrno": employeesrno,
      "dsi_title": title,
      "dsi_description": description,
      "dsi_link": link,
      "dsi_related_to": relatedTo,
    });

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('img1', imageFile.path),
      );
    }

    final response = await request.send();
    final resBody = await response.stream.bytesToString();

    final decoded = jsonDecode(resBody);
    return decoded["status"] == 0;
  }

  static Future<List<DsiModel>> viewDsi({
    required String usersrno,
    required String employeesrno,
    String? fromDate,
    String? toDate,
  }) async {
    final Map<String, String> body = {
      "usersrno": usersrno,
      "employeesrno": employeesrno,
    };

    if (fromDate != null && toDate != null) {
      body["from_date"] = fromDate;
      body["to_date"] = toDate;
    }

    final res = await _postRequest(ApiConfig.viewDsi, body);

    if (res["status"] == 0 && res["data"] != null) {
      return (res["data"] as List).map((e) => DsiModel.fromJson(e)).toList();
    }
    return [];
  }

  static Future<List<HolidayModel>> getHolidayList() async {
    final res = await _postRequest(ApiConfig.holidayList, {});

    if (res["status"] == 0 && res["data"] != null) {
      return (res["data"] as List)
          .map((e) => HolidayModel.fromJson(e))
          .toList();
    }
    return [];
  }

  static Future<List<ServiceTicketModel>> viewServiceTickets({
    required String usersrno,
    required String employeesrno,
    required String fromDate,
    required String toDate,
  }) async {
    final res = await _postRequest(ApiConfig.viewService, {
      "usersrno": usersrno,
      "employeesrno": employeesrno,
      "from_date": fromDate,
      "to_date": toDate,
    });

    if (res["status"] == 0 && res["data"] != null) {
      return (res["data"] as List)
          .map((e) => ServiceTicketModel.fromJson(e))
          .toList();
    }

    return [];
  }

  static Future<List<UserModel>> getUsers() async {
    final res = await _postRequest(ApiConfig.getUsers, {});

    if (res['status'] == 0 && res['data'] != null) {
      return (res['data'] as List).map((e) => UserModel.fromJson(e)).toList();
    }
    return [];
  }

  static Future<bool> updateTaskStatus({
    required String srNo,
    required String status,
  }) async {
    final uri = Uri.parse(
      "https://digitalspaceinc.com/digitalspace/ws/updatetaskstatus.php",
    ).replace(queryParameters: {"srno": srNo, "status": status});

    try {
      final response = await http.post(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json["status"] == 0;
      }
    } catch (e) {
      return false;
    }

    return false;
  }

  static Future<List<ProjectModel>> getActiveProjects() async {
    final res = await _postRequest(ApiConfig.getActiveProjects, {});

    if (res['status'] == 0 && res['data'] != null) {
      return (res['data'] as List)
          .map((e) => ProjectModel.fromJson(e))
          .toList();
    }
    return [];
  }

  static Future<ProgressStatusModel?> getProgressStatus({
    required String userSrNo,
  }) async {
    final res = await _postRequest(ApiConfig.getProgressStatus, {
      'usersrno': userSrNo,
    });

    if (res['status'] == 0) {
      return ProgressStatusModel.fromJson(res);
    }
    return null;
  }

  static Future<bool> updateServiceStatus({
    required String srNo,
    required String status,
  }) async {
    final res = await _postRequest(ApiConfig.updateServiceStatus, {
      "srno": srNo,
      "status": status,
    });

    return res["status"] == 0;
  }
}
