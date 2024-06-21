// View Vault Page

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:password_manager/providers/category_provider.dart';
import 'package:password_manager/providers/current_user_provider.dart';
import 'package:password_manager/utils/constants.dart';
import 'package:password_manager/utils/icons.dart';
import 'package:password_manager/utils/services.dart';
import 'package:password_manager/widgets/input_box.dart';
import 'package:password_manager/widgets/my_text.dart';

class ViewVaultPage extends ConsumerStatefulWidget {
  const ViewVaultPage({
    super.key,
    this.vault,
    required this.mode, // mode - create / view / edit
    required this.category,
  });

  final QueryDocumentSnapshot? vault;
  final VaultMode mode;
  final String category;

  @override
  ConsumerState<ViewVaultPage> createState() => _ViewVaultPageState();
}

class _ViewVaultPageState extends ConsumerState<ViewVaultPage> {
  final _formKey = GlobalKey<FormState>();

  // Obscure text attribute values for various TextFormFields in the form
  late bool _obscureTextPass;
  late bool _obscureTextBank;
  late bool _obscureTextCardNo;
  late bool _obscureTextCardCVV;
  late bool _obscureTextATMPIN;
  late bool _obscureTextUPIPIN;

  // mode - create / view / edit
  late VaultMode mode;

  // if mode -> view then only vault will be not null
  late QueryDocumentSnapshot? vault;

  // initializing values
  @override
  void initState() {
    super.initState();
    _obscureTextPass = true;
    _obscureTextBank = true;
    _obscureTextCardNo = true;
    _obscureTextCardCVV = true;
    _obscureTextATMPIN = true;
    _obscureTextUPIPIN = true;
    mode = widget.mode;
    _categoryInp = widget.category;
    vault = widget.vault;
  }

  // Input field values
  String? _categoryInp;

  // Password Input Field values
  String? _nameInp;
  String? _usernameInp;
  String? _passwordInp;
  String? _passNotesInp;

  // Bank Account Input Field values
  String? _bankNameInp;
  String? _accTypeInp;
  String? _accNoInp;
  String? _ifscInp;
  String? _bankNotesInp;

  // ATM Card Input Field values
  String? _cardNameInp;
  String? _nameOnCardInp;
  String? _cardTypeInp;
  String? _cardNoInp;
  String? _cvvInp;
  String? _expDate;
  String? _atmPINInp;
  String? _upiPINInp;
  String? _cardNotesInp;

  // Notes Input Field values
  String? _notesNameInp;
  String? _notesInp;

  @override
  Widget build(BuildContext context) {
    // Retrieve the current brightness of the system.
    final Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
    final bool isLightMode = currentBrightness == Brightness.light;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // Appbar
      appBar: AppBar(
        // Button -> Back
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_circle_left_rounded,
            size: 28,
            color: Theme.of(context).highlightColor,
          ),
        ),
        title: MyText(
          // Displaying heading conditionally depending on the current vault mode
          text: mode == VaultMode.create
              ? "Create New Vault"
              : mode == VaultMode.edit
                  ? "Edit Vault"
                  : "View Vault",
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).highlightColor,
        ),

        // Button -> Delete
        // if mode is not create then only Delete option will be available
        actions: [
          if (mode != VaultMode.create)
            IconButton(
              onPressed: () {
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
                            text: 'Are you sure you want to delete this item?',
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
                                Navigator.of(context).pop(); // Close the dialog
                                Navigator.of(context)
                                    .pop(); // Close the ViewVaultPage
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
              icon: SvgPicture.asset(icoDelete, width: 24, color: Theme.of(context).highlightColor,),
            ),
        ],
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
      ),

      // Body
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).cardColor,
              ),

              // Form
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Form Heading - Credential
                    MyText(
                      text: "Credential",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).highlightColor,
                    ),
                    const SizedBox(height: 16),

                    // Category Dropdown Field
                    MyText(
                      text: "Select Category",
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).hintColor,
                    ),
                    Theme(
                      data: ThemeData(canvasColor: Theme.of(context).cardColor),
                      child: DropdownButtonFormField<String>(
                        enableFeedback: false,
                        value: _categoryInp,
                        items: [
                          DropdownMenuItem(
                            value: categoryMap[Category.passwords]["value"],
                            child:
                                Text(categoryMap[Category.passwords]["value"]),
                          ),
                          DropdownMenuItem(
                            value: categoryMap[Category.banks]["value"],
                            child: Text(categoryMap[Category.banks]["value"]),
                          ),
                          DropdownMenuItem(
                            value: categoryMap[Category.cards]["value"],
                            child: Text(categoryMap[Category.cards]["value"]),
                          ),
                          DropdownMenuItem(
                            value: categoryMap[Category.notes]["value"],
                            child: Text(categoryMap[Category.notes]["value"]),
                          ),
                        ],
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).highlightColor,
                        ),
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 1.5,
                            ),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).unselectedWidgetColor,
                              width: 1.5,
                            ),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          errorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          focusedErrorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                        onChanged: mode == VaultMode.create
                            // if mode -> create then only keep the field enabled
                            ? (newValue) {
                                setState(() {
                                  _categoryInp = newValue;
                                });
                              }
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Other Input Fields based on the selected category
                    ...buildFormFields(_categoryInp!, isLightMode),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),

      // Bottom Action Button
      floatingActionButton: Container(
        width: double.infinity,
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: TextButton(
          onPressed: () async {
            // if mode -> create
            if (mode == VaultMode.create) {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                // Create new vault and store it in Firebase Firestore
                if (await createVault(
                  ref.read(currentUserProvider)[CurrentUser.uid]!,
                  ref.read(currentUserProvider)[CurrentUser.masterPass]!,
                  _categoryInp!,
                  _nameInp,
                  _usernameInp,
                  _passwordInp,
                  _passNotesInp,
                  _bankNameInp,
                  _accTypeInp,
                  _accNoInp,
                  _ifscInp,
                  _bankNotesInp,
                  _cardNameInp,
                  _nameOnCardInp,
                  _cardTypeInp,
                  _cardNoInp,
                  _cvvInp,
                  _expDate,
                  _atmPINInp,
                  _upiPINInp,
                  _cardNotesInp,
                  _notesNameInp,
                  _notesInp,
                )) {
                  // if new vault successfully created
                  Future.delayed(
                    const Duration(seconds: 0),
                    () {
                      Navigator.of(context).pop(); // Pop the current page

                      // refresh the vault list by changing the Category back n forth
                      final cat = ref.read(categoryProvider);
                      ref
                          .read(categoryProvider.notifier)
                          .changeCategory(Category.other);
                      ref.read(categoryProvider.notifier).changeCategory(cat);
                    },
                  );
                }

                // if any error occurred during creation of new vault
                else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Something went wrong! Please try again."),
                    ),
                  );
                }
              }
            }

            // if mode -> view
            else if (mode == VaultMode.view) {
              // change the Vault mode to Edit
              setState(() {
                mode = VaultMode.edit;
              });
            }

            // if mode -> edit
            else if (mode == VaultMode.edit) {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                // Update the existing Vault item in Firebase Firestore
                if (await editVault(
                  vault!["id"],
                  _categoryInp!,
                  ref.read(currentUserProvider)[CurrentUser.masterPass]!,
                  _nameInp,
                  _usernameInp,
                  _passwordInp,
                  _passNotesInp,
                  _bankNameInp,
                  _accTypeInp,
                  _accNoInp,
                  _ifscInp,
                  _bankNotesInp,
                  _cardNameInp,
                  _nameOnCardInp,
                  _cardTypeInp,
                  _cardNoInp,
                  _cvvInp,
                  _expDate,
                  _atmPINInp,
                  _upiPINInp,
                  _cardNotesInp,
                  _notesNameInp,
                  _notesInp,
                )) {
                  // if updation of vault successful
                  Future.delayed(
                    const Duration(seconds: 0),
                    () {
                      Navigator.of(context).pop(); // pop the ViewVaultPage

                      // refresh the vault list by changing the Category back n forth
                      final cat = ref.read(categoryProvider);
                      ref
                          .read(categoryProvider.notifier)
                          .changeCategory(Category.other);
                      ref.read(categoryProvider.notifier).changeCategory(cat);
                    },
                  );
                }

                // if any error occurred during updation of vault
                else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Something went wrong! Please try again."),
                    ),
                  );
                }
              }
            }
          },
          style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.symmetric(vertical: 12),
            ),
            backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).focusColor),
          ),
          child: MyText(
            // Displaying button text conditionally depending on the mode
            text: mode == VaultMode.create
                ? "Create the Vault"
                : mode == VaultMode.edit
                    ? "Save"
                    : "Edit",
            fontSize: 20,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  List buildFormFields(String category, bool isLightMode) {
    // function builds form input fields conditionally according to opening mode (create, edit, view)

    // getting the master password of the user
    String masterPass = ref.read(currentUserProvider)[CurrentUser.masterPass]!;

    // decrypting the field values
    String name =
        vault != null ? decryptSecret(vault!["name"], masterPass) : "";
    String notes =
        vault != null ? decryptSecret(vault!["notes"], masterPass) : "";

    // Password Fields
    if (category == categoryMap[Category.passwords]["value"]) {
      String username =
          vault != null ? decryptSecret(vault!["username"], masterPass) : "";
      String password =
          vault != null ? decryptSecret(vault!["password"], masterPass) : "";
      return [
        // Name Input Field
        MyText(
          text: "Name",
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),
        InputBox(
          // if mode -> view then disable the field
          enabled: !(mode == VaultMode.view),
          initialValue: name,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.none,
          enableSuggestions: true,
          onSaved: (newValue) {
            _nameInp = newValue;
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Required";
            }
            return null;
          },
        ),
        const SizedBox(height: 10),

        // Username Input Field
        MyText(
          text: "Username",
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),
        Stack(
          children: [
            InputBox(
              // if mode -> view then disable the field
              enabled: !(mode == VaultMode.view),
              initialValue: username,
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              prefixIcon: IconButton(
                icon: SvgPicture.asset(
                  icoUserInAct,
                  width: 20,
                  color: Theme.of(context).hintColor
                ),
                onPressed: null,
              ),
              onSaved: (newValue) {
                _usernameInp = newValue;
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Required";
                }
                return null;
              },
            ),
            // Button -> Copy username
            if (mode == VaultMode.view)
              Positioned(
                right: 0,
                child: IconButton(
                  icon: SvgPicture.asset(
                    isLightMode ? icoCopyLight: icoCopyDark,
                    width: 24,
                  ),
                  onPressed: () {
                    authAndCopy(username, context, masterPass);
                  },
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // Password Input Field
        MyText(
          text: "Password",
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),
        Stack(
          children: [
            InputBox(
              // if mode -> view then disable the field
              enabled: !(mode == VaultMode.view),
              initialValue: password,
              keyboardType: TextInputType.visiblePassword,
              obscureText: _obscureTextPass,
              prefixIcon: IconButton(
                onPressed: null,
                icon: SvgPicture.asset(
                  icoPassInAct,
                  width: 20,
                  color: Theme.of(context).hintColor
                ),
              ),
              // Button -> Password visibility toggle
              suffixIcon: IconButton(
                icon: SvgPicture.asset(
                  _obscureTextPass ? icoEyeOpen : icoEyeClose,
                  width: 20,
                  color: Theme.of(context).hintColor
                ),
                onPressed: () async {
                  // if password is hidden then ask user to authenticate to make it visible
                  if (_obscureTextPass) {
                    final masterPass =
                        ref.read(currentUserProvider)[CurrentUser.masterPass];
                    if (await authenticate(context, masterPass!)) {
                      setState(() {
                        _obscureTextPass = !_obscureTextPass;
                      });
                    }
                  }

                  // if password is visible in plaintext then no need to authenticate user to hide it
                  else {
                    setState(() {
                      _obscureTextPass = !_obscureTextPass;
                    });
                  }
                },
              ),
              onSaved: (newValue) {
                _passwordInp = newValue;
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Required";
                }
                return null;
              },
            ),

            // Button -> Copy password
            if (mode == VaultMode.view)
              Positioned(
                right: 0,
                child: IconButton(
                  icon: SvgPicture.asset(
                    isLightMode ? icoCopyLight: icoCopyDark,
                    width: 24,
                  ),
                  onPressed: () {
                    authAndCopy(password, context, masterPass);
                  },
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // Notes
        MyText(
          text: "Notes",
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),
        InputBox(
          // if mode -> view then disable the field
          enabled: !(mode == VaultMode.view),
          initialValue: notes,
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          enableSuggestions: true,
          validator: (value) {
            return null;
          },
          onSaved: (newValue) {
            _passNotesInp = newValue;
          },
        ),
      ];
    }

    // Bank Fields
    else if (category == categoryMap[Category.banks]["value"]) {
      String accType =
          vault != null ? decryptSecret(vault!["acc_type"], masterPass) : "";
      String accNo =
          vault != null ? decryptSecret(vault!["acc_no"], masterPass) : "";
      String ifsc =
          vault != null ? decryptSecret(vault!["ifsc"], masterPass) : "";
      return [
        // Bank Name Input Field
        MyText(
          text: "Bank Name",
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),
        InputBox(
          // if mode -> view then disable the field
          enabled: !(mode == VaultMode.view),
          initialValue: name,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          onSaved: (newValue) {
            _bankNameInp = newValue;
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Required";
            }
            return null;
          },
        ),
        const SizedBox(height: 10),

        // Account Type Input Field
        MyText(
          text: "Account Type",
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),
        InputBox(
          // if mode -> view then disable the field
          enabled: !(mode == VaultMode.view),
          initialValue: accType,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          onSaved: (newValue) {
            _accTypeInp = newValue;
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Required";
            }
            return null;
          },
        ),
        const SizedBox(height: 10),

        // Account No Input Field
        MyText(
          text: "Account No",
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),
        Stack(
          children: [
            InputBox(
              // if mode -> view then disable the field
              enabled: !(mode == VaultMode.view),
              initialValue: accNo,
              keyboardType: TextInputType.number,
              obscureText: _obscureTextBank,
              prefixIcon: IconButton(
                onPressed: null,
                icon: SvgPicture.asset(
                  icoUserInAct,
                  width: 20,
                  color: Theme.of(context).hintColor
                ),
              ),
              // Button -> Password visibility toggle
              suffixIcon: IconButton(
                icon: SvgPicture.asset(
                  _obscureTextBank ? icoEyeOpen : icoEyeClose,
                  width: 20,
                  color: Theme.of(context).hintColor
                ),
                onPressed: () async {
                  // if field value is hidden then ask user to authenticate to make it visible
                  if (_obscureTextBank) {
                    final masterPass =
                        ref.read(currentUserProvider)[CurrentUser.masterPass];
                    if (await authenticate(context, masterPass!)) {
                      setState(() {
                        _obscureTextBank = !_obscureTextBank;
                      });
                    }
                  }

                  // if field value is visible in plaintext then no need to authenticate user to hide it
                  else {
                    setState(() {
                      _obscureTextBank = !_obscureTextBank;
                    });
                  }
                },
              ),
              onSaved: (newValue) {
                _accNoInp = newValue;
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Required";
                }
                return null;
              },
            ),
            // Button -> Copy Account No
            if (mode == VaultMode.view)
              Positioned(
                right: 0,
                child: IconButton(
                  icon: SvgPicture.asset(
                    isLightMode ? icoCopyLight: icoCopyDark,
                    width: 24,
                  ),
                  onPressed: () {
                    authAndCopy(accNo, context, masterPass);
                  },
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // IFSC Code Input Field
        MyText(
          text: "IFSC Code",
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),
        InputBox(
          // if mode -> view then disable the field
          enabled: !(mode == VaultMode.view),
          initialValue: ifsc,
          keyboardType: TextInputType.text,
          onSaved: (newValue) {
            _ifscInp = newValue;
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Required";
            }
            return null;
          },
        ),
        const SizedBox(height: 10),

        // Notes
        MyText(
          text: "Notes",
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),
        InputBox(
          // if mode -> view then disable the field
          enabled: !(mode == VaultMode.view),
          initialValue: notes,
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          enableSuggestions: true,
          validator: (value) {
            return null;
          },
          onSaved: (newValue) {
            _bankNotesInp = newValue;
          },
        ),
      ];
    }

    // ATM Card Fields
    else if (category == categoryMap[Category.cards]["value"]) {
      String nameOnCard = vault != null
          ? decryptSecret(vault!["name_on_card"], masterPass)
          : "";
      String cardType =
          vault != null ? decryptSecret(vault!["card_type"], masterPass) : "";
      String cardNo =
          vault != null ? decryptSecret(vault!["card_no"], masterPass) : "";
      String cvv =
          vault != null ? decryptSecret(vault!["cvv"], masterPass) : "";
      String expDate =
          vault != null ? decryptSecret(vault!["exp_date"], masterPass) : "";
      String atmPin =
          vault != null ? decryptSecret(vault!["atm_pin"], masterPass) : "";
      String upiPin =
          vault != null ? decryptSecret(vault!["upi_pin"], masterPass) : "";
      return [
        // Bank Name Input Field
        MyText(
          text: "Bank",
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),
        InputBox(
          // if mode -> view then disable the field
          enabled: !(mode == VaultMode.view),
          initialValue: name,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          enableSuggestions: true,
          onSaved: (newValue) {
            _cardNameInp = newValue;
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Required";
            }
            return null;
          },
        ),
        const SizedBox(height: 10),

        // Name on Card Input Field
        MyText(
          text: "Name on Card",
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),
        InputBox(
          // if mode -> view then disable the field
          enabled: !(mode == VaultMode.view),
          initialValue: nameOnCard,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          enableSuggestions: true,
          onSaved: (newValue) {
            _nameOnCardInp = newValue;
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Required";
            }
            return null;
          },
        ),
        const SizedBox(height: 10),

        // Card Type Input Field
        MyText(
          text: "Card Type",
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),
        InputBox(
          // if mode -> view then disable the field
          enabled: !(mode == VaultMode.view),
          initialValue: cardType,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          enableSuggestions: true,
          onSaved: (newValue) {
            _cardTypeInp = newValue;
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Required";
            }
            return null;
          },
        ),
        const SizedBox(height: 10),

        // Card No Input Field
        MyText(
          text: "Card No",
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),
        Stack(
          children: [
            InputBox(
              // if mode -> view then disable the field
              enabled: !(mode == VaultMode.view),
              initialValue: cardNo,
              keyboardType: TextInputType.number,
              obscureText: _obscureTextCardNo,
              prefixIcon: IconButton(
                onPressed: null,
                icon: SvgPicture.asset(
                  icoUserInAct,
                  width: 20,
                  color: Theme.of(context).hintColor
                ),
              ),
              // Button -> Password visibility toggle
              suffixIcon: IconButton(
                icon: SvgPicture.asset(
                  _obscureTextCardNo ? icoEyeOpen : icoEyeClose,
                  width: 20,
                  color: Theme.of(context).hintColor
                ),
                onPressed: () async {
                  // if field value is hidden then ask user to authenticate to make it visible
                  if (_obscureTextCardNo) {
                    final masterPass =
                        ref.read(currentUserProvider)[CurrentUser.masterPass];
                    if (await authenticate(context, masterPass!)) {
                      setState(() {
                        _obscureTextCardNo = !_obscureTextCardNo;
                      });
                    }
                  }

                  // if field value is visible in plaintext then no need to authenticate user to hide it
                  else {
                    setState(() {
                      _obscureTextCardNo = !_obscureTextCardNo;
                    });
                  }
                },
              ),
              onSaved: (newValue) {
                _cardNoInp = newValue;
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Required";
                }
                return null;
              },
            ),
            // Button -> Copy Card No
            if (mode == VaultMode.view)
              Positioned(
                right: 0,
                child: IconButton(
                  icon: SvgPicture.asset(
                    isLightMode ? icoCopyLight: icoCopyDark,
                    width: 24,
                  ),
                  onPressed: () {
                    authAndCopy(cardNo, context, masterPass);
                  },
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // CVV Input Field
        MyText(
          text: "CVV",
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),
        Stack(
          children: [
            InputBox(
              // if mode -> view then disable the field
              enabled: !(mode == VaultMode.view),
              initialValue: cvv,
              keyboardType: TextInputType.number,
              obscureText: _obscureTextCardCVV,
              prefixIcon: IconButton(
                onPressed: null,
                icon: SvgPicture.asset(
                  icoPassInAct,
                  width: 20,
                  color: Theme.of(context).hintColor
                ),
              ),
              // Button -> Password visibility toggle
              suffixIcon: IconButton(
                icon: SvgPicture.asset(
                  _obscureTextCardCVV ? icoEyeOpen : icoEyeClose,
                  width: 20,
                  color: Theme.of(context).hintColor
                ),
                onPressed: () async {
                  // if field value is hidden then ask user to authenticate to make it visible
                  if (_obscureTextCardCVV) {
                    final masterPass =
                        ref.read(currentUserProvider)[CurrentUser.masterPass];
                    if (await authenticate(context, masterPass!)) {
                      setState(() {
                        _obscureTextCardCVV = !_obscureTextCardCVV;
                      });
                    }
                  }

                  // if field value is visible in plaintext then no need to authenticate user to hide it
                  else {
                    setState(() {
                      _obscureTextCardCVV = !_obscureTextCardCVV;
                    });
                  }
                },
              ),
              onSaved: (newValue) {
                _cvvInp = newValue;
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Required";
                }
                return null;
              },
            ),
            // Button Copy CVV
            if (mode == VaultMode.view)
              Positioned(
                right: 0,
                child: IconButton(
                  icon: SvgPicture.asset(
                    isLightMode ? icoCopyLight: icoCopyDark,
                    width: 24,
                  ),
                  onPressed: () {
                    authAndCopy(cvv, context, masterPass);
                  },
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // Expiry Date Input Field
        MyText(
          text: "Expiry Date",
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),
        InputBox(
          // if mode -> view then disable the field
          enabled: !(mode == VaultMode.view),
          initialValue: expDate,
          keyboardType: TextInputType.datetime,
          onSaved: (newValue) {
            _expDate = newValue;
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Required";
            }
            return null;
          },
        ),
        const SizedBox(height: 10),

        // ATM PIN Input Field
        MyText(
          text: "ATM PIN",
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),
        Stack(
          children: [
            InputBox(
              // if mode -> view then disable the field
              enabled: !(mode == VaultMode.view),
              initialValue: atmPin,
              keyboardType: TextInputType.number,
              obscureText: _obscureTextATMPIN,
              prefixIcon: IconButton(
                onPressed: null,
                icon: SvgPicture.asset(
                  icoPassInAct,
                  width: 20,
                  color: Theme.of(context).hintColor
                ),
              ),
              // Button -> Password visibility toggle
              suffixIcon: IconButton(
                icon: SvgPicture.asset(
                  _obscureTextATMPIN ? icoEyeOpen : icoEyeClose,
                  width: 20,
                  color: Theme.of(context).hintColor
                ),
                onPressed: () async {
                  // if field value is hidden then ask user to authenticate to make it visible
                  if (_obscureTextATMPIN) {
                    final masterPass =
                        ref.read(currentUserProvider)[CurrentUser.masterPass];
                    if (await authenticate(context, masterPass!)) {
                      setState(() {
                        _obscureTextATMPIN = !_obscureTextATMPIN;
                      });
                    }
                  }

                  // if field value is visible in plaintext then no need to authenticate user to hide it
                  else {
                    setState(() {
                      _obscureTextATMPIN = !_obscureTextATMPIN;
                    });
                  }
                },
              ),
              onSaved: (newValue) {
                _atmPINInp = newValue;
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Required";
                }
                return null;
              },
            ),
            // Button -> Copy ATM PIN
            if (mode == VaultMode.view)
              Positioned(
                right: 0,
                child: IconButton(
                  icon: SvgPicture.asset(
                    isLightMode ? icoCopyLight: icoCopyDark,
                    width: 24,
                  ),
                  onPressed: () {
                    authAndCopy(atmPin, context, masterPass);
                  },
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // UPI PIN Input Field
        MyText(
          text: "UPI PIN",
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),
        Stack(
          children: [
            InputBox(
              // if mode -> view then disable the field
              enabled: !(mode == VaultMode.view),
              initialValue: upiPin,
              keyboardType: TextInputType.number,
              obscureText: _obscureTextUPIPIN,
              prefixIcon: IconButton(
                onPressed: null,
                icon: SvgPicture.asset(
                  icoPassInAct,
                  width: 20,
                  color: Theme.of(context).hintColor
                ),
              ),
              // Button -> Password visibility toggle
              suffixIcon: IconButton(
                icon: SvgPicture.asset(
                  _obscureTextUPIPIN ? icoEyeOpen : icoEyeClose,
                  width: 20,
                  color: Theme.of(context).hintColor
                ),
                onPressed: () async {
                  // if field value is hidden then ask user to authenticate to make it visible
                  if (_obscureTextUPIPIN) {
                    final masterPass =
                        ref.read(currentUserProvider)[CurrentUser.masterPass];
                    if (await authenticate(context, masterPass!)) {
                      setState(() {
                        _obscureTextUPIPIN = !_obscureTextUPIPIN;
                      });
                    }
                  }

                  // if field value is visible in plaintext then no need to authenticate user to hide it
                  else {
                    setState(() {
                      _obscureTextUPIPIN = !_obscureTextUPIPIN;
                    });
                  }
                },
              ),
              onSaved: (newValue) {
                _upiPINInp = newValue;
              },
              validator: (value) {
                return null;
              },
            ),
            // Button -> Copy UPI PIN
            if (mode == VaultMode.view)
              Positioned(
                right: 0,
                child: IconButton(
                  icon: SvgPicture.asset(
                    isLightMode ? icoCopyLight: icoCopyDark,
                    width: 24,
                  ),
                  onPressed: () {
                    authAndCopy(upiPin, context, masterPass);
                  },
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // Notes
        MyText(
          text: "Notes",
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),
        InputBox(
          // if mode -> view then disable the field
          enabled: !(mode == VaultMode.view),
          initialValue: notes,
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          enableSuggestions: true,
          validator: (value) {
            return null;
          },
          onSaved: (newValue) {
            _cardNotesInp = newValue;
          },
        ),
      ];
    }

    // Notes Fields
    else if (category == categoryMap[Category.notes]["value"]) {
      return [
        // Notes Title Input Field
        MyText(
          text: "Title",
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),
        InputBox(
          // if mode -> view then disable the field
          enabled: !(mode == VaultMode.view),
          initialValue: name,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          enableSuggestions: true,
          onSaved: (newValue) {
            _notesNameInp = newValue;
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Required";
            }
            return null;
          },
        ),
        const SizedBox(height: 10),

        // Notes Input Field
        MyText(
          text: "Notes",
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),
        InputBox(
          // if mode -> view then disable the field
          enabled: !(mode == VaultMode.view),
          initialValue: notes,
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          enableSuggestions: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Required";
            }
            return null;
          },
          onSaved: (newValue) {
            _notesInp = newValue;
          },
        ),
      ];
    }

    // Exceptional Case (which is surely not going to occur)
    return [];
  }
}
