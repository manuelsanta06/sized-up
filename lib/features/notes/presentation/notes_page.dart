import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteRepository = ref.watch(noteRepositoryProvider);
    return SizedBox.shrink(key: ObjectKey(noteRepository));
  }
}
