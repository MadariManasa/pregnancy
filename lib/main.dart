import 'package:abcd/login_page.dart';
import 'package:flutter/material.dart';
import 'nutrition_tracker_page.dart';
import 'appointment_scheduler_page.dart';
import 'symptom_diary_page.dart';
import 'exercise_guide_page.dart';
import 'medication_reminder_page.dart';
import 'weight_tracker_page.dart';
import 'baby_growth_page.dart';
import 'educational_tips_page.dart';
import 'mood_tracker_page.dart';
import 'birth_plan_page.dart';
import 'vaccination_tracker_page.dart';
import 'growth_chart_page.dart';
import 'feeding_schedule_page.dart';
import 'sleep_tracker_page.dart';
import 'milestone_tracker_page.dart';
import 'health_records_page.dart';
import 'allergy_alerts_page.dart';
import 'doctor_appointments_page.dart';
import 'child_medication_reminder_page.dart';
import 'educational_activities_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pregnancy and Childcare App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginPage(),
      
      routes: {
        '/nutrition_tracker': (context) => const NutritionTrackerPage(),
        '/appointment_scheduler': (context) => const AppointmentSchedulerPage(),
        '/symptom_diary': (context) => const SymptomDiaryPage(),
        '/exercise_guide': (context) => const ExerciseGuidePage(),
        '/medication_reminder': (context) => const MedicationReminderPage(),
        '/weight_tracker': (context) => const WeightTrackerPage(),
        '/baby_growth': (context) => const BabyGrowthPage(),
        '/educational_tips': (context) => const EducationalTipsPage(),
        '/mood_tracker': (context) => const MoodTrackerPage(),
        '/birth_plan': (context) => const BirthPlanPage(),
        '/vaccination_tracker': (context) => const VaccinationTrackerPage(),
        '/growth_chart': (context) => const GrowthChartPage(),
        '/feeding_schedule': (context) => const FeedingSchedulePage(),
        '/sleep_tracker': (context) => const SleepTrackerPage(),
        '/milestone_tracker': (context) => const MilestoneTrackerPage(),
        '/health_records': (context) => const HealthRecordsPage(),
        '/allergy_alerts': (context) => const AllergyAlertsPage(),
        '/doctor_appointments': (context) => const DoctorAppointmentsPage(),
        '/child_medication_reminder': (context) => const ChildMedicationReminderPage(),
        '/educational_activities': (context) => const EducationalActivitiesPage(),
      },
    );
  }
}
