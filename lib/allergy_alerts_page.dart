import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'session_manager.dart';

class AllergyAlertsPage extends StatefulWidget {
  const AllergyAlertsPage({super.key});

  @override
  State<AllergyAlertsPage> createState() => _AllergyAlertsPageState();
}

class _AllergyAlertsPageState extends State<AllergyAlertsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _allergyController = TextEditingController();
  final TextEditingController _reactionController = TextEditingController();
  final TextEditingController _severityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  List<Map<String, dynamic>> _allergyAlerts = [];
  String? _userEmail;
  String? _authToken;
  final _storage = const FlutterSecureStorage();
  String _aiTips = 'No tips available yet. Add an allergy to get personalized advice.';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEmailAndFetchAllergies();
  }

  @override
  void dispose() {
    _allergyController.dispose();
    _reactionController.dispose();
    _severityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadEmailAndFetchAllergies() async {
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
      await _fetchAllergies();
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User email or token not found in storage. Please log in.')),
      );
    }
  }

  Future<void> _fetchAllergies() async {
    try {
      if (_userEmail == null || _authToken == null) {
        throw Exception('User email or token not found in storage');
      }

      final url = 'https://health-tips-backend.onrender.com/allergyalerts/allergy?email=$_userEmail';
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
        final data = jsonDecode(response.body);
        if (kDebugMode) {
          print('Parsed response data: $data');
        }

        if (data.containsKey('symptoms')) {
          setState(() {
            _allergyAlerts = List<Map<String, dynamic>>.from(data['symptoms']);
          });
          if (kDebugMode) {
            print('Extracted allergy alerts: $_allergyAlerts');
          }
        } else if (data.containsKey('message') && data['symptoms'] == null) {
          setState(() {
            _allergyAlerts = [];
          });
          if (kDebugMode) {
            print('No allergy alerts found in response: $data');
          }
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No allergy alerts found: ${data['message']}')),
          );
        } else {
          throw Exception('Unexpected response format: "allergy" key not found');
        }
      } else {
        final data = jsonDecode(response.body);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch allergy alerts: ${data['message']}')),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching allergy alerts: $e');
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching allergy alerts: $e')),
      );
    }
  }

  Future<void> _getAITips() async {
    // Use the current input from the form fields
    final allergy = _allergyController.text;
    final reaction = _reactionController.text;
    final severity = _severityController.text;
    final notes = _notesController.text;

    // Log the input being used for AI tips
    if (kDebugMode) {
      print('Generating AI tips with input:');
    }
    if (kDebugMode) {
      print('Allergy: $allergy');
    }
    if (kDebugMode) {
      print('Reaction: $reaction');
    }
    if (kDebugMode) {
      print('Severity: $severity');
    }
    if (kDebugMode) {
      print('Notes: $notes');
    }

    // Check if the form fields have valid data
    if (allergy.isEmpty || reaction.isEmpty || severity.isEmpty) {
      setState(() {
        _aiTips = 'Please fill in all required fields (Allergy, Reaction, Severity) to get AI tips.';
      });
      if (kDebugMode) {
        print('AI tips generation failed: Required fields are empty');
      }
      return;
    }

    try {
      const apiKey = 'AIzaSyBWf3dHvfx8Mngg82THekL1x2ZRdlEnqs4';
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );

      // Format the current input for AI prompt
      final allergiesText = 'Allergy: $allergy, Reaction: $reaction, Severity: $severity, Notes: ${notes.isEmpty ? 'None' : notes}';

      final prompt = '''
      Analyze the following allergies and provide health tips to manage or improve the situation. Be concise and provide actionable advice in a list format. Do not include any disclaimers or warnings about seeking medical advice.

      $allergiesText
      ''';

      if (kDebugMode) {
        print('Sending prompt to AI: $prompt');
      }
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      if (kDebugMode) {
        print('AI response: ${response.text}');
      }

      setState(() {
        _aiTips = response.text ?? 'No tips generated.';
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error generating AI tips: $e');
      }
      setState(() {
        _aiTips = 'Error generating tips: $e';
      });
    }
  }

  Future<void> _saveAlert() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (_userEmail == null || _authToken == null) {
          throw Exception('User email or token not found in storage');
        }

        // Generate AI tips based on current input before saving
        await _getAITips();

        final alert = {
          'email': _userEmail,
          'allergy': _allergyController.text,
          'reaction': _reactionController.text,
          'severity': _severityController.text,
          'notes': _notesController.text,
        };

        final response = await http.post(
          Uri.parse('https://health-tips-backend.onrender.com/allergyalerts/allergy'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_authToken',
          },
          body: jsonEncode(alert),
        );

        if (response.statusCode == 201) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Allergy alert saved successfully')),
          );
          _allergyController.clear();
          _reactionController.clear();
          _severityController.clear();
          _notesController.clear();

          // After saving, fetch updated allergy alerts
          await _fetchAllergies();
        } else {
          final data = jsonDecode(response.body);
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save allergy alert: ${data['message']}')),
          );
        }
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving allergy alert: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
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

  Widget _buildAllergyInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Common Allergies:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('- Peanuts'),
        const Text('- Dairy'),
        const Text('- Eggs'),
        const Text('- Shellfish'),
        const SizedBox(height: 16),
        const Text('Past Allergies:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _allergyAlerts.isEmpty
            ? const Text('No allergies recorded yet.')
            : Column(
                children: _allergyAlerts.map((alert) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '- ${alert['allergy']} (Reaction: ${alert['reaction']}, Severity: ${alert['severity']})',
                    ),
                  );
                }).toList(),
              ),
        const SizedBox(height: 16),
        const Text('AI-Generated Health Tips:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Text(_aiTips),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Allergy Alerts'),
        backgroundColor: const Color.fromARGB(255, 114, 190, 200),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 108, 182, 182), Color.fromARGB(255, 135, 198, 206)],
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
                          controller: _allergyController,
                          decoration: _inputDecoration('Allergy', Icons.warning),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter allergy';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _reactionController,
                          decoration: _inputDecoration('Reaction', Icons.healing),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter reaction';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _severityController,
                          decoration: _inputDecoration('Severity', Icons.report),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter severity';
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
                            onPressed: _isLoading ? null : _saveAlert,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
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
                  child: _buildAllergyInfo(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}