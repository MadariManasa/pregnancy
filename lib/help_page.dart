import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  final List<Map<String, String>> faqs = const [
    {
      'question': 'What is pregnancy?',
      'answer': 'Pregnancy is the period during which a fetus develops inside a woman\'s womb.'
    },
    {
      'question': 'How to maintain a healthy pregnancy?',
      'answer': 'Eat a balanced diet, exercise regularly, and attend prenatal checkups.'
    },
    {
      'question': 'What are common pregnancy symptoms?',
      'answer': 'Nausea, fatigue, frequent urination, and mood swings are common symptoms.'
    },
    {
      'question': 'When should I see a doctor during pregnancy?',
      'answer': 'Regularly, and immediately if you experience severe pain or bleeding.'
    },
    {
      'question': 'What prenatal vitamins should I take?',
      'answer': 'Folic acid, iron, and calcium are commonly recommended.'
    },
    {
      'question': 'Can I exercise during pregnancy?',
      'answer': 'Yes, but consult your doctor for suitable exercises.'
    },
    {
      'question': 'What foods should I avoid during pregnancy?',
      'answer': 'Avoid raw fish, unpasteurized dairy, and excessive caffeine.'
    },
    {
      'question': 'How much weight should I gain?',
      'answer': 'It varies, but typically 25-35 pounds for normal weight women.'
    },
    {
      'question': 'What is prenatal care?',
      'answer': 'Medical care during pregnancy to ensure health of mother and baby.'
    },
    {
      'question': 'How to manage morning sickness?',
      'answer': 'Eat small meals, stay hydrated, and rest as needed.'
    },
    {
      'question': 'What are signs of labor?',
      'answer': 'Regular contractions, water breaking, and lower back pain.'
    },
    {
      'question': 'Can I travel during pregnancy?',
      'answer': 'Consult your doctor; generally safe in second trimester.'
    },
    {
      'question': 'What is gestational diabetes?',
      'answer': 'Diabetes that develops during pregnancy and usually resolves after birth.'
    },
    {
      'question': 'How to prepare for childbirth?',
      'answer': 'Attend classes, create a birth plan, and pack a hospital bag.'
    },
    {
      'question': 'When to call emergency services?',
      'answer': 'If you have heavy bleeding, severe pain, or decreased fetal movement.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help - FAQs'),
      ),
      body: ListView.builder(
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return ExpansionTile(
            title: Text(faq['question']!),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(faq['answer']!),
              ),
            ],
          );
        },
      ),
    );
  }
}
