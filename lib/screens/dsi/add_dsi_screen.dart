import 'dart:io';

import 'package:digital_space/api/api_service.dart';
import 'package:digital_space/sharedpref/shared_pref_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class AddDsiScreen extends StatefulWidget {
  const AddDsiScreen({super.key});

  @override
  State<AddDsiScreen> createState() => _AddDsiScreenState();
}

class _AddDsiScreenState extends State<AddDsiScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _linkController = TextEditingController();
  final _relatedController = TextEditingController();

  File? _selectedImage;
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final usersrno = await SharedPrefHelper.getUserSrNo();
    final employeesrno = await SharedPrefHelper.getEmployeeSrNo();

    setState(() => _isSubmitting = true);

    final success = await ApiService.addDsi(
      usersrno: usersrno!,
      employeesrno: employeesrno!,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      link: _linkController.text.trim(),
      relatedTo: _relatedController.text.trim(),
      imageFile: _selectedImage,
    );

    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("DSI added successfully")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to add DSI")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add DSI"), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _field(_titleController, "DSI Title", requiredField: true),
              SizedBox(height: 16.h),

              _field(
                _descController,
                "Description",
                maxLines: 4,
                requiredField: true,
              ),
              SizedBox(height: 16.h),

              _field(_linkController, "Reference Link"),
              SizedBox(height: 16.h),

              _field(_relatedController, "Related To"),
              SizedBox(height: 16.h),

              /// IMAGE PICKER
              Text(
                "Upload Image (Optional)",
                style: TextStyle(fontSize: 14.sp),
              ),
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150.h,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: _selectedImage == null
                      ? const Center(child: Icon(Icons.add_a_photo, size: 40))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 30.h),

              SizedBox(
                height: 48.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Submit",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    bool requiredField = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: requiredField
          ? (v) =>
                v == null || v.trim().isEmpty ? "This field is required" : null
          : null,
      decoration: InputDecoration(
        labelText: requiredField ? "$label *" : label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
