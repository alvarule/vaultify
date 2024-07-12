import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

import 'package:password_manager/providers/category_provider.dart';
import 'package:password_manager/providers/current_user_provider.dart';
import 'package:password_manager/utils/constants.dart';
import 'package:password_manager/widgets/input_box.dart';
import 'package:password_manager/widgets/my_text.dart';

// Function to copy contents to clipboard
Future<void> copyToClipboard(String text, BuildContext context) async {
  await Clipboard.setData(ClipboardData(text: text));

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Copied to clipboard"),
    ),
  );
}

// Function to encrypt secrets
String encryptSecret(String secret, String key) {
  // if the secret is empty secret
  if (secret == "") {
    return secret;
  }

  final encryptionKey =
      encrypt.Key.fromUtf8(key.substring(0, 32)); // solve error -> key length
  final iv = encrypt.IV.fromLength(0);

  final encrypter = encrypt.Encrypter(encrypt.AES(encryptionKey));

  // print(secret);
  // print(encryptionKey.base16);

  final encrypted = encrypter.encrypt(secret, iv: iv);

  // print(encrypted.base16);

  return encrypted.base16;
}

// Function to decrypt secrets
String decryptSecret(String encrypted, String key) {
  // if the encrypted is empty
  if (encrypted == "") {
    return encrypted;
  }

  final encryptionKey =
      encrypt.Key.fromUtf8(key.substring(0, 32)); // solve error -> key length
  final iv = encrypt.IV.fromLength(0);

  final decrypter = encrypt.Encrypter(encrypt.AES(encryptionKey));

  final decrypted = decrypter.decrypt16(encrypted, iv: iv);

  // print(decrypted);

  return decrypted;
}

// Function to perform hash
String hash(String pass) {
  var bytes = utf8.encode(pass);
  var digest = sha512.convert(bytes);

  // print("Digest as bytes: ${digest.bytes}");
  // print("Digest as hex string: ${digest}");

  return digest.toString();
}

// Function to authenticate user
Future<bool> authenticate(BuildContext context, String masterPassHashed) async {
  final formKey = GlobalKey<FormState>();
  final localAuth = LocalAuthentication();
  final isAvailable = await localAuth.canCheckBiometrics;

  String? password;

  Future<void> useBiometric() async {
    final authorized = await localAuth.authenticate(
      localizedReason: "Please authenticate to copy",
      options: const AuthenticationOptions(
        stickyAuth: true,
        biometricOnly: true,
      ),
    );

    if (authorized) {
      // Return true on successful authentication
      Navigator.pop(context, true);
    }
  }

  useBiometric();

  final result = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      surfaceTintColor: Theme.of(context).cardColor,
      title: MyText(
        text: "Authenticate",
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).highlightColor,
        textAlign: TextAlign.center,
      ),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyText(
              text: "Master Password",
              fontSize: 16,
              color: Theme.of(context).hintColor,
            ),
            InputBox(
              text: "",
              enabled: true,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Invalid Password";
                }
                return null;
              },
              onSaved: (newValue) {
                password = newValue;
              },
            ),
          ],
        ),
      ),
      actions: [
        Center(
          child: Column(
            children: [
              TextButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();

                    password = hash(password!);

                    if (password == masterPassHashed) {
                      // Return true on successful authentication
                      Navigator.pop(context, true);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Incorrect Password"),
                        ),
                      );
                      Navigator.pop(context, false); // Return false on failure
                    }
                  }
                },
                child: MyText(
                  text: "Verify",
                  fontSize: 18,
                  color: Theme.of(context).highlightColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pop(context, false), // Cancel with false
                child: MyText(
                  text: "Cancel",
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).highlightColor,
                ),
              ),
              if (isAvailable)
                TextButton(
                  onPressed: useBiometric,
                  child: MyText(
                    text: "Use Biometrics",
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).highlightColor,
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );

  // Handle potential errors during dialog dismissal (if applicable)
  return result ?? false;
}

// Function to authenticate user and then copy content to clipboard
void authAndCopy(
    String text, BuildContext context, String masterPassHashed) async {
  // Use the authenticate function for authentication
  final isAuthenticated = await authenticate(context, masterPassHashed);
  if (isAuthenticated) {
    copyToClipboard(text, context);
  }
}

// Function to create vault item add it to firebase and provider
Future<bool> createVault(
  String uid,
  String key,
  String category,

  // Password Input Fields
  String? nameInp,
  String? usernameInp,
  String? passwordInp,
  String? passNotesInp,

  // Bank Account Input Fields
  String? bankNameInp,
  String? accTypeInp,
  String? accNoInp,
  String? ifscInp,
  String? bankNotesInp,

  // ATM Card Input Fields
  String? cardNameInp,
  String? nameOnCardInp,
  String? cardTypeInp,
  String? cardNoInp,
  String? cvvInp,
  String? expDate,
  String? atmPINInp,
  String? upiPINInp,
  String? cardNotesInp,

  // Notes Input Fields
  String? notesNameInp,
  String? notesInp,
) async {
  Map<String, String> vault = {
    "uid": uid,
    "category": category,
  };

  // if category - password
  if (category == categoryMap[Category.passwords]["value"]) {
    vault = {
      ...vault,
      "name": encryptSecret(nameInp!, key),
      "username": encryptSecret(usernameInp!, key),
      "password": encryptSecret(passwordInp!, key),
      "notes": encryptSecret(passNotesInp!, key),
    };
  }

  // if category - bank account
  else if (category == categoryMap[Category.banks]["value"]) {
    vault = {
      ...vault,
      "name": encryptSecret(bankNameInp!, key),
      "acc_type": encryptSecret(accTypeInp!, key),
      "acc_no": encryptSecret(accNoInp!, key),
      "ifsc": encryptSecret(ifscInp!, key),
      "notes": encryptSecret(bankNotesInp!, key),
    };
  }

  // if category - atm card
  else if (category == categoryMap[Category.cards]["value"]) {
    vault = {
      ...vault,
      "name": encryptSecret(cardNameInp!, key),
      "name_on_card": encryptSecret(nameOnCardInp!, key),
      "card_type": encryptSecret(cardTypeInp!, key),
      "card_no": encryptSecret(cardNoInp!, key),
      "cvv": encryptSecret(cvvInp!, key),
      "exp_date": encryptSecret(expDate!, key),
      "atm_pin": encryptSecret(atmPINInp!, key),
      "upi_pin": encryptSecret(upiPINInp!, key),
      "notes": encryptSecret(cardNotesInp!, key),
    };
  }

  // if category - notes
  else if (category == categoryMap[Category.notes]["value"]) {
    vault = {
      ...vault,
      "name": encryptSecret(notesNameInp!, key),
      "notes": encryptSecret(notesInp!, key),
    };
  }

  // exceptional case
  else {
    return false;
  }

  // saving data to firestore
  try {
    // print(vault);
    await FirebaseFirestore.instance
        .collection("Vault")
        .add(vault)
        .then((docRef) {
      final docId = docRef.id;
      vault["id"] = docId;
      docRef.update(vault);
    });
    // print("success");
    return true;
  } on FirebaseException catch (error) {
    // print(error.code);
    return false;
  }
}

// Function to create vault item add it to firebase and provider
Future<bool> editVault(
  String vaultId,
  String category,
  String key,

  // Password Input Fields
  String? nameInp,
  String? usernameInp,
  String? passwordInp,
  String? passNotesInp,

  // Bank Account Input Fields
  String? bankNameInp,
  String? accTypeInp,
  String? accNoInp,
  String? ifscInp,
  String? bankNotesInp,

  // ATM Card Input Fields
  String? cardNameInp,
  String? nameOnCardInp,
  String? cardTypeInp,
  String? cardNoInp,
  String? cvvInp,
  String? expDate,
  String? atmPINInp,
  String? upiPINInp,
  String? cardNotesInp,

  // Notes Input Fields
  String? notesNameInp,
  String? notesInp,
) async {
  Map<String, String> vault;

  // if category - password
  if (category == categoryMap[Category.passwords]["value"]) {
    vault = {
      "name": encryptSecret(nameInp!, key),
      "username": encryptSecret(usernameInp!, key),
      "password": encryptSecret(passwordInp!, key),
      "notes": encryptSecret(passNotesInp!, key),
    };
  }

  // if category - bank account
  else if (category == categoryMap[Category.banks]["value"]) {
    vault = {
      "name": encryptSecret(bankNameInp!, key),
      "acc_type": encryptSecret(accTypeInp!, key),
      "acc_no": encryptSecret(accNoInp!, key),
      "ifsc": encryptSecret(ifscInp!, key),
      "notes": encryptSecret(bankNotesInp!, key),
    };
  }

  // if category - atm card
  else if (category == categoryMap[Category.cards]["value"]) {
    vault = {
      "name": encryptSecret(cardNameInp!, key),
      "name_on_card": encryptSecret(nameOnCardInp!, key),
      "card_type": encryptSecret(cardTypeInp!, key),
      "card_no": encryptSecret(cardNoInp!, key),
      "cvv": encryptSecret(cvvInp!, key),
      "exp_date": encryptSecret(expDate!, key),
      "atm_pin": encryptSecret(atmPINInp!, key),
      "upi_pin": encryptSecret(upiPINInp!, key),
      "notes": encryptSecret(cardNotesInp!, key),
    };
  }

  // if category - notes
  else if (category == categoryMap[Category.notes]["value"]) {
    vault = {
      "name": encryptSecret(notesNameInp!, key),
      "notes": encryptSecret(notesInp!, key),
    };
  }

  // exceptional case
  else {
    return false;
  }

  // saving data to firestore
  try {
    await FirebaseFirestore.instance
        .collection("Vault")
        .doc(vaultId)
        .update(vault);

    // print("success");
    return true;
  } on FirebaseException catch (error) {
    // print(error.code);
    return false;
  }
}

// Function to delete vault item
Future<bool> deleteVault(String vaultId) async {
  try {
    await FirebaseFirestore.instance.collection("Vault").doc(vaultId).delete();
    print("success");
    return true;
  } on FirebaseException catch (error) {
    print(error.code);
    return false;
  }
}

// Function to change master password
Future<bool> changeMasterPass(BuildContext context, String uid, String email,
    String masterPassHashed) async {
  final formKey = GlobalKey<FormState>();
  String? oldPass;
  String? newPass;
  String? newPassConf;

  final result = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      surfaceTintColor: Theme.of(context).cardColor,
      title: MyText(
        text: "Change Master Password",
        fontSize: 22,
        color: Theme.of(context).highlightColor,
        fontWeight: FontWeight.w500,
        textAlign: TextAlign.center,
      ),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyText(
              text: "Old Master Password",
              fontSize: 16,
              color: Theme.of(context).hintColor,
              fontWeight: FontWeight.w500,
            ),
            InputBox(
              text: "",
              enabled: true,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Invalid Password";
                }
                return null;
              },
              onSaved: (newValue) {
                oldPass = newValue;
              },
            ),
            MyText(
              text: "New Master Password",
              fontSize: 16,
              color: Theme.of(context).hintColor,
            ),
            InputBox(
              text: "",
              enabled: true,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Invalid Password";
                } else if (value.length < 8) {
                  return "Password should be minimum 8 characters";
                }
                return null;
              },
              onChanged: (newValue) {
                newPass = newValue;
              },
              onSaved: (newValue) {
                newPass = newValue;
              },
            ),
            MyText(
              text: "Confirm New Master Password",
              fontSize: 16,
              color: Theme.of(context).hintColor,
            ),
            InputBox(
              text: "",
              enabled: true,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Invalid Password";
                } else if (value != newPass) {
                  return "Passwords don't match";
                }
                return null;
              },
              onSaved: (newValue) {
                newPassConf = newValue;
              },
            ),
          ],
        ),
      ),
      actions: [
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: MyText(
                  text: "Cancel",
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).highlightColor,
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    String oldPassHashed = hash(oldPass!);
                    if (oldPassHashed == masterPassHashed) {
                      try {
                        User? user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          AuthCredential cred = EmailAuthProvider.credential(
                              email: email, password: oldPass!);
                          await user.reauthenticateWithCredential(cred);
                          await user.updatePassword(newPass!);

                          String newPassHashed = hash(newPass!);

                          final docRef = FirebaseFirestore.instance
                              .collection("User")
                              .doc(uid);
                          await docRef.update({"password": newPassHashed});
                          // Return true on successful authentication
                          Navigator.pop(context, true);
                          Navigator.of(context).pop();
                        }
                      } on FirebaseException catch (e) {
                        print(e.code);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Something went wrong"),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Incorrect Password"),
                        ),
                      );
                      // Navigator.pop(context, false); // Return false on failure
                    }
                  }
                },
                child: MyText(
                  text: "Change",
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).highlightColor,
                ),
              ),
            ],
          ),
        )
      ],
    ),
  );
  return result;
}

// Function to logout with user confirmation
void logout(context, ref) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      surfaceTintColor: Theme.of(context).cardColor,
      title: MyText(
        text: "Confirm Logout",
        fontSize: 20,
        color: Theme.of(context).highlightColor,
        fontWeight: FontWeight.w500,
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            MyText(
              text: 'Are you sure you want to logout?',
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
          onPressed: () => Navigator.of(context).pop(), // Close dialog
        ),
        TextButton(
          child: MyText(
            text: 'Logout',
            fontSize: 16,
            color: Theme.of(context).highlightColor,
            fontWeight: FontWeight.w500,
          ),
          onPressed: () async {
            Navigator.of(context).pop();
            ref
                .read(categoryProvider.notifier)
                .changeCategory(Category.passwords);
            ref.read(currentUserProvider.notifier).clearData();
            FirebaseAuth.instance.signOut();
          },
        ),
      ],
    ),
  );
}
