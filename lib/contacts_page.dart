import 'package:flutter/material.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  Widget _buildContactCard(String name, String phone, IconData icon, Color color) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color,
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.white),
        title: Text(name,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Text(phone, style: const TextStyle(color: Colors.white70)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade300, Colors.green.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildContactCard('Pediatrician', '123-456-7890', Icons.local_hospital, Colors.teal),
            const SizedBox(height: 16),
            _buildContactCard('Family Doctor', '098-765-4321', Icons.person, Colors.blue),
            const SizedBox(height: 16),
            _buildContactCard('Emergency', '911', Icons.warning, Colors.red),
          ],
        ),
      ),
    );
  }
}
