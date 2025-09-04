import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'session_manager.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userProfile;

  const EditProfilePage({super.key, required this.userProfile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _husbandNameController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _alternativeMobileNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _otherFamilyDetailsController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill form fields with existing profile data
    _nameController.text = widget.userProfile['name'] ?? '';
    _ageController.text = widget.userProfile['age']?.toString() ?? '';
    _weightController.text = widget.userProfile['weight']?.toString() ?? '';
    _birthdayController.text = widget.userProfile['birthday'] != null
        ? DateTime.parse(widget.userProfile['birthday']).toIso8601String().split('T')[0]
        : '';
    _husbandNameController.text = widget.userProfile['husbandName'] ?? '';
    _contactNumberController.text = widget.userProfile['contactNumber'] ?? '';
    _alternativeMobileNumberController.text = widget.userProfile['alternativeMobileNumber'] ?? '';
    _addressController.text = widget.userProfile['address'] ?? '';
    _otherFamilyDetailsController.text = widget.userProfile['otherFamilyDetails'] ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _birthdayController.dispose();
    _husbandNameController.dispose();
    _contactNumberController.dispose();
    _alternativeMobileNumberController.dispose();
    _addressController.dispose();
    _otherFamilyDetailsController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    // Check if at least one field is non-empty
    if (_nameController.text.isEmpty &&
        _ageController.text.isEmpty &&
        _weightController.text.isEmpty &&
        _birthdayController.text.isEmpty &&
        _husbandNameController.text.isEmpty &&
        _contactNumberController.text.isEmpty &&
        _alternativeMobileNumberController.text.isEmpty &&
        _addressController.text.isEmpty &&
        _otherFamilyDetailsController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please enter at least one detail to save.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = await SessionManager.getUserEmail();
      if (email == null) {
        throw Exception('User not logged in');
      }

      final response = await http.put(
        Uri.parse('https://health-tips-backend.onrender.com/profiles/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'name': _nameController.text.isNotEmpty ? _nameController.text : null,
          'age': _ageController.text.isNotEmpty ? int.parse(_ageController.text) : null,
          'weight': _weightController.text.isNotEmpty ? double.parse(_weightController.text) : null,
          'birthday': _birthdayController.text.isNotEmpty ? _birthdayController.text : null,
          'husbandName': _husbandNameController.text.isNotEmpty ? _husbandNameController.text : null,
          'contactNumber': _contactNumberController.text.isNotEmpty ? _contactNumberController.text : null,
          'alternativeMobileNumber': _alternativeMobileNumberController.text.isNotEmpty ? _alternativeMobileNumberController.text : null,
          'address': _addressController.text.isNotEmpty ? _addressController.text : null,
          'otherFamilyDetails': _otherFamilyDetailsController.text.isNotEmpty ? _otherFamilyDetailsController.text : null,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        // ignore: use_build_context_synchronously
        Navigator.pop(context, true); // Return true to trigger profile refresh
      } else {
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to update profile: ${response.body}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Something went wrong: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color.fromARGB(255, 106, 149, 221),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent.shade100, const Color.fromARGB(255, 144, 166, 226)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration('Name', Icons.person),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ageController,
                  decoration: _inputDecoration('Age', Icons.cake),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _weightController,
                  decoration: _inputDecoration('Weight', Icons.fitness_center),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _birthdayController,
                  decoration: _inputDecoration('Birthday', Icons.calendar_today),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _birthdayController.text = picked.toIso8601String().split('T')[0];
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _husbandNameController,
                  decoration: _inputDecoration('Husband Name', Icons.person),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contactNumberController,
                  decoration: _inputDecoration('Contact Number', Icons.phone),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _alternativeMobileNumberController,
                  decoration: _inputDecoration('Alternative Mobile Number', Icons.phone_android),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: _inputDecoration('Address', Icons.home),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _otherFamilyDetailsController,
                  decoration: _inputDecoration('Other Family Details', Icons.family_restroom),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 124, 144, 198),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Save',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pop(context, false), // Return false to indicate no changes
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade400,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}