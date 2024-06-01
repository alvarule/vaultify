// Stores the current selected Category of Vault items to be displayed in the list
// Stores the Category Enum value

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:password_manager/utils/constants.dart';

class CategoryNotifier extends StateNotifier<Enum> {
  CategoryNotifier() : super(Category.passwords);

  void changeCategory(Enum cat) {
    state = cat;
  }
}

final categoryProvider = StateNotifierProvider<CategoryNotifier, Enum>(
  (ref) => CategoryNotifier(),
);
