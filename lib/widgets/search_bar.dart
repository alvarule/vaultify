// Search Bar Widget

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:password_manager/providers/search_provider.dart';
import 'package:password_manager/utils/colors.dart';

class SearchBarWidget extends ConsumerStatefulWidget {
  const SearchBarWidget({super.key});

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  // Todo: Implement Search Functionality
  TextEditingController searchController = TextEditingController();

  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: secondary60),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                ref.read(searchProvider.notifier).updateQuery(value);
              },
              decoration: InputDecoration(
                hintStyle: GoogleFonts.outfit(
                  color: secondary60,
                ),
                hintText: "Search your vaults",
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              searchController.clear();
              ref.read(searchProvider.notifier).updateQuery("");
            },
            icon: const Icon(Icons.clear, color: secondary60),
          ),
        ],
      ),
    );
  }
}
