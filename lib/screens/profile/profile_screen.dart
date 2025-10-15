import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('Farmer John'),
            subtitle: Text('07XX XXX XXX'),
          ),
          const Divider(),
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('Language: English'),
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Sync Now'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Manage Offline Content'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {},
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {},
            child: const Text('Logout'),
          )
        ],
      ),
    );
  }
}