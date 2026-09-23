import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_section.dart';

final searchQueryProvider=NotifierProvider.family<SearchQueryNotifier,String,AppSection>(SearchQueryNotifier.new);

class SearchQueryNotifier extends Notifier<String>{
  SearchQueryNotifier(AppSection _);
  @override
  String build()=>'';
  void update(String query)=>state=query;
  void clear()=>state='';
}
