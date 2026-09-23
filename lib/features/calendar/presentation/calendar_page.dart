import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../navigation/app_section.dart';
import '../../../navigation/search_query_provider.dart';

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarRepository = ref.watch(calendarEventRepositoryProvider);
    final query=ref.watch(searchQueryProvider(AppSection.calendar));
    return SizedBox.shrink(key:ObjectKey((calendarRepository,query)));
  }
}
