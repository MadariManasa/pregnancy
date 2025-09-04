import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppointmentSchedulerPage extends StatefulWidget {
  const AppointmentSchedulerPage({super.key});

  @override
  State<AppointmentSchedulerPage> createState() => _AppointmentSchedulerPageState();
}

class _AppointmentSchedulerPageState extends State<AppointmentSchedulerPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _doctorController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  List<Map<String, dynamic>> _appointments = [];
  String? _userEmail;
  String? _authToken;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadEmailAndFetchAppointments();
  }

  @override
  void dispose() {
    _doctorController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadEmailAndFetchAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final token = await _storage.read(key: 'auth_token');
    setState(() {
      _userEmail = prefs.getString('user_email');
      _authToken = token;
    });
    if (_userEmail != null && _authToken != null) {
      await _fetchAppointments();
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User email or token not found in storage')),
      );
    }
  }

  Future<void> _fetchAppointments() async {
    if (_userEmail == null || _authToken == null) return;

    try {
      final response = await http.get(
        Uri.parse('https://health-tips-backend.onrender.com/appointments/appointment?email=$_userEmail'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );
      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
      }
      if (kDebugMode) {
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // Check if the response is a list or wrapped in an object
        if (responseData is List) {
          setState(() {
            _appointments = List<Map<String, dynamic>>.from(responseData);
          });
        } else if (responseData is Map && responseData.containsKey('appointments')) {
          setState(() {
            _appointments = List<Map<String, dynamic>>.from(responseData['appointments']);
          });
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load appointments: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching appointments: $e');
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching appointments: $e')),
      );
    }
  }

  Future<void> _saveAppointment() async {
    if (_userEmail == null || _authToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User email or token not found in storage')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final appointment = {
        'email': _userEmail,
        'doctor': _doctorController.text,
        'date': _dateController.text,
        'time': _timeController.text,
        'notes': _notesController.text,
      };

      try {
        final response = await http.post(
          Uri.parse('https://health-tips-backend.onrender.com/appointments/appointment'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_authToken',
          },
          body: jsonEncode(appointment),
        );

        if (response.statusCode == 201) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appointment scheduled')),
          );
          _doctorController.clear();
          _dateController.clear();
          _timeController.clear();
          _notesController.clear();
          await _fetchAppointments();
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to schedule appointment')),
          );
        }
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error scheduling appointment')),
        );
      }
    }
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

  Widget _buildAppointmentInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Appointment Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('- Schedule regular check-ups'),
        Text('- Prepare questions in advance'),
        Text('- Arrive early for appointments'),
        SizedBox(height: 8),
        Text('Additional Info:'),
        Text('- Keep a record of appointment outcomes.'),
        Text('- Set reminders for upcoming appointments.'),
      ],
    );
  }

  Widget _buildAppointmentList() {
    return _appointments.isEmpty
        ? const Text('No appointments scheduled yet.')
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _appointments.length,
            itemBuilder: (context, index) {
              final appointment = _appointments[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text('Doctor: ${appointment['doctor']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${appointment['date']}'),
                      Text('Time: ${appointment['time']}'),
                      if (appointment['notes'] != null && appointment['notes'].isNotEmpty)
                        Text('Notes: ${appointment['notes']}'),
                    ],
                  ),
                ),
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Scheduler'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade200, Colors.teal.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
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
                          controller: _doctorController,
                          decoration: _inputDecoration('Doctor', Icons.person),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter doctor\'s name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _dateController,
                          decoration: _inputDecoration('Date', Icons.calendar_today),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter date';
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
                            onPressed: _saveAppointment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 80, 163, 154),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Schedule',
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
                  child: _buildAppointmentInfo(),
                ),
              ),
              const SizedBox(height: 30),
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Scheduled Appointments:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _buildAppointmentList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}