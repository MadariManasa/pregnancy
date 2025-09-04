import 'package:flutter/material.dart';

class ChildModulePage extends StatelessWidget {
  const ChildModulePage({super.key});

  final List<Map<String, dynamic>> features = const [
    {
      'title': 'Vaccination Tracker',
      //'description': 'Keep track of your child’s vaccination schedule and records.',
      'color': Colors.blueAccent,
      'route': '/vaccination_tracker'
    },
    {
      'title': 'Growth Chart',
      //'description': 'Monitor your child’s growth and development over time.',
      'color': Colors.green,
      'route': '/growth_chart'
    },
    {
      'title': 'Allergy Alerts',
      //'description': 'Manage and get alerts for your child’s allergies.',
      'color': Colors.cyan,
      'route': '/allergy_alerts'
    },
    {
      'title': 'Doctor Appointments',
      //'description': 'Schedule and manage your child’s doctor visits.',
      'color': Colors.indigo,
      'route': '/doctor_appointments'
    },
    {
      'title': 'Medication Reminder',
      // 'description': 'Set reminders for your child’s medications.',
      'color': Colors.pinkAccent,
      'route': '/child_medication_reminder'
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
        title: const Text('Child Module'),
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
