import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';

class PeoplePage extends ConsumerWidget {
  const PeoplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personRepository = ref.watch(personRepositoryProvider);
    return SizedBox.shrink(key: ObjectKey(personRepository));
  }
}
