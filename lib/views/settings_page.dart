import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Account (Coming Soon)'),
          ),
          ListTile(
            leading: Icon(Icons.cloud_upload_outlined),
            title: Text('Backup & Restore'),
          ),
        ],
      ),
    );
  }
}
