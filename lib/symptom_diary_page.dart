import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'session_manager.dart';

class SymptomDiaryPage extends StatefulWidget {
  const SymptomDiaryPage({super.key});

  @override
  State<SymptomDiaryPage> createState() => _SymptomDiaryPageState();
}

class _SymptomDiaryPageState extends State<SymptomDiaryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _symptomController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _severityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _pastSymptoms = [];
  String _aiTips = 'No tips available yet. Add a symptom to get personalized advice.';

  @override
  void initState() {
    super.initState();
    _fetchSymptoms(); // Fetch symptoms when the page loads
  }

  @override
  void dispose() {
    _symptomController.dispose();
    _dateController.dispose();
    _severityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveSymptom() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Get the user's email from SessionManager
        final email = await SessionManager.getUserEmail();
        if (email == null) {
          throw Exception('User not logged in');
        }

        // POST request to save the symptom
        final response = await http.post(
          Uri.parse('https://health-tips-backend.onrender.com/symptoms/symptom'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'symptom': _symptomController.text,
            'date': _dateController.text,
            'severity': _severityController.text,
            'notes': _notesController.text,
          }),
        );

        if (response.statusCode == 201) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Symptom entry saved successfully')),
          );
          _symptomController.clear();
          _dateController.clear();
          _severityController.clear();
          _notesController.clear();

          // After saving, fetch updated symptoms and get AI tips
          await _fetchSymptoms();
        } else {
          final data = jsonDecode(response.body);
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save symptom: ${data['message']}')),
          );
        }
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchSymptoms() async {
    try {
      final email = await SessionManager.getUserEmail();
      if (email == null) {
        throw Exception('User not logged in');
      }

      // GET request to fetch symptoms
      final response = await http.get(
        Uri.parse('https://health-tips-backend.onrender.com/symptoms/symptom?email=$email'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _pastSymptoms = List<Map<String, dynamic>>.from(data['symptoms']);
        });

        // Send symptoms to Google Generative AI for analysis
        await _getAITips();
      } else {
        final data = jsonDecode(response.body);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch symptoms: ${data['message']}')),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching symptoms: $e')),
      );
    }
  }

  Future<void> _getAITips() async {
    if (_pastSymptoms.isEmpty) {
      setState(() {
        _aiTips = 'No symptoms recorded yet. Add a symptom to get personalized advice.';
      });
      return;
    }

    try {
      final apiKey = 'AIzaSyBWf3dHvfx8Mngg82THekL1x2ZRdlEnqs4';

      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );

      // Format symptoms data for AI prompt
      final symptomsText = _pastSymptoms.map((symptom) {
        return 'Symptom: ${symptom['symptom']}, Date: ${symptom['date']}, Severity: ${symptom['severity']}, Notes: ${symptom['notes']}';
      }).join('\n');

      final prompt = '''
      Analyze the following symptoms and provide health tips to manage or improve the situation. Be concise and provide actionable advice in a list format. Do not include any disclaimers or warnings about seeking medical advice.

      $symptomsText
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      setState(() {
        _aiTips = response.text ?? 'No tips generated.';
      });
    } catch (e) {
      setState(() {
        _aiTips = 'Error generating tips: $e';
      });
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

  Widget _buildSymptomInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Past Symptoms:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        _pastSymptoms.isEmpty
            ? const Text('No symptoms recorded yet.')
            : Column(
                children: _pastSymptoms.map((symptom) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '- ${symptom['symptom']} on ${symptom['date'].toString().substring(0, 10)} (Severity: ${symptom['severity']})',
                    ),
                  );
                }).toList(),
              ),
        const SizedBox(height: 16),
        const Text(
          'AI-Generated Health Tips:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(_aiTips),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Symptom Diary'),
        backgroundColor: Colors.redAccent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.redAccent, Colors.red],
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
                          controller: _symptomController,
                          decoration: _inputDecoration('Symptom', Icons.warning),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter symptom';
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
                            onPressed: _isLoading ? null : _saveSymptom,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
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
                  child: _buildSymptomInfo(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}