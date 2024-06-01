// Stores the current search query

import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchNotifier extends StateNotifier<String> {
  SearchNotifier() : super("");

  void updateQuery(String query) {
    state = query;
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, String>(
  (ref) => SearchNotifier(),
);
