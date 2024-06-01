// Vault List Widget

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:password_manager/pages/splash.dart';
import 'package:password_manager/providers/category_provider.dart';
import 'package:password_manager/providers/current_user_provider.dart';
import 'package:password_manager/providers/search_provider.dart';
import 'package:password_manager/utils/colors.dart';
import 'package:password_manager/utils/constants.dart';
import 'package:password_manager/utils/services.dart';
import 'package:password_manager/widgets/my_text.dart';
import 'package:password_manager/widgets/vault.dart';

class VaultList extends ConsumerStatefulWidget {
  const VaultList({super.key});

  @override
  ConsumerState<VaultList> createState() => _VaultListState();
}

class _VaultListState extends ConsumerState<VaultList> {
  // Function to returned a filtered list of vault items based on the current search query
  List<QueryDocumentSnapshot<Map<String, dynamic>>> filterVaults(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> data,
    String query,
  ) {
    // if query is empty
    if (query == "") {
      return data;
    }

    // if query is not empty
    else {
      final lowercaseQuery = query.toLowerCase();
      final filteredData = data.where((snapshot) {
        final docData = snapshot.data();
        return docData.entries.any((entry) {
          String field = entry.key.toString().toLowerCase();
          
          if (field == "name" || field == "username") {
            // first decryption of the field value is needed
            String masterPass =
                ref.read(currentUserProvider)[CurrentUser.masterPass]!;
            return decryptSecret(entry.value, masterPass)
                .toLowerCase()
                .contains(lowercaseQuery);
          }

          // for other entry fields
          else {
            return false;
          }
        });
      }).toList();
      return filteredData;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

      // StreamBuilder for fetching the Vault items of the currently logged in user from Firebase Firestore
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("Vault")
            .where("uid",
                isEqualTo: ref.read(currentUserProvider)[CurrentUser.uid])
            .orderBy("category", descending: true)
            .snapshots(),
        builder: (ctx, snapshot) {
          // if error occurred during fetching Vault items
          if (snapshot.hasError) {
            return const Center(
              child: MyText(
                text: "Some Error Occurred",
                fontSize: 20,
                color: secondary,
                fontWeight: FontWeight.w500,
                textAlign: TextAlign.center,
              ),
            );
          }

          // if vault items are loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          // after successfully fetching vault items
          if (snapshot.hasData) {
            final vaultItems = snapshot.data!.docs;

            // filtering vault items based on search query
            String query = ref.watch(searchProvider);
            final filteredVaultItems = filterVaults(vaultItems, query);

            // if Vault of current user is empty or if Search query does not match any vault item
            if (filteredVaultItems.isEmpty) {
              final q = ref.watch(searchProvider);
              return Center(
                child: MyText(
                  text: q == ""
                      ? "Your Vault is Empty"
                      : "No Vault Match Your Search",
                  fontSize: 20,
                  color: secondary,
                  fontWeight: FontWeight.w500,
                  textAlign: TextAlign.center,
                ),
              );
            }

            // if Vault of current user is not empty or search query matches any vault items
            else {
              return ListView.builder(
                // Add one for the empty item at the last just for some spacing
                itemCount: filteredVaultItems.length + 1,
                itemBuilder: (context, index) {
                  // getting the currently selected cateoory
                  final category = ref.watch(categoryProvider);

                  // for last extra item for some spacing
                  if (index == filteredVaultItems.length) {
                    // if no items exists for the selected category
                    if (category != Category.all &&
                        filteredVaultItems.every(
                          (vault) =>
                              vault["category"] !=
                              categoryMap[category]["value"],
                        )) {
                      return const Center(
                        child: MyText(
                          text: 'No vault found in this category.',
                          fontSize: 20,
                          color: secondary,
                        ),
                      );
                    }
                    //
                    else {
                      // Spacer for bottom
                      return const SizedBox(height: 80);
                    }
                  }

                  // if items exists for current category
                  else {
                    final vault = filteredVaultItems[index];
                    // if current category -> All then display all items
                    if (category == Category.all) {
                      return Vault(vault: vault);
                    }

                    // else display items of the current category only
                    else if (vault["category"] ==
                        categoryMap[category]["value"]) {
                      return Vault(vault: vault);
                    }

                    // Hidden item for other categories
                    else {
                      return Container();
                    }
                  }
                },
              );
            }
          }

          // Exceptional Case (never gonna occur)
          return const Center(
            child: MyText(
              text: "Exceptional Case",
              fontSize: 20,
              color: secondary,
              fontWeight: FontWeight.w500,
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }
}
