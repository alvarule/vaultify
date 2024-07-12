// Generate Password Widget

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:password_manager/pages/view_vault.dart';
import 'package:password_manager/utils/constants.dart';
import 'package:password_manager/utils/icons.dart';
import 'package:password_manager/utils/services.dart';
import 'package:password_manager/widgets/my_text.dart';

class GeneratePasswordCard extends ConsumerStatefulWidget {
  const GeneratePasswordCard({super.key});

  @override
  ConsumerState<GeneratePasswordCard> createState() =>
      _GeneratePasswordCardState();
}

class _GeneratePasswordCardState extends ConsumerState<GeneratePasswordCard> {
  String _generatedPassword = '';

  // customizations to modify the generated password
  double _passwordLength = 12;
  bool _includeLowercase = true;
  bool _includeUppercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;

  // Function to generate password
  void _generatePassword() {
    final length = _passwordLength.toInt(); // length of password to generate
    final random = Random(); // for generating random password

    // set of characters to use while password generation
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    const symbols = '!@#\$%^&*()-_=+[]{}|;:",.<>?/';

    // current character pool to use for password generation
    String charPool = '';

    // modifying the character pool based on the current selected customization
    if (_includeLowercase) charPool += lowercase;
    if (_includeUppercase) charPool += uppercase;
    if (_includeNumbers) charPool += numbers;
    if (_includeSymbols) charPool += symbols;

    // generating the password
    String password = '';
    for (int i = 0; i < length; i++) {
      password += charPool[random.nextInt(charPool.length)];
    }

    setState(() {
      _generatedPassword = password;
    });
  }

  // Function to toggle the customization selection
  void _onCheckboxChanged(bool? newValue, int index) {
    setState(() {
      switch (index) {
        case 0:
          _includeLowercase = newValue!;
          break;
        case 1:
          _includeUppercase = newValue!;
          break;
        case 2:
          _includeNumbers = newValue!;
          break;
        case 3:
          _includeSymbols = newValue!;
          break;
      }

      // Ensure at least one option is always selected
      if (!_includeLowercase &&
          !_includeUppercase &&
          !_includeNumbers &&
          !_includeSymbols) {
        switch (index) {
          case 0:
            _includeLowercase = true;
            break;
          case 1:
            _includeUppercase = true;
            break;
          case 2:
            _includeNumbers = true;
            break;
          case 3:
            _includeSymbols = true;
            break;
        }
      }
    });

    _generatePassword();
  }

  @override
  void initState() {
    super.initState();
    // Schedule the state update to happen after the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generatePassword();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the current brightness of the system.
    final Brightness currentBrightness =
        MediaQuery.of(context).platformBrightness;
    final bool isLightMode = currentBrightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Title Text - Generate Password
            MyText(
              text: "Generate Secure Password",
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).highlightColor,
            ),
            const SizedBox(height: 60),
            
            const Divider(thickness: 2),

            // Generated Password
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          MyText(
                              text: _generatedPassword,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).highlightColor),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(thickness: 2),

            // Icons - Regenerate and Copy Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.restart_alt_rounded,
                    color: Theme.of(context).hintColor,
                  ),
                  onPressed: () {
                    _generatePassword();
                  },
                ),
                IconButton(
                  icon: SvgPicture.asset(
                    isLightMode ? icoCopyLight : icoCopyDark,
                    width: 24,
                  ),
                  onPressed: () {
                    copyToClipboard(_generatedPassword, context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 60),

            // Password Length Slider
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: MyText(
                    text: 'Length: ${_passwordLength.toInt()}',
                    fontSize: 20,
                    color: Theme.of(context).highlightColor),
              ),
            ),
            Slider(
              value: _passwordLength,
              min: 8,
              max: 100,
              divisions: 100,
              thumbColor: Theme.of(context).primaryColor,
              activeColor: Theme.of(context).primaryColor,
              overlayColor:
                  WidgetStateProperty.all(Theme.of(context).primaryColorLight),
              onChanged: (value) {
                setState(() {
                  _passwordLength = value;
                });
                _generatePassword();
              },
            ),

            // Switch Button - for lowercase character set
            SwitchListTile(
              title: MyText(
                  text: 'Include Lowercase',
                  fontSize: 20,
                  color: Theme.of(context).highlightColor),
              activeColor: Theme.of(context).primaryColor,
              value: _includeLowercase,
              onChanged: (newValue) {
                _onCheckboxChanged(newValue, 0);
              },
            ),

            // Switch Button - for uppercase character set
            SwitchListTile(
              title: MyText(
                  text: 'Include Uppercase',
                  fontSize: 20,
                  color: Theme.of(context).highlightColor),
              activeColor: Theme.of(context).primaryColor,
              value: _includeUppercase,
              onChanged: (newValue) {
                _onCheckboxChanged(newValue, 1);
              },
            ),

            // Switch Button - for number character set
            SwitchListTile(
              title: MyText(
                  text: 'Include Numbers',
                  fontSize: 20,
                  color: Theme.of(context).highlightColor),
              activeColor: Theme.of(context).primaryColor,
              value: _includeNumbers,
              onChanged: (newValue) {
                _onCheckboxChanged(newValue, 2);
              },
            ),

            // Switch Button - for symbol character set
            SwitchListTile(
              title: MyText(
                  text: 'Include Symbols',
                  fontSize: 20,
                  color: Theme.of(context).highlightColor),
              activeColor: Theme.of(context).primaryColor,
              value: _includeSymbols,
              onChanged: (newValue) {
                _onCheckboxChanged(newValue, 3);
              },
            ),
            const Expanded(child: SizedBox()),

            // Button - Save
            SizedBox(
              width: double.infinity,
              height: 60,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ViewVaultPage(
                        category: categoryMap[Category.passwords]["value"],
                        mode: VaultMode.create,
                        generatedPassword: _generatedPassword,
                      ),
                    ),
                  );
                },
                style: ButtonStyle(
                  padding: WidgetStateProperty.all<EdgeInsets>(
                    const EdgeInsets.symmetric(vertical: 12),
                  ),
                  backgroundColor: WidgetStateProperty.all<Color>(
                      Theme.of(context).primaryColor),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  foregroundColor: WidgetStateProperty.all<Color>(
                      Theme.of(context).focusColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyText(
                      text: "Save Password",
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).focusColor,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
