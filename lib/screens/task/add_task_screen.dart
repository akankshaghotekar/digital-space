import 'package:digital_space/api/api_service.dart';
import 'package:digital_space/model/user_model/user_model.dart';
import 'package:digital_space/sharedpref/shared_pref_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _taskDetailController = TextEditingController();

  Future<List<UserModel>>? _usersFuture;

  String _priority = "Urgent";

  String _fromUserSrNo = "1";
  bool _isSubmitting = false;

  String? _userSrNo;
  String? _employeeSrNo;

  @override
  void initState() {
    super.initState();
    _usersFuture = ApiService.getUsers();
    _loadUser();
  }

  Future<void> _loadUser() async {
    _userSrNo = await SharedPrefHelper.getUserSrNo();
    _employeeSrNo = await SharedPrefHelper.getEmployeeSrNo();
  }

  Future<void> _submitTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_userSrNo == null || _employeeSrNo == null) return;

    setState(() => _isSubmitting = true);

    final success = await ApiService.addTask(
      usersrno: _userSrNo!,
      employeesrno: _employeeSrNo!,
      fromUsersrno: _fromUserSrNo,
      taskName: _taskNameController.text.trim(),
      taskDetail: _taskDetailController.text.trim(),
      taskPriority: _priority,
    );

    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Task added successfully")));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to add task")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("Add Task")),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                /// Task Name
                TextFormField(
                  controller: _taskNameController,
                  decoration: const InputDecoration(
                    labelText: "Task Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? "Enter task name" : null,
                ),

                SizedBox(height: 16.h),

                /// Task Detail
                TextFormField(
                  controller: _taskDetailController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: "Task Details",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? "Enter task details"
                      : null,
                ),

                SizedBox(height: 16.h),

                /// Assign From
                FutureBuilder<List<UserModel>>(
                  future: _usersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final users = snapshot.data ?? [];

                    return DropdownButtonFormField<String>(
                      value: _fromUserSrNo,
                      decoration: const InputDecoration(
                        labelText: "Assign From",
                        border: OutlineInputBorder(),
                      ),
                      items: users
                          .map(
                            (u) => DropdownMenuItem<String>(
                              value: u.userSrNo,
                              child: Text(u.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _fromUserSrNo = v!),
                      validator: (v) => v == null ? "Select user" : null,
                    );
                  },
                ),

                SizedBox(height: 16.h),

                /// Priority
                DropdownButtonFormField<String>(
                  value: _priority,
                  decoration: const InputDecoration(
                    labelText: "Task Priority",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Urgent", child: Text("Urgent")),
                    DropdownMenuItem(
                      value: "Important",
                      child: Text("Important"),
                    ),
                  ],
                  onChanged: (v) => setState(() => _priority = v!),
                ),

                SizedBox(height: 30.h),

                /// Submit Button
                SizedBox(
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Add Task",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
