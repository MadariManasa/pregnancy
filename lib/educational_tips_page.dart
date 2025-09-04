import 'package:flutter/material.dart';

class EducationalTipsPage extends StatefulWidget {
  const EducationalTipsPage({super.key});

  @override
  State<EducationalTipsPage> createState() => _EducationalTipsPageState();
}

class _EducationalTipsPageState extends State<EducationalTipsPage> {
  final TextEditingController _tipController = TextEditingController();
  final List<String> _tips = [
    'Ensure a balanced diet rich in vitamins and minerals.',
    'Maintain a regular sleep schedule for better health.',
    'Engage in safe and moderate physical activity.',
  ];

  void _addTip() {
    final tip = _tipController.text.trim();
    if (tip.isNotEmpty) {
      setState(() {
        _tips.add(tip);
        _tipController.clear();
      });
    }
  }

  Widget _buildTipCard(String tip) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.lightBlue,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          tip,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEducationalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Educational Tips Info:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 8),
        Text('- Regularly update your knowledge on pregnancy and childcare.', style: TextStyle(color: Colors.white)),
        Text('- Consult reliable sources and healthcare professionals.', style: TextStyle(color: Colors.white)),
        Text('- Share tips with your support network.', style: TextStyle(color: Colors.white)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Educational Tips'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade200, Colors.lightBlue.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _tipController,
              decoration: InputDecoration(
                labelText: 'Add a new tip',
                prefixIcon: const Icon(Icons.add),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addTip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue.shade900,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Add Tip',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: _tips.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildTipCard(_tips[index]);
                },
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.blueAccent,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildEducationalInfo(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
