// Category Widget

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:password_manager/providers/category_provider.dart';
import 'package:password_manager/utils/colors.dart';
import 'package:password_manager/utils/constants.dart';
import 'package:password_manager/widgets/my_text.dart';

class CategoryWidget extends ConsumerWidget {
  const CategoryWidget({
    super.key,
    required this.category,
  });

  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCategory = ref.watch(categoryProvider);

    return TextButton.icon(
      // change the currently selected category using categoryProvider
      onPressed: () {
        ref.read(categoryProvider.notifier).changeCategory(category);
      },
      icon: SvgPicture.asset(
        categoryMap[category]["icon"],
        width: 12,
        color: currentCategory == category ? white : secondary,
      ),
      label: MyText(
        text: categoryMap[category]["value"],
        fontSize: 14,
        color: currentCategory == category ? white : secondary,
      ),
      style: TextButton.styleFrom(
        backgroundColor: currentCategory == category ? primary : white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
