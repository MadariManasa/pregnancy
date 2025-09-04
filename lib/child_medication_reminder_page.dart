import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'session_manager.dart';

class ChildMedicationReminderPage extends StatefulWidget {
  const ChildMedicationReminderPage({super.key});

  @override
  State<ChildMedicationReminderPage> createState() => _ChildMedicationReminderPageState();
}

class _ChildMedicationReminderPageState extends State<ChildMedicationReminderPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _medicationNameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  List<Map<String, dynamic>> _pastReminders = [];
  String? _userEmail;
  String? _authToken;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEmailAndFetchReminders();
  }

  @override
  void dispose() {
    _medicationNameController.dispose();
    _dosageController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadEmailAndFetchReminders() async {
    final email = await SessionManager.getUserEmail();
    final token = await _storage.read(key: 'auth_token');
    setState(() {
      _userEmail = email;
      _authToken = token;
    });
    if (kDebugMode) {
      print('Retrieved email: $_userEmail');
    }
    if (kDebugMode) {
      print('Retrieved token: $_authToken');
    }

    if (_userEmail != null && _authToken != null) {
      await _fetchReminders();
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User email or token not found in storage. Please log in.')),
      );
    }
  }

  Future<void> _fetchReminders() async {
    if (_userEmail == null || _authToken == null) return;

    try {
      final url = 'https://health-tips-backend.onrender.com/medication/medicationreminder?email=$_userEmail';
      if (kDebugMode) {
        print('Making GET request to: $url');
      }
      if (kDebugMode) {
        print('Authorization header: Bearer $_authToken');
      }
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out. Please check your network connection.');
      });
      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
      }
      if (kDebugMode) {
        print('Response body: ${response.body}');
      }

      // Check if the response is HTML
      if (response.body.trim().startsWith('<!DOCTYPE') || response.body.contains('<html')) {
        throw Exception('Server returned HTML instead of JSON. Please check the server URL and ensure the endpoint is correct.');
      }

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (kDebugMode) {
          print('Parsed response data: $responseData');
        }

        List<Map<String, dynamic>> reminders = [];
        if (responseData.containsKey('medicationReminders')) {
          reminders = List<Map<String, dynamic>>.from(responseData['medicationReminders']);
        } else if (responseData.containsKey('message') && responseData['medicationReminders'] == null) {
          reminders = [];
          if (kDebugMode) {
            print('No reminders found in response: $responseData');
          }
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No reminders found: ${responseData['message']}')),
          );
        } else {
          throw Exception('Unexpected response format: "childMedicationReminders" key not found');
        }

        if (kDebugMode) {
          print('Extracted reminders: $reminders');
        }
        setState(() {
          _pastReminders = reminders;
        });
      } else {
        final data = jsonDecode(response.body);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load reminders: ${response.statusCode} - ${data['message']}')),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching reminders: $e');
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching reminders: $e')),
      );
    }
  }

  Future<void> _saveReminder() async {
    if (_userEmail == null || _authToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User email or token not found in storage. Please log in.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final reminder = {
          'email': _userEmail,
          'medicationName': _medicationNameController.text,
          'dosage': _dosageController.text,
          'time': _timeController.text,
          'notes': _notesController.text,
        };

        final url = 'https://health-tips-backend.onrender.com/medication/medicationreminder';
        if (kDebugMode) {
          print('Making POST request to: $url');
        }
        if (kDebugMode) {
          print('Request body: ${jsonEncode(reminder)}');
        }
        if (kDebugMode) {
          print('Authorization header: Bearer $_authToken');
        }
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_authToken',
          },
          body: jsonEncode(reminder),
        ).timeout(const Duration(seconds: 10), onTimeout: () {
          throw Exception('Request timed out. Please check your network connection.');
        });

        if (kDebugMode) {
          print('POST Response status: ${response.statusCode}');
        }
        if (kDebugMode) {
          print('POST Response body: ${response.body}');
        }

        // Check if the response is HTML
        if (response.body.trim().startsWith('<!DOCTYPE') || response.body.contains('<html')) {
          throw Exception('Server returned HTML instead of JSON. Please check the server URL and ensure the endpoint is correct.');
        }

        if (response.statusCode == 201) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Medication reminder saved')),
          );
          _medicationNameController.clear();
          _dosageController.clear();
          _timeController.clear();
          _notesController.clear();
          await _fetchReminders();
        } else {
          final data = jsonDecode(response.body);
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save reminder: ${response.statusCode} - ${data['message']}')),
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error saving reminder: $e');
        }
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving reminder: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildEmailSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.email, color: Color.fromARGB(255, 226, 136, 166)),
            const SizedBox(width: 8),
            Text(
              _userEmail ?? 'Loading email...',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.pinkAccent),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastReminders() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Past Child Medication Reminders:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            _pastReminders.isEmpty
                ? const Text('No reminders recorded yet.')
                : Column(
                    children: _pastReminders.map((reminder) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('- ${reminder['medicationName']}: ${reminder['dosage']} at ${reminder['time']}'),
                            if (reminder['notes'] != null && reminder['notes'].isNotEmpty)
                              Text('  Notes: ${reminder['notes']}', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Medication Reminder Tips:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(height: 8),
        Text('- Follow dosage instructions'),
        Text('- Keep track of timings'),
        Text('- Consult doctor if side effects occur'),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Medication Reminder'),
        backgroundColor: const Color.fromARGB(255, 204, 123, 150),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pinkAccent, Color.fromARGB(255, 175, 84, 114)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildEmailSection(),
              _buildPastReminders(),
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _medicationNameController,
                          decoration: _inputDecoration('Medication Name', Icons.medication),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter medication name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _dosageController,
                          decoration: _inputDecoration('Dosage', Icons.local_hospital),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter dosage';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _timeController,
                          decoration: _inputDecoration('Time', Icons.access_time),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter time';
                            }
                            return null;
                          },
                          onTap: () async {
                            TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              setState(() {
                                pickedTime.hour.toString().padLeft(2, '0');
                                final minute = pickedTime.minute.toString().padLeft(2, '0');
                                final period = pickedTime.hour < 12 ? 'AM' : 'PM';
                                final adjustedHour = pickedTime.hour % 12 == 0 ? 12 : pickedTime.hour % 12;
                                _timeController.text = '$adjustedHour:$minute $period';
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _notesController,
                          decoration: _inputDecoration('Notes', Icons.note),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveReminder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 226, 148, 124),
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
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildMedicationInfo(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}