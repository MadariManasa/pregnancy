import 'package:flutter/material.dart';

class PregnancyModulePage extends StatelessWidget {
  const PregnancyModulePage({super.key});

  final List<Map<String, dynamic>> features = const [
    {
      'title': 'Nutrition Tracker',
      //'description': 'Track your daily nutrition intake for a healthy pregnancy.',
      'color': Colors.pinkAccent,
      'route': '/nutrition_tracker'
    },
    {
      'title': 'Appointment Scheduler',
      //'description': 'Schedule and manage your prenatal appointments.',
      'color': Colors.deepPurple,
      'route': '/appointment_scheduler'
    },
    {
      'title': 'Symptom Diary',
      //'description': 'Record and monitor pregnancy symptoms over time.',
      'color': Colors.teal,
      'route': '/symptom_diary'
    },
    {
      'title': 'Exercise Guide',
      //'description': 'Safe exercises and routines for pregnancy fitness.',
      'color': Colors.orange,
      'route': '/exercise_guide'
    },
    {
      'title': 'Medication Reminder',
      //'description': 'Set reminders for your medications and supplements.',
      'color': Colors.blueAccent,
      'route': '/medication_reminder'
    },
  ];

  void _onFeatureTap(BuildContext context, String? route) {
    if (route != null && route.isNotEmpty) {
      Navigator.pushNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pregnancy Module'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: features.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisSpacing: 12,
            childAspectRatio: 5,
          ),
          itemBuilder: (context, index) {
            final feature = features[index];
            return GestureDetector(
              onTap: () => _onFeatureTap(context, feature['route'] as String?),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: feature['color'],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: feature['color'].withOpacity(0.6),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.info, color: Colors.white, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            feature['title'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            feature['description'] ?? '',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white70),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
