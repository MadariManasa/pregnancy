import 'package:flutter/material.dart';

class WeightTrackerPage extends StatefulWidget {
  const WeightTrackerPage({super.key});

  @override
  State<WeightTrackerPage> createState() => _WeightTrackerPageState();
}

class _WeightTrackerPageState extends State<WeightTrackerPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveWeight() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weight entry saved')),
      );
      _weightController.clear();
      _dateController.clear();
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

  Widget _buildWeightInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Weight Tracker Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('- Track weight regularly'),
        Text('- Maintain a healthy diet'),
        Text('- Consult doctor if unusual changes occur'),
        SizedBox(height: 8),
        Text('Additional Info:'),
        Text('- Weight gain varies during pregnancy stages.'),
        Text('- Monitor trends rather than daily fluctuations.'),
        Text('- Use this tracker to discuss progress with your healthcare provider.'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight Tracker'),
        backgroundColor: Colors.brown,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.brown, Colors.brown.shade300],
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
                          controller: _weightController,
                          decoration: _inputDecoration('Weight (kg)', Icons.monitor_weight),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter weight';
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
                          controller: _notesController,
                          decoration: _inputDecoration('Notes', Icons.note),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveWeight,
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
                  child: _buildWeightInfo(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
