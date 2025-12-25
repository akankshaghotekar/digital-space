class ApiConfig {
  static const String baseUrl = "https://digitalspaceinc.com/digitalspace/ws/";

  static String get loginUrl => "${baseUrl}login.php";
  static String get applyLeave => "${baseUrl}leavesapply.php";
  static String get leavesView => "${baseUrl}leavesview.php";
  static String get getLeavesBalance => "${baseUrl}get_leaves_balance.php";
  static String get getLeavesCalculated =>
      "${baseUrl}get_leaves_calculated.php";
  static String get getAttendanceStatus =>
      "${baseUrl}get_attendance_status.php";
  static String get markAttendance => "${baseUrl}markAttendance.php";
  static String get addattendanceRegularize =>
      "${baseUrl}addattendanceregularize.php";
  static String get addTask => "${baseUrl}addtask.php";
  static String get viewTask => "${baseUrl}viewtask.php";
  static String get addDsi => "${baseUrl}adddsi.php";
  static const String viewDsi = "${baseUrl}viewdsi.php";
  static const String holidayList = "${baseUrl}holidayList.php";
  static const String viewService = "${baseUrl}viewservice.php";
  static const String getUsers = "${baseUrl}getusers.php";
  static const String getActiveProjects = "${baseUrl}getactiveprojects.php";
  static const String getProgressStatus = "${baseUrl}getprogressstatus.php";
  static const String updateServiceStatus = "${baseUrl}updateservicestatus.php";
}
