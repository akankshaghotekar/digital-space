import 'package:digital_space/api/api_service.dart';
import 'package:digital_space/model/dsi/dsi_model.dart';
import 'package:digital_space/model/user_model/user_model.dart';
import 'package:digital_space/screens/dsi/add_dsi_screen.dart';
import 'package:digital_space/sharedpref/shared_pref_helper.dart';
import 'package:digital_space/utils/app_colors.dart';
import 'package:digital_space/utils/common/common_drawer.dart';
import 'package:digital_space/utils/media_query_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class DsiScreen extends StatefulWidget {
  const DsiScreen({super.key});

  @override
  State<DsiScreen> createState() => _DsiScreenState();
}

class _DsiScreenState extends State<DsiScreen> {
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  Future<List<UserModel>>? _usersFuture;
  List<UserModel> _users = [];

  Future<List<DsiModel>>? _dsiFuture;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool _isAdmin = true;
  String? _selectedUserSrNo;
  String? _selectedEmployeeSrNo;

  @override
  void initState() {
    super.initState();
    _initUser();
    _usersFuture = _loadUsers();
    _dsiFuture = _loadDsi();
  }

  Future<List<UserModel>> _loadUsers() async {
    final list = await ApiService.getUsers();

    return [UserModel(userSrNo: "0", name: "All Users"), ...list];
  }

  // Future<void> _initUser() async {
  //   final userSrNo = await SharedPrefHelper.getUserSrNo();
  //   if (!mounted) return;

  //   setState(() {
  //     _isAdmin = userSrNo == "1";
  //     if (_isAdmin) {
  //       _selectedUserSrNo = "0";
  //       _selectedEmployeeSrNo = "0";
  //     }
  //   });
  // }
  Future<void> _initUser() async {
    if (!mounted) return;

    setState(() {
      _isAdmin = true;
      _selectedUserSrNo = "0";
      _selectedEmployeeSrNo = "0";
    });
  }

  Future<List<DsiModel>> _loadDsi() async {
    final loggedUserSrNo = await SharedPrefHelper.getUserSrNo();
    final loggedEmployeeSrNo = await SharedPrefHelper.getEmployeeSrNo();

    // final usersrno = (_isAdmin && _selectedUserSrNo != null)
    //     ? _selectedUserSrNo!
    //     : loggedUserSrNo!;
    // final employeesrno = (_isAdmin && _selectedEmployeeSrNo != null)
    //     ? _selectedEmployeeSrNo!
    //     : loggedEmployeeSrNo!;
    final usersrno = _selectedUserSrNo ?? loggedUserSrNo!;
    final employeesrno = _selectedEmployeeSrNo ?? loggedEmployeeSrNo!;

    return ApiService.viewDsi(
      usersrno: usersrno,
      employeesrno: employeesrno,
      fromDate: DateFormat('dd-MM-yyyy').format(_fromDate),
      toDate: DateFormat('dd-MM-yyyy').format(_toDate),
    );
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _fromDate = picked;
      if (_toDate.isBefore(_fromDate)) _toDate = _fromDate;

      final future = _loadDsi();

      setState(() {
        _dsiFuture = future;
      });
    }
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate,
      firstDate: _fromDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _toDate = picked;

      final future = _loadDsi();

      setState(() {
        _dsiFuture = future;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const CommonDrawer(),
      appBar: AppBar(
        title: const Text("DSI"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final added = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddDsiScreen()),
              );
              if (added == true) {
                final future = _loadDsi();
                setState(() {
                  _dsiFuture = future;
                });
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          /// SEARCH
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) =>
                  setState(() => _searchQuery = value.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search DSI...",
                hintStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey,
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          /// ADMIN FILTER
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
            child: FutureBuilder<List<UserModel>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                }

                _users = snapshot.data!;

                return DropdownButtonFormField<String>(
                  value: _selectedUserSrNo,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkCard
                        : AppColors.lightCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: _users.map((u) {
                    return DropdownMenuItem(
                      value: u.userSrNo,
                      child: Text(u.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _selectedUserSrNo = value;
                    _selectedEmployeeSrNo = value;

                    final future = _loadDsi();

                    setState(() {
                      _dsiFuture = future;
                    });
                  },
                );
              },
            ),
          ),

          /// DATE FILTER
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Expanded(
                  child: _dateCard("From", _fromDate, _pickFromDate, isDark),
                ),
                SizedBox(width: 12.w),
                Expanded(child: _dateCard("To", _toDate, _pickToDate, isDark)),
              ],
            ),
          ),

          /// LIST
          Expanded(
            child: FutureBuilder<List<DsiModel>>(
              future: _dsiFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allList = snapshot.data ?? [];

                final list = _searchQuery.isEmpty
                    ? allList
                    : allList.where((dsi) {
                        return dsi.title.toLowerCase().contains(_searchQuery) ||
                            dsi.description.toLowerCase().contains(
                              _searchQuery,
                            ) ||
                            dsi.status.toLowerCase().contains(_searchQuery) ||
                            (dsi.relatedTo ?? '').toLowerCase().contains(
                              _searchQuery,
                            );
                      }).toList();

                if (list.isEmpty) {
                  return const Center(child: Text("No DSI found"));
                }

                return ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    return _dsiCard(list[index], isDark);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// CARD
  Widget _dsiCard(DsiModel dsi, bool isDark) {
    return Container(
      width: MQ.width(context),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1F2937), const Color(0xFF111827)]
              : [const Color(0xFFEEF2FF), Colors.white],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF2563EB), const Color(0xFF1E40AF)]
                    : [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.white),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    dsi.title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _iconRow(
                  Icons.description,
                  "Description",
                  dsi.description,
                  isDark,
                ),
                SizedBox(height: 10.h),
                _iconRow(Icons.calendar_today, "Date", dsi.date, isDark),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 8.w,
                  children: [
                    _chip(Icons.info, dsi.status, Colors.green, isDark),
                    if (dsi.relatedTo != null && dsi.relatedTo!.isNotEmpty)
                      _chip(Icons.link, dsi.relatedTo!, Colors.orange, isDark),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark ? Colors.white60 : Colors.grey,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(IconData icon, String text, Color color, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.25 : 0.15),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateCard(
    String label,
    DateTime date,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? Colors.white24 : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark ? Colors.white70 : Colors.grey,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              DateFormat('dd MMM yyyy').format(date),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
