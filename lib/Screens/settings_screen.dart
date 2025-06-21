// import 'package:flutter/material.dart';
//
// class SettingsScreen extends StatefulWidget {
//   @override
//   _SettingsScreenState createState() => _SettingsScreenState();
// }
//
// class _SettingsScreenState extends State<SettingsScreen> {
//   bool isDarkMode = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Settings")),
//       body: ListView(
//         children: [
//           SwitchListTile(
//             title: Text("Dark Mode"),
//             value: isDarkMode,
//             onChanged: (value) {
//               setState(() {
//                 isDarkMode = value;
//               });
//             },
//           ),
//           ListTile(
//             title: Text("Privacy Policy"),
//             onTap: () {
//               // Add navigation or alert
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;

  void _toggleDarkMode(bool value) {
    setState(() {
      isDarkMode = value;
      // TODO: Implement app-wide theme change logic
      // For example: use Provider or Bloc to update theme mode
    });
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Privacy Policy"),
        content: Text(
            "This is a sample privacy policy. You can replace this with your actual policy."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: Text("Dark Mode"),
            value: isDarkMode,
            onChanged: _toggleDarkMode,
            secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text("Privacy Policy"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showPrivacyPolicyDialog,
          ),
        ],
      ),
    );
  }
}
