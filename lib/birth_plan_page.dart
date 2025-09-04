import 'package:flutter/material.dart';

class BirthPlanPage extends StatefulWidget {
  const BirthPlanPage({super.key});

  @override
  State<BirthPlanPage> createState() => _BirthPlanPageState();
}

class _BirthPlanPageState extends State<BirthPlanPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _preferencesController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _preferencesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _savePlan() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Birth plan saved')),
      );
      _preferencesController.clear();
      _notesController.clear();
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

  Widget _buildPlanInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Birth Plan Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('- Discuss preferences with your doctor'),
        Text('- Include pain management options'),
        Text('- Plan for support persons'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Birth Plan'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepOrangeAccent, Colors.deepOrange],
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
                          controller: _preferencesController,
                          decoration: _inputDecoration('Preferences', Icons.list),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your preferences';
                            }
                            return null;
                          },
                          maxLines: 3,
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
                            onPressed: _savePlan,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
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
                  child: _buildPlanInfo(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
