import 'package:digital_space/api/api_service.dart';
import 'package:digital_space/model/service_ticket_model.dart/service_ticket_model.dart';
import 'package:digital_space/model/user_model/user_model.dart';
import 'package:digital_space/sharedpref/shared_pref_helper.dart';
import 'package:digital_space/utils/app_colors.dart';
import 'package:digital_space/utils/common/common_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ServiceTicketScreen extends StatefulWidget {
  const ServiceTicketScreen({super.key});

  @override
  State<ServiceTicketScreen> createState() => _ServiceTicketScreenState();
}

class _ServiceTicketScreenState extends State<ServiceTicketScreen> {
  Future<List<ServiceTicketModel>>? _ticketFuture;

  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();

  Future<List<UserModel>>? _usersFuture;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool _isAdmin = false;
  String? _selectedUserSrNo;
  String? _selectedEmployeeSrNo;

  @override
  void initState() {
    super.initState();
    _initUser();
    _ticketFuture = _loadTickets();
    _usersFuture = ApiService.getUsers();
  }

  Future<void> _initUser() async {
    final userSrNo = await SharedPrefHelper.getUserSrNo();
    if (!mounted) return;

    setState(() {
      _isAdmin = userSrNo == "1";
      if (_isAdmin) {
        _selectedUserSrNo = "0";
        _selectedEmployeeSrNo = "0";
      }
    });
  }

  Future<List<ServiceTicketModel>> _loadTickets() async {
    final loggedUserSrNo = await SharedPrefHelper.getUserSrNo();
    final loggedEmployeeSrNo = await SharedPrefHelper.getEmployeeSrNo();

    final usersrno = (_isAdmin && _selectedUserSrNo != null)
        ? _selectedUserSrNo!
        : loggedUserSrNo!;
    final employeesrno = (_isAdmin && _selectedEmployeeSrNo != null)
        ? _selectedEmployeeSrNo!
        : loggedEmployeeSrNo!;

    return ApiService.viewServiceTickets(
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
      setState(() {
        _fromDate = picked;
        if (_toDate.isBefore(_fromDate)) _toDate = _fromDate;
        _ticketFuture = _loadTickets();
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
      setState(() {
        _toDate = picked;
        _ticketFuture = _loadTickets();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const CommonDrawer(),
      appBar: AppBar(title: const Text("Service Tickets"), centerTitle: true),
      body: Column(
        children: [
          ///  SEARCH
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              onChanged: (value) {
                setState(() => _searchQuery = value.trim().toLowerCase());
              },
              decoration: InputDecoration(
                hintText: "Search service tickets...",
                hintStyle: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? Colors.white54 : null,
                ),
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
          if (_isAdmin)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              child: FutureBuilder<List<UserModel>>(
                future: _usersFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox();
                  }

                  final users = snapshot.data!;

                  return DropdownButtonFormField<String>(
                    value: _selectedUserSrNo,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    dropdownColor: isDark ? AppColors.darkCard : Colors.white,
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
                    items: [
                      const DropdownMenuItem(
                        value: "0",
                        child: Text("All Users"),
                      ),
                      ...users.map(
                        (u) => DropdownMenuItem(
                          value: u.userSrNo,
                          child: Text(u.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedUserSrNo = value;
                        _selectedEmployeeSrNo = value;
                        _ticketFuture = _loadTickets();
                      });
                    },
                  );
                },
              ),
            ),

          ///  DATE FILTER
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

          ///  LIST
          Expanded(
            child: FutureBuilder<List<ServiceTicketModel>>(
              future: _ticketFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allTickets = snapshot.data ?? [];

                final tickets = _searchQuery.isEmpty
                    ? allTickets
                    : allTickets
                          .where(
                            (t) =>
                                t.issueTitle.toLowerCase().contains(
                                  _searchQuery,
                                ) ||
                                t.issueDetail.toLowerCase().contains(
                                  _searchQuery,
                                ) ||
                                t.clientName.toLowerCase().contains(
                                  _searchQuery,
                                ) ||
                                t.projectName.toLowerCase().contains(
                                  _searchQuery,
                                ) ||
                                t.status.toLowerCase().contains(_searchQuery),
                          )
                          .toList();

                if (tickets.isEmpty) {
                  return const Center(child: Text("No service tickets found"));
                }

                return ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: tickets.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    return _ticketCard(tickets[index], isDark);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// TICKET CARD
  Widget _ticketCard(ServiceTicketModel t, bool isDark) {
    final priorityColor = t.priority == "High" ? Colors.red : Colors.orange;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.issueTitle,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  t.priority,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 6.h),

          Text(
            t.issueDetail,
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? Colors.white70 : Colors.grey,
            ),
          ),

          SizedBox(height: 10.h),

          Row(
            children: [
              _infoChip("Client", t.clientName, isDark),
              SizedBox(width: 8.w),
              _infoChip("Project", t.projectName, isDark),
            ],
          ),

          SizedBox(height: 10.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat(
                  'dd MMM yyyy',
                ).format(DateFormat('dd-MM-yyyy').parse(t.date)),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
              ),
              Text(
                t.status,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label, String value, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        "$label: $value",
        style: TextStyle(
          fontSize: 11.sp,
          color: isDark ? Colors.white70 : Colors.black,
        ),
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
                color: isDark ? Colors.white54 : Colors.grey,
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
