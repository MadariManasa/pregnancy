import 'package:flutter/material.dart';

class SleepTrackerPage extends StatefulWidget {
  const SleepTrackerPage({super.key});

  @override
  State<SleepTrackerPage> createState() => _SleepTrackerPageState();
}

class _SleepTrackerPageState extends State<SleepTrackerPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _sleepDurationController = TextEditingController();
  final TextEditingController _sleepQualityController = TextEditingController();
  final TextEditingController _bedtimeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _sleepDurationController.dispose();
    _sleepQualityController.dispose();
    _bedtimeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sleep entry saved')),
      );
      _sleepDurationController.clear();
      _sleepQualityController.clear();
      _bedtimeController.clear();
      _notesController.clear();
    }
  }

  Widget _buildSleepTipsTable() {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Age')),
        DataColumn(label: Text('Recommended Sleep Duration')),
      ],
      rows: const [
        DataRow(cells: [DataCell(Text('0-3 months')), DataCell(Text('14-17 hours'))]),
        DataRow(cells: [DataCell(Text('4-11 months')), DataCell(Text('12-15 hours'))]),
        DataRow(cells: [DataCell(Text('1-2 years')), DataCell(Text('11-14 hours'))]),
      ],
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
            Text('Q: How much sleep does my child need?'),
            Text('A: It varies by age; refer to the recommended durations above.'),
            SizedBox(height: 8),
            Text('Q: What if my child has trouble sleeping?'),
            Text('A: Establish a consistent bedtime routine and consult a pediatrician if needed.'),
            SizedBox(height: 8),
            Text('Q: Can naps affect nighttime sleep?'),
            Text('A: Yes, balance daytime naps to ensure good nighttime sleep.'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Tracker'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _sleepDurationController,
                    decoration: const InputDecoration(labelText: 'Sleep Duration (hours)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter sleep duration';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _sleepQualityController,
                    decoration: const InputDecoration(labelText: 'Sleep Quality (Good, Fair, Poor)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter sleep quality';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _bedtimeController,
                    decoration: const InputDecoration(labelText: 'Bedtime'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter bedtime';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(labelText: 'Notes'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveEntry,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Recommended Sleep Duration',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _buildSleepTipsTable(),
                  ],
                ),
              ),
            ),
            _buildFAQSection(),
          ],
        ),
      ),
    );
  }
}
