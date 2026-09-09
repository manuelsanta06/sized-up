import 'package:flutter/material.dart';

class QuickAction {
  const QuickAction({
    required this.label,
    required this.description,
    required this.icon,
  });

  final String label;
  final String description;
  final IconData icon;
}
