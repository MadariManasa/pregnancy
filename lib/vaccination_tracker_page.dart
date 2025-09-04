import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'session_manager.dart';

class VaccinationTrackerPage extends StatefulWidget {
  const VaccinationTrackerPage({super.key});

  @override
  State<VaccinationTrackerPage> createState() => _VaccinationTrackerPageState();
}

class _VaccinationTrackerPageState extends State<VaccinationTrackerPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _vaccineNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  
  List<Map<String, dynamic>> _pastVaccinations = [];
  String? _userEmail;
  String? _authToken;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEmailAndFetchVaccinations();
  }

  @override
  void dispose() {
    _vaccineNameController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _loadEmailAndFetchVaccinations() async {
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
      await _fetchVaccinations();
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User email or token not found in storage. Please log in.')),
      );
    }
  }

  Future<void> _fetchVaccinations() async {
    if (_userEmail == null || _authToken == null) return;

    try {
      final url = 'https://health-tips-backend.onrender.com/vaccinationandgrowth/vaccination?email=$_userEmail';
      if (kDebugMode) {
        print('Making GET request to: $url');
      }
      final response = await http.get(
        Uri.parse(url),
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
        if (kDebugMode) {
          print('Parsed response data: $responseData');
        }

        List<Map<String, dynamic>> vaccinations = [];
        if (responseData.containsKey('vaccinations')) {
          vaccinations = List<Map<String, dynamic>>.from(responseData['vaccinations']);
        } else if (responseData.containsKey('message') && responseData['vaccinations'] == null) {
          vaccinations = [];
          if (kDebugMode) {
            print('No vaccinations found in response: $responseData');
          }
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No vaccinations found: ${responseData['message']}')),
          );
        } else {
          throw Exception('Unexpected response format: "vaccinations" key not found');
        }

        if (kDebugMode) {
          print('Extracted vaccinations: $vaccinations');
        }
        setState(() {
          _pastVaccinations = vaccinations;
        });
      } else {
        final data = jsonDecode(response.body);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load vaccinations: ${response.statusCode} - ${data['message']}')),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching vaccinations: $e');
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching vaccinations: $e')),
      );
    }
  }

  Future<void> _saveVaccination() async {
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
        final vaccination = {
          'email': _userEmail,
          'vaccinationName': _vaccineNameController.text,
          'date': _dateController.text,
        };

        final response = await http.post(
          Uri.parse('https://health-tips-backend.onrender.com/vaccinationandgrowth/vaccination'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_authToken',
          },
          body: jsonEncode(vaccination),
        );

        if (response.statusCode == 201) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vaccination record saved')),
          );
          _vaccineNameController.clear();
          _dateController.clear();
          await _fetchVaccinations();
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save vaccination: ${response.statusCode} - ${response.body}')),
          );
        }
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving vaccination')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildScheduleTable() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vaccination Schedule:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Table(
              border: TableBorder.all(color: Colors.grey),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
              },
              children: const [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Vaccine', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Recommended Age', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
                TableRow(children: [
                  Padding(padding: EdgeInsets.all(8.0), child: Text('Hepatitis B')),
                  Padding(padding: EdgeInsets.all(8.0), child: Text('Birth, 1-2 months, 6-18 months')),
                ]),
                TableRow(children: [
                  Padding(padding: EdgeInsets.all(8.0), child: Text('DTaP')),
                  Padding(padding: EdgeInsets.all(8.0), child: Text('2, 4, 6 months, 15-18 months, 4-6 years')),
                ]),
                TableRow(children: [
                  Padding(padding: EdgeInsets.all(8.0), child: Text('Polio')),
                  Padding(padding: EdgeInsets.all(8.0), child: Text('2, 4, 6-18 months, 4-6 years')),
                ]),
                TableRow(children: [
                  Padding(padding: EdgeInsets.all(8.0), child: Text('MMR')),
                  Padding(padding: EdgeInsets.all(8.0), child: Text('12-15 months, 4-6 years')),
                ]),
                TableRow(children: [
                  Padding(padding: EdgeInsets.all(8.0), child: Text('Varicella')),
                  Padding(padding: EdgeInsets.all(8.0), child: Text('12-15 months, 4-6 years')),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastVaccinations() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Past Vaccinations:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            _pastVaccinations.isEmpty
                ? const Text('No vaccinations recorded yet.')
                : Column(
                    children: _pastVaccinations.map((vaccination) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          '- ${vaccination['vaccinationName']} on ${vaccination['date']}',
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Frequently Asked Questions:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            Text('Q: When should my child get vaccinated?'),
            Text('A: Follow the recommended vaccination schedule provided by your healthcare provider.'),
            SizedBox(height: 8),
            Text('Q: Are vaccines safe?'),
            Text('A: Yes, vaccines are thoroughly tested and monitored for safety.'),
            SizedBox(height: 8),
            Text('Q: What if my child misses a vaccine?'),
            Text('A: Consult your pediatrician to catch up on missed vaccines.'),
          ],
        ),
      ),
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
        title: const Text('Vaccination Tracker'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildScheduleTable(),
              _buildPastVaccinations(),
              _buildFAQSection(),
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
                          controller: _vaccineNameController,
                          decoration: _inputDecoration('Vaccine Name', Icons.vaccines),
                          validator: (value) => value == null || value.isEmpty ? 'Please enter vaccine name' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _dateController,
                          decoration: _inputDecoration('Date', Icons.calendar_today),
                          validator: (value) => value == null || value.isEmpty ? 'Please enter date' : null,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _dateController.text = pickedDate.toString().substring(0, 10); // Format as YYYY-MM-DD
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveVaccination,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
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
            ],
          ),
        ),
      ),
    );
  }
}