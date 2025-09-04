import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'session_manager.dart';
import 'login_page.dart';

class NutritionTrackerPage extends StatefulWidget {
  const NutritionTrackerPage({super.key});

  @override
  State<NutritionTrackerPage> createState() => _NutritionTrackerPageState();
}

class _NutritionTrackerPageState extends State<NutritionTrackerPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;
  String? _pregnancyTips;

  // Replace with your Google Generative AI API key
 final String _apiKey = 'AIzaSyBWf3dHvfx8Mngg82THekL1x2ZRdlEnqs4';

  @override
  void dispose() {
    _foodController.dispose();
    _quantityController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final email = await SessionManager.getUserEmail();
        if (kDebugMode) {
          print('Session email: $email');
        }

        if (email == null) {
          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in to save nutrition data')),
          );
          return;
        }

        // Save to your existing API
        final saveResponse = await http.post(
          Uri.parse('https://health-tips-backend.onrender.com/nutritions/nutrition'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'food': _foodController.text,
            'quantity': _quantityController.text,
            'date': _dateController.text,
            'notes': _notesController.text,
          }),
        );

        if (saveResponse.statusCode == 201) {
          // Get pregnancy nutrition tips from Google Generative AI
          await _getPregnancyTips();

          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nutrition entry saved successfully')),
          );
          _foodController.clear();
          _quantityController.clear();
          _dateController.clear();
          _notesController.clear();
        } else {
          showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to save nutrition entry: ${saveResponse.body}'),
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
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _getPregnancyTips() async {
    try {
      final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: _apiKey);
      final prompt = '''
        I am a pregnant woman tracking my nutrition. I just ate: 
        - Food: ${_foodController.text}
        - Quantity: ${_quantityController.text}
        - Date: ${_dateController.text}
        - Notes: ${_notesController.text}
        Based on this, provide 4-5 tailored tips on what I should eat during pregnancy to support a healthy pregnancy. Focus on nutrient-rich foods and avoid general advice.
      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      setState(() {
        _pregnancyTips = response.text;
      });

      // Show tips in a dialog
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pregnancy Nutrition Tips'),
          content: SingleChildScrollView(
            child: Text(_pregnancyTips ?? 'No tips available'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _pregnancyTips = 'Error fetching tips: $e';
      });
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to fetch pregnancy tips: $e'),
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _buildNutritionInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Nutrition Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('- Eat a balanced diet'),
        Text('- Include fruits and vegetables'),
        Text('- Stay hydrated'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Tracker'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.greenAccent, Colors.green],
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
                          controller: _foodController,
                          decoration: _inputDecoration('Food', Icons.fastfood),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter food';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _quantityController,
                          decoration: _inputDecoration('Quantity', Icons.scale),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter quantity';
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
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                _dateController.text = picked.toIso8601String().split('T')[0];
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _notesController,
                          decoration: _inputDecoration('Notes', Icons.note),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter notes';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveEntry,
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
                  child: _buildNutritionInfo(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}