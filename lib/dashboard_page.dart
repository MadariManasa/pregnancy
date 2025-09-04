import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'help_page.dart';
import 'contacts_page.dart';
import 'pregnancy_module_page.dart';
import 'child_module_page.dart';
import 'login_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Widget _buildDashboardCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: color,
        child: SizedBox(
          height: 120,
          child: Center(
            child: ListTile(
              leading: Icon(icon, size: 48, color: Colors.white),
              title: Text(title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.indigo,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade400, Colors.indigo.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: GridView.count(
          padding: const EdgeInsets.all(16.0),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: <Widget>[
            _buildDashboardCard('Profile', Icons.person, Colors.deepPurple, () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
            }),
            _buildDashboardCard('Help', Icons.help, Colors.teal, () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HelpPage()));
            }),
            _buildDashboardCard('Contact', Icons.contacts, Colors.green, () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ContactsPage()));
            }),
            _buildDashboardCard('Pregnancy Module', Icons.pregnant_woman, Colors.pink, () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PregnancyModulePage()));
            }),
            _buildDashboardCard('Child Module', Icons.child_care, Colors.orange, () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChildModulePage()));
            }),
            // Removed Vaccination Tracker and Sleep Tracker as requested
            _buildDashboardCard('Logout', Icons.logout, Colors.red, () {
              _showLogoutDialog(context);
            }),
          ],
        ),
      ),
    );
  }
}
