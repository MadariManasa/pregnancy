import 'package:flutter/material.dart';

class EducationalActivitiesPage extends StatefulWidget {
  const EducationalActivitiesPage({super.key});

  @override
  State<EducationalActivitiesPage> createState() => _EducationalActivitiesPageState();
}

class _EducationalActivitiesPageState extends State<EducationalActivitiesPage> {
  final TextEditingController _activityController = TextEditingController();
  final List<String> _activities = [];

  void _addActivity() {
    final activity = _activityController.text.trim();
    if (activity.isNotEmpty) {
      setState(() {
        _activities.add(activity);
        _activityController.clear();
      });
    }
  }

  Widget _buildActivityCard(String activity) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.lightBlue.shade300,
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.white),
        title: Text(activity, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Educational Activities'),
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
            const Text(
              'Add educational activities for your child to encourage learning and development.',
              style: TextStyle(fontSize: 16, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _activityController,
              decoration: InputDecoration(
                labelText: 'New Activity',
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
                onPressed: _addActivity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue.shade900,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Add Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _activities.isEmpty
                  ? const Center(
                      child: Text(
                        'No activities added yet.',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _activities.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return _buildActivityCard(_activities[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
