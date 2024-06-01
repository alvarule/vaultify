// Categories Row - [All, Passwords, Bank Accounts, ATM Cards, Notes]

import 'package:flutter/material.dart';
import 'package:password_manager/utils/constants.dart';
import 'package:password_manager/widgets/category_widget.dart';

class CategoryRow extends StatelessWidget {
  const CategoryRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          CategoryWidget(
            category: Category.all,
          ),
          SizedBox(width: 8),
          CategoryWidget(
            category: Category.passwords,
          ),
          SizedBox(width: 8),
          CategoryWidget(
            category: Category.banks,
          ),
          SizedBox(width: 8),
          CategoryWidget(
            category: Category.cards,
          ),
          SizedBox(width: 8),
          CategoryWidget(
            category: Category.notes,
          ),
        ],
      ),
    );
  }
}
