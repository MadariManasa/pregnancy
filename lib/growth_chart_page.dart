import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'session_manager.dart';

class GrowthChartPage extends StatefulWidget {
  const GrowthChartPage({super.key});

  @override
  State<GrowthChartPage> createState() => _GrowthChartPageState();
}

class _GrowthChartPageState extends State<GrowthChartPage> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  
  List<Map<String, dynamic>> _entries = [];
  String? _userEmail;
  String? _authToken;
  bool _isLoading = false;
  bool _isFetchingTips = false;
  String? _growthTips;

  // Replace with your Gemini API key
  static const String _apiKey = 'AIzaSyBWf3dHvfx8Mngg82THekL1x2ZRdlEnqs4'; // e.g., 'AIzaSyD...'

  @override
  void initState() {
    super.initState();
    _loadEmailAndFetchGrowthEntries();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadEmailAndFetchGrowthEntries() async {
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
      await _fetchGrowthEntries();
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User email or token not found in storage. Please log in.')),
      );
    }
  }

  Future<void> _fetchGrowthEntries() async {
    if (_userEmail == null || _authToken == null) return;

    try {
      final url = 'https://health-tips-backend.onrender.com/vaccinationandgrowth/growthchart/?email=$_userEmail';
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

      // Check if the response is HTML
      if (response.body.trim().startsWith('<!DOCTYPE') || response.body.contains('<html')) {
        throw Exception('Server returned HTML instead of JSON. Please check the server URL and ensure the endpoint is correct.');
      }

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (kDebugMode) {
          print('Parsed response data: $responseData');
        }

        List<Map<String, dynamic>> entries = [];
        if (responseData.containsKey('growthCharts')) {
          entries = List<Map<String, dynamic>>.from(responseData['growthCharts']);
        } else if (responseData.containsKey('message') && responseData['growthCharts'] == null) {
          entries = [];
          if (kDebugMode) {
            print('No growth entries found in response: $responseData');
          }
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No growth entries found: ${responseData['message']}')),
          );
        } else {
          throw Exception('Unexpected response format: "growthEntries" key not found');
        }

        if (kDebugMode) {
          print('Extracted growth entries: $entries');
        }
        setState(() {
          _entries = entries;
        });
      } else {
        final data = jsonDecode(response.body);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load growth entries: ${response.statusCode} - ${data['message']}')),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching growth entries: $e');
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching growth entries: $e')),
      );
    }
  }

  Future<void> _generateGrowthTips(String height, String weight) async {
    setState(() {
      _isFetchingTips = true;
      _growthTips = null;
    });

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
      final prompt = '''
      You are a health assistant providing growth tips for a child based on their height and weight.
      The child's height is $height cm, and their weight is $weight kg.
      Provide 3 concise, practical tips to support healthy growth for this child.
      Format the tips as a numbered list.
      Do not include any medical advice that requires a professional diagnosis.
      Focus on general nutrition, activity, and wellness tips.
      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      if (response.text != null) {
        setState(() {
          _growthTips = response.text;
        });
      } else {
        throw Exception('Failed to generate growth tips: No response from API');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error generating growth tips: $e');
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating growth tips: $e')),
      );
    } finally {
      setState(() {
        _isFetchingTips = false;
      });
    }
  }

  Future<void> _addEntry() async {
    if (_userEmail == null || _authToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User email or token not found in storage. Please log in.')),
      );
      return;
    }

    final height = _heightController.text.trim();
    final weight = _weightController.text.trim();
    if (height.isNotEmpty && weight.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        final entry = {
          'email': _userEmail,
          'height': height,
          'weight': weight,
        };

        final response = await http.post(
          Uri.parse('https://health-tips-backend.onrender.com/vaccinationandgrowth/growthchart'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_authToken',
          },
          body: jsonEncode(entry),
        );

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
            const SnackBar(content: Text('Growth entry saved')),
          );
          _heightController.clear();
          _weightController.clear();
          await _fetchGrowthEntries();

          // Generate growth tips after saving the entry
          await _generateGrowthTips(height, weight);
        } else {
          final data = jsonDecode(response.body);
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save growth entry: ${response.statusCode} - ${data['message']}')),
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error saving growth entry: $e');
        }
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving growth entry: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both height and weight')),
      );
    }
  }

  Widget _buildEntryCard(Map<String, dynamic> entry) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.deepPurple.shade300,
      child: ListTile(
        leading: const Icon(Icons.show_chart, color: Colors.white),
        title: Text('Height: ${entry['height']} cm', style: const TextStyle(color: Colors.white)),
        subtitle: Text('Weight: ${entry['weight']} kg', style: const TextStyle(color: Colors.white70)),
      ),
    );
  }

  Widget _buildGrowthTipsSection() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI-Generated Growth Tips:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (_isFetchingTips)
              const Center(child: CircularProgressIndicator())
            else if (_growthTips != null)
              Text(
                _growthTips!,
                style: const TextStyle(fontSize: 14),
              )
            else
              const Text(
                'Add a growth entry to receive personalized tips.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
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
        title: const Text('Growth Chart'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade200, Colors.deepPurple.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'Track your child\'s growth by adding height and weight entries.',
                style: TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Height (cm)', Icons.height),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Weight (kg)', Icons.monitor_weight),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade900,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Add Entry',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              _buildGrowthTipsSection(),
              const SizedBox(height: 20),
              _entries.isEmpty
                  ? const Center(
                      child: Text(
                        'No growth entries yet.',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    )
                  : Column(
                      children: _entries.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: _buildEntryCard(entry.value),
                        );
                      }).toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}