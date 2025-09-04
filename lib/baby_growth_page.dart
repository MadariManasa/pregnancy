import 'package:flutter/material.dart';

class BabyGrowthPage extends StatelessWidget {
  const BabyGrowthPage({super.key});

  Widget _buildGrowthCard(String title, String description, Color color) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text(description,
                style: const TextStyle(fontSize: 16, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baby Growth'),
        backgroundColor: Colors.purple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purpleAccent, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildGrowthCard(
              'Height',
              'Track your baby\'s height growth over time.',
              Colors.deepPurple,
            ),
            const SizedBox(height: 16),
            _buildGrowthCard(
              'Weight',
              'Monitor your baby\'s weight changes.',
              Colors.purpleAccent,
            ),
            const SizedBox(height: 16),
            _buildGrowthCard(
              'Head Circumference',
              'Keep an eye on head circumference development.',
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }
}
