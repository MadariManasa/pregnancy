  import 'package:flutter/material.dart';

class ExerciseGuidePage extends StatelessWidget {
  const ExerciseGuidePage({super.key});

  final Map<String, Map<String, dynamic>> exerciseDetails = const {
    'Prenatal Yoga': {
      'tips': [
        'Practice deep breathing to relax.',
        'Focus on gentle stretching and avoid overstretching.',
        'Use props like blocks and straps for support.',
        'Maintain proper alignment to avoid strain.',
        'Stay hydrated and listen to your body.',
      ],
      'poses': [
        {
          'name': 'Cat-Cow Pose',
          'description': 'Helps stretch the back and relieve tension.',
        },
        {
          'name': 'Warrior II Pose',
          'description': 'Strengthens legs and improves balance.',
        },
        {
          'name': 'Child\'s Pose',
          'description': 'Provides gentle stretch and relaxation.',
        },
        {
          'name': 'Seated Forward Bend',
          'description': 'Stretches the spine and hamstrings.',
        },
        {
          'name': 'Bridge Pose',
          'description': 'Strengthens the back and pelvic muscles.',
        },
      ],
    },
    'Pelvic Floor Exercises': {
      'tips': [
        'Perform exercises regularly for best results.',
        'Focus on slow and controlled muscle contractions.',
        'Avoid holding your breath during exercises.',
        'Maintain good posture during exercises.',
        'Gradually increase repetitions over time.',
      ],
      'poses': [
        {
          'name': 'Kegel Exercises',
          'description': 'Strengthens pelvic floor muscles.',
        },
        {
          'name': 'Bridge Pose',
          'description': 'Engages pelvic muscles and glutes.',
        },
        {
          'name': 'Squats',
          'description': 'Strengthens pelvic and leg muscles.',
        },
        {
          'name': 'Happy Baby Pose',
          'description': 'Stretches the hips and relaxes pelvic muscles.',
        },
        {
          'name': 'Pelvic Tilts',
          'description': 'Improves pelvic mobility and strength.',
        },
      ],
    },
    'Walking': {
      'tips': [
        'Maintain a steady pace for cardiovascular benefits.',
        'Wear comfortable shoes to avoid injury.',
        'Incorporate intervals of brisk walking for intensity.',
        'Keep your posture upright and shoulders relaxed.',
        'Swing your arms naturally to increase workout efficiency.',
      ],
      'poses': [
        {
          'name': 'Brisk Walking',
          'description': 'Increases heart rate and endurance.',
        },
        {
          'name': 'Interval Walking',
          'description': 'Alternates between fast and slow pace.',
        },
        {
          'name': 'Hill Walking',
          'description': 'Builds strength and stamina.',
        },
        {
          'name': 'Walking Lunges',
          'description': 'Strengthens legs and improves balance.',
        },
        {
          'name': 'Side Steps',
          'description': 'Improves lateral movement and hip strength.',
        },
      ],
    },
  };

  void _showExerciseDetails(BuildContext context, String exercise) {
    final details = exerciseDetails[exercise];
    if (details == null) return;

    showDialog(
      context: context,
      builder: (context) {
        final tips = details['tips'] as List<String>;
        final poses = details['poses'] as List<dynamic>;

        return AlertDialog(
          title: Text(exercise),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...tips.map((tip) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('- $tip'),
                    )),
                const SizedBox(height: 12),
                const Text('Poses/Exercises:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...poses.map((pose) {
                  final name = pose['name'] as String;
                  final description = pose['description'] as String;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(description),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExerciseOption(BuildContext context, String title, Color color) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color,
      child: ListTile(
        title: Text(title,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        onTap: () => _showExerciseDetails(context, title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Guide'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.greenAccent, Colors.green],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildExerciseOption(context, 'Prenatal Yoga', Colors.teal),
            const SizedBox(height: 16),
            _buildExerciseOption(context, 'Walking', Colors.lightGreen),
            const SizedBox(height: 16),
            _buildExerciseOption(context, 'Pelvic Floor Exercises', Colors.greenAccent),
          ],
        ),
      ),
    );
  }
}
