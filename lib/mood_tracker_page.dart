import 'package:flutter/material.dart';

class MoodTrackerPage extends StatefulWidget {
  const MoodTrackerPage({super.key});

  @override
  State<MoodTrackerPage> createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  final TextEditingController _moodController = TextEditingController();
  final List<String> _moods = [];

  void _addMood() {
    final mood = _moodController.text.trim();
    if (mood.isNotEmpty) {
      setState(() {
        _moods.add(mood);
        _moodController.clear();
      });
    }
  }

  Widget _buildMoodCard(String mood) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.pink.shade300,
      child: ListTile(
        leading: const Icon(Icons.mood, color: Colors.white),
        title: Text(mood, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        backgroundColor: Colors.pink,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.shade200, Colors.pink.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Track your moods by adding daily entries.',
              style: TextStyle(fontSize: 16, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _moodController,
              decoration: InputDecoration(
                labelText: 'New Mood',
                prefixIcon: const Icon(Icons.mood),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addMood,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade900,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Add Mood',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _moods.isEmpty
                  ? const Center(
                      child: Text(
                        'No mood entries yet.',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _moods.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return _buildMoodCard(_moods[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
