import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../navigation/app_section.dart';
import '../../../navigation/search_query_provider.dart';

class PeoplePage extends ConsumerWidget {
  const PeoplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personRepository = ref.watch(personRepositoryProvider);
    final query=ref.watch(searchQueryProvider(AppSection.people));
    return SizedBox.shrink(key:ObjectKey((personRepository,query)));
  }
}
