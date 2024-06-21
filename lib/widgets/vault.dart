// Vault Widget

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:password_manager/pages/view_vault.dart';
import 'package:password_manager/providers/category_provider.dart';
import 'package:password_manager/providers/current_user_provider.dart';
import 'package:password_manager/utils/constants.dart';
import 'package:password_manager/utils/icons.dart';
import 'package:password_manager/utils/images.dart';
import 'package:password_manager/utils/services.dart';
import 'package:password_manager/widgets/my_text.dart';

class Vault extends ConsumerStatefulWidget {
  const Vault({
    super.key,
    required this.vault,
  });

  final QueryDocumentSnapshot vault;

  @override
  ConsumerState<Vault> createState() => _VaultState();
}

class _VaultState extends ConsumerState<Vault> {
  late QueryDocumentSnapshot vault;
  late String thumbnail;

  // initializing values
  @override
  void initState() {
    super.initState();
    vault = widget.vault;

    // setting the appropriate thumbnail based on category
    thumbnail = vault["category"] == categoryMap[Category.passwords]["value"]
        ? passwordThumbnail
        : vault["category"] == categoryMap[Category.banks]["value"]
            ? bankThumbnail
            : vault["category"] == categoryMap[Category.cards]["value"]
                ? cardThumbnail
                : notesThumbnail;
    String title = decryptSecret(
        vault["name"], ref.read(currentUserProvider)[CurrentUser.masterPass]!);
    thumbnail = thumbnailMap.containsKey(title.toLowerCase())
        ? thumbnailMap[title.toLowerCase()]!
        : thumbnail;
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the current brightness of the system.
    final Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
    final bool isLightMode = currentBrightness == Brightness.light;

    return GestureDetector(
      // open ViewVault page of current vault in edit mode
      onTap: () async {
        // get the master password
        final masterPass =
            ref.read(currentUserProvider)[CurrentUser.masterPass];
        // authenticate user and open ViewVaultPage only after successful authentication
        if (await authenticate(context, masterPass!)) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ViewVaultPage(
                vault: vault,
                mode: VaultMode.view,
                category: vault["category"],
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        width: double.infinity,
        height: 90,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Slidable(
          // Todo: Implement share action
          // startActionPane: ActionPane(
          //   motion: DrawerMotion(),
          //   children: [
          //     SlidableAction(
          //       onPressed: (context) {},
          //       label: 'Share',
          //       icon: Icons.share_rounded,
          //       foregroundColor: Theme.of(context).highlightColor,
          //     )
          //   ],
          // ),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                backgroundColor: Theme.of(context).cardColor,
                onPressed: (context) async {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: MyText(
                        text: "Confirm Deletion",
                        fontSize: 20,
                        color: Theme.of(context).highlightColor,
                        fontWeight: FontWeight.w500,
                      ),
                      backgroundColor: Theme.of(context).cardColor,
                      surfaceTintColor: Theme.of(context).cardColor,
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            MyText(
                              text:
                                  'Are you sure you want to delete this item?',
                              fontSize: 16,
                              color: Theme.of(context).highlightColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: MyText(
                            text: 'Cancel',
                            fontSize: 16,
                            color: Theme.of(context).highlightColor,
                            fontWeight: FontWeight.w500,
                          ),
                          onPressed: () =>
                              Navigator.of(context).pop(), // Close dialog
                        ),
                        TextButton(
                          child: MyText(
                            text: 'Delete',
                            fontSize: 16,
                            color: Theme.of(context).highlightColor,
                            fontWeight: FontWeight.w500,
                          ),
                          onPressed: () async {
                            if (await deleteVault(vault!["id"])) {
                              Future.delayed(
                                const Duration(seconds: 0),
                                () {
                                  // Close the dialog
                                  Navigator.of(context).pop();
                                  final cat = ref.read(categoryProvider);
                                  ref
                                      .read(categoryProvider.notifier)
                                      .changeCategory(Category.other);
                                  ref
                                      .read(categoryProvider.notifier)
                                      .changeCategory(cat);
                                },
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Something went wrong"),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
                label: 'Delete',
                icon: Icons.delete_outline_rounded,
                foregroundColor: Colors.red,
              )
            ],
          ),
          child: ClipRect(
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    width: 40,
                    height: 40,
                    color: Theme.of(context).focusColor,
                    child: FadeInImage(
                      placeholder: const AssetImage(placeholder),
                      image: AssetImage(thumbnail),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Name of the Vault
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name of the Vault
                      MyText(
                        text: decryptSecret(
                            vault["name"],
                            ref.read(
                                currentUserProvider)[CurrentUser.masterPass]!),
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).highlightColor,
                      ),

                      // if category -> password then display the username
                      if (vault["category"] ==
                          categoryMap[Category.passwords]["value"])
                        MyText(
                          text: decryptSecret(
                              vault["username"],
                              ref.read(currentUserProvider)[
                                  CurrentUser.masterPass]!),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).hintColor,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // if category -> password then display copy button for copying password
                if (vault["category"] ==
                    categoryMap[Category.passwords]["value"])
                  IconButton(
                    onPressed: () {
                      authAndCopy(
                          decryptSecret(
                              vault["password"],
                              ref.read(currentUserProvider)[
                                  CurrentUser.masterPass]!),
                          context,
                          ref.read(
                              currentUserProvider)[CurrentUser.masterPass]!);
                    },
                    icon: SvgPicture.asset(isLightMode ? icoCopyLight: icoCopyDark),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
