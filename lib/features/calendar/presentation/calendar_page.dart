import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarRepository = ref.watch(calendarEventRepositoryProvider);
    return SizedBox.shrink(key: ObjectKey(calendarRepository));
  }
}
