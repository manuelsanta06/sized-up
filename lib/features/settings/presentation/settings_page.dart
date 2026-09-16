import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const _options = [
    _SettingsOption(title: 'Appearance', icon: Icons.palette_outlined),
    _SettingsOption(title: 'About', icon: Icons.info_outline),
    _SettingsOption(title: 'Privacy', icon: Icons.lock_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        itemCount: _options.length,
        separatorBuilder: (_, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final option = _options[index];
          final colorScheme = Theme.of(context).colorScheme;

          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: colorScheme.secondaryContainer,
                child: Icon(
                  option.icon,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              title: Text(option.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}

class _SettingsOption {
  const _SettingsOption({required this.title, required this.icon});

  final String title;
  final IconData icon;
}
