// Home Page

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:password_manager/pages/account.dart';
import 'package:password_manager/pages/view_vault.dart';
import 'package:password_manager/providers/current_user_provider.dart';
import 'package:password_manager/utils/constants.dart';
import 'package:password_manager/utils/icons.dart';
import 'package:password_manager/utils/services.dart';
import 'package:password_manager/widgets/category_row.dart';
import 'package:password_manager/widgets/my_text.dart';
import 'package:password_manager/widgets/search_bar.dart';
import 'package:password_manager/widgets/vault_list.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends ConsumerState<HomePage> {
  // Func to open a Modal Bottom Sheet of Categories while adding new Vault
  void _openCategoryMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 300, // Adjust height as needed
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: ListView.builder(
            itemCount: categoryMap.length - 1,
            itemBuilder: (context, index) {
              final category = categoryMap.keys.elementAt(index);
              final value = categoryMap[category];

              return ListTile(
                // Pop with selected value
                onTap: () => Navigator.pop(
                  context,
                  value['value'],
                ),
                leading: SvgPicture.asset(
                  value['icon'],
                  width: 18,
                  color: Theme.of(context).highlightColor,
                ),
                title: MyText(
                  text: value['value'],
                  fontSize: 20,
                  color: Theme.of(context).highlightColor,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        );
      },
    )
        // After modal is closed
        .then((value) {
      // check if user has selected any category
      if (value != null) {
        // if user has selected a category -> navigate to ViewVaultPage with the chosen category and create mode
        return Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ViewVaultPage(
              category: value,
              mode: VaultMode.create,
            ),
          ),
        );
      }
    });
  }

  // to check local authentication state
  bool _authenticated = false; // todo: change it to false when done development

  @override
  Widget build(context) {
    // if user has not done local authentication
    if (!_authenticated) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        // AppBar
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          surfaceTintColor: Theme.of(context).primaryColor,
          title: MyText(
            text: "Password Manager",
            fontSize: 24,
            color: Theme.of(context).focusColor,
            fontWeight: FontWeight.w600,
          ),
          centerTitle: true,
        ),

        // Body
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Button - Unlock
              ElevatedButton(
                onPressed: () async {
                  final masterPass =
                      ref.read(currentUserProvider)[CurrentUser.masterPass];
                  if (await authenticate(context, masterPass!)) {
                    setState(() {
                      _authenticated = true;
                    });
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 40,
                    ),
                  ),
                ),
                child: const MyText(
                  text: "Unlock",
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 60),

              // Button - Logout
              TextButton(
                onPressed: () {
                  logout(context, ref);
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 40,
                    ),
                  ),
                ),
                child: MyText(
                  text: "Logout",
                  fontSize: 20,
                  color: Theme.of(context).hintColor,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
        ),
      );
    }

    // if user has done the local authentication
    else {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        // Appbar
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: AppBar(
              surfaceTintColor: Colors.transparent,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              leading: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AccountPage(),
                    ),
                  );
                },
                child: Hero(
                  tag: "account",
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage: NetworkImage(
                      ref
                          .watch(currentUserProvider)[CurrentUser.userProfile]
                          .toString(),
                    ),
                  ),
                ),
              ),
              title: Column(
                children: [
                  MyText(
                    text: "Welcome Back",
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).hintColor,
                  ),
                  MyText(
                    text: ref
                        .watch(currentUserProvider)[CurrentUser.name]
                        .toString(),
                    fontSize: 22,
                    color: Theme.of(context).highlightColor,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              centerTitle: true,

              // Button -> Logout
              actions: [
                IconButton(
                  onPressed: () {
                    logout(context, ref);
                  },
                  icon:
                      SvgPicture.asset(icoLogout, width: 24, color: Theme.of(context).highlightColor),
                )
              ],
            ),
          ),
        ),

        // Body
        body: const SizedBox(
          width: double.maxFinite,
          child: Column(
            children: [
              SearchBarWidget(), // Search Bar
              CategoryRow(), // Category Selection Row
              Expanded(child: VaultList()), // Vaults List
            ],
          ),
        ),

        // Button -> Add New Vault
        floatingActionButton: IconButton(
          icon: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.add_rounded,
              size: 32,
              color: Theme.of(context).focusColor,
            ),
          ),
          onPressed: _openCategoryMenu,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    }
  }
}
