import 'package:flutter/material.dart';

enum AppSection { calendar, notes, people }

extension AppSectionDetails on AppSection {
  String get title => switch (this) {
    AppSection.calendar => 'Calendar',
    AppSection.notes => 'Notes',
    AppSection.people => 'People',
  };

  String get description => switch (this) {
    AppSection.calendar => 'Keep your days in view.',
    AppSection.notes => 'Capture what matters.',
    AppSection.people => 'Stay close to your people.',
  };

  IconData get icon => switch (this) {
    AppSection.calendar => Icons.calendar_today_outlined,
    AppSection.notes => Icons.sticky_note_2_outlined,
    AppSection.people => Icons.people_outline,
  };

  IconData get selectedIcon => switch (this) {
    AppSection.calendar => Icons.calendar_today,
    AppSection.notes => Icons.sticky_note_2,
    AppSection.people => Icons.people,
  };
}
