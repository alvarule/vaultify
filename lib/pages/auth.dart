// Login & Sign Up Page

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:password_manager/utils/constants.dart';
import 'package:password_manager/utils/icons.dart';
import 'package:password_manager/utils/images.dart';
import 'package:password_manager/utils/services.dart';
import 'package:password_manager/widgets/input_box.dart';
import 'package:password_manager/widgets/my_text.dart';
import 'package:password_manager/providers/current_user_provider.dart';
import 'package:path_provider/path_provider.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({
    super.key,
    required this.isLogin, // login or signup mode
  });

  final bool isLogin;

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _firebase = FirebaseAuth.instance;

  late bool _isLogin;
  late bool _obscureTextP; // Password field obscure text value
  late bool _obscureTextCP; // Confirm Password field obscure text value

  bool _profilePicError = false;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.isLogin;
    _obscureTextP = true;
    _obscureTextCP = true;
  }

  String? _userProfile; // stores the path of selected profile pic
  String? _userName; // stores the entered username
  String? _userEmail; // stores the entered email
  String? _userPass; // stores the entered password
  String? _userConfPass; // stores the entered confirm password

  // stores the current state (authentication loading after login/signup btn click)
  bool _isAuthenticating = false;

  // Func to set the profile pic path
  void _setProfilePic(String selectedImage) {
    _userProfile = selectedImage;
  }

  // Func to authenticate
  void _authenticate() async {
    setState(() {
      _profilePicError = false;
    });
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // set authentication state -> true
        setState(() {
          _isAuthenticating = true;
        });

        // if in Login Mode
        if (_isLogin) {
          // login with provided credentials
          final userCreds = await _firebase.signInWithEmailAndPassword(
            email: _userEmail!,
            password: _userPass!,
          );

          // getting user uid
          final String uid = userCreds.user!.uid;

          // getting the user data stored in firebase cloud firestore
          final userData = await FirebaseFirestore.instance
              .collection("User")
              .doc(uid)
              .get();

          // extracting the User's Name and Password from the fetched data
          final String name = userData.data()!["name"];
          final String password = userData.data()!["password"];
          final String userProfile = userData.data()!["profile_pic"];

          // storing the User's data (Name, UID, Password) in currentUserProvider
          ref.read(currentUserProvider.notifier).updateData(
                _userEmail!,
                name,
                uid,
                password,
                userProfile,
              );
        }

        // if in Sign Up Mode
        else {
          // if profile pic is not selected -> return
          if (_userProfile == null) {
            setState(() {
              _profilePicError = true;
              _isAuthenticating = false;
            });
            return;
          }

          // Sign up with provided credentials
          final userCreds = await _firebase.createUserWithEmailAndPassword(
            email: _userEmail!,
            password: _userPass!,
          );

          // getting the UID generated after sign up
          final String uid = userCreds.user!.uid;

          // Generate a unique temporary file name
          String fileName = DateTime.now().millisecondsSinceEpoch.toString();

          // Storing the selected profile pic in a temp location
          final Directory tempDir = await getTemporaryDirectory();
          String tempFilePath = '${tempDir.path}/$fileName';

          ByteData assetData = await rootBundle.load(_userProfile!);
          List<int> bytes = assetData.buffer.asUint8List();
          File tempFile = File(tempFilePath);
          await tempFile.writeAsBytes(bytes);
          _userProfile = tempFile.path;

          // uploading the profile pic to firebase storage and fetching the image url
          final storageRef = FirebaseStorage.instance
              .ref()
              .child("profile_pic")
              .child('$uid.jpg');
          await storageRef.putFile(File(_userProfile!));
          final profilePicUrl = await storageRef.getDownloadURL();

          // Refresh -> relogin
          await _firebase.signOut();
          await _firebase.signInWithEmailAndPassword(
              email: _userEmail!, password: _userPass!);

          // Generating hash of the user's master password
          String userPassHashed = hash(_userPass!);

          // storing the User's data (Name, UID, Password -> hashed, Profile Pic URL) in currentUserProvider
          ref.read(currentUserProvider.notifier).updateData(
                _userEmail!,
                _userName!,
                uid,
                userPassHashed,
                profilePicUrl,
              );

          // storing the User's data (Name, UID, Password -> hashed, Profile Pic URL) in Firebase Cloud Firestore
          final Map<String, String> userData = {
            "uid": uid,
            "email": _userEmail!,
            "name": _userName!,
            "password": userPassHashed,
            "profile_pic": profilePicUrl,
          };
          await FirebaseFirestore.instance
              .collection("User")
              .doc(userCreds.user!.uid)
              .set(userData);
        }

        // Pop the Auth Page
        Navigator.of(context).pop();
      }

      // On Errors
      on FirebaseAuthException catch (error) {
        // print(error.code);
        if (error.code == "too-many-requests") {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Too many failed attempts! Please try again later"),
            ),
          );
        } else if (error.code == "invalid-credential") {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid Credentials"),
            ),
          );
        } else if (error.code == "invalid-email") {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid Credentials"),
            ),
          );
        } else if (error.code == "network-request-failed") {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No Internet Connection"),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Unknown Error Occurred! Please try again"),
            ),
          );
        }

        // after completion of authentication set authentication state -> false
        setState(() {
          _isAuthenticating = false;
        });
      }
    } else {
      // if profile pic is not selected
      if (_userProfile == null) {
        setState(() {
          _profilePicError = true;
        });
      } else {
        setState(() {
          _profilePicError = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // Appbar
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
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
          // display Title conditionally
          text: _isLogin ? "Login" : "Sign Up",
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).highlightColor,
        ),
        centerTitle: true,
      ),

      // Body
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).cardColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Pic Field
                      if (!_isLogin)
                        Align(
                          alignment: Alignment.center,
                          child: UploadProfilePic(
                            setSelectedImage: _setProfilePic,
                          ),
                        ),
                      // If user clicks Sign up without selecting profile pic
                      if (!_isLogin && _profilePicError)
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Select Profile Pic",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ),

                      // Name Field
                      if (!_isLogin)
                        MyText(
                          text: "Name",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).hintColor,
                        ),
                      if (!_isLogin)
                        InputBox(
                          text: "",
                          enabled: true,
                          enableSuggestions: false,
                          autocorrect: true,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Invalid Name";
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _userName = newValue;
                          },
                        ),
                      const SizedBox(height: 10),

                      // Email Field
                      MyText(
                        text: "Email",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).hintColor,
                      ),
                      InputBox(
                        enabled: true,
                        autocorrect: false,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              !value.contains("@")) {
                            return "Invalid Email";
                          }

                          return null;
                        },
                        onSaved: (newValue) {
                          _userEmail = newValue;
                        },
                      ),
                      const SizedBox(height: 10),

                      // Password Field
                      MyText(
                        text: _isLogin
                            ? "Master Password"
                            : "Create Master Password",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).hintColor,
                      ),
                      InputBox(
                        text: "",
                        enabled: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        obscureText: _obscureTextP,
                        textInputAction: TextInputAction.next,
                        suffixIcon: IconButton(
                          icon: SvgPicture.asset(
                            _obscureTextP ? icoEyeOpen : icoEyeClose,
                            width: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureTextP = !_obscureTextP;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Invalid Password";
                          } else if (value.length < 8) {
                            return "Password should be minimum of 8 characters";
                          }
                          return null;
                        },
                        onSaved: (newValue) {},
                        onChanged: (newValue) {
                          _userPass = newValue;
                        },
                      ),
                      const SizedBox(height: 10),

                      // Confirm Password Field
                      if (!_isLogin)
                        MyText(
                          text: "Confirm Master Password",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).hintColor,
                        ),
                      if (!_isLogin)
                        InputBox(
                          text: "",
                          enabled: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          obscureText: _obscureTextCP,
                          textInputAction: TextInputAction.done,
                          suffixIcon: IconButton(
                            icon: SvgPicture.asset(
                              _obscureTextCP ? icoEyeOpen : icoEyeClose,
                              width: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureTextCP = !_obscureTextCP;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value != _userPass) {
                              return "Password and Confirm Password don't match";
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _userConfPass = newValue;
                          },
                        ),
                    ],
                  ),
                ),

                // Action button (Login / Sign Up)
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: TextButton(
                    onPressed: !_isAuthenticating ? _authenticate : null,
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all<EdgeInsets>(
                        const EdgeInsets.symmetric(vertical: 12),
                      ),
                      backgroundColor: _isAuthenticating
                          ? WidgetStateProperty.all<Color>(Theme.of(context).primaryColorDark)
                          : WidgetStateProperty.all<Color>(Theme.of(context).primaryColor),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      foregroundColor: WidgetStateProperty.all<Color>(Theme.of(context).focusColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // show loading while state is authenticating
                        if (_isAuthenticating)
                          SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).focusColor),
                            ),
                          ),
                        if (_isAuthenticating) const SizedBox(width: 12),
                        MyText(
                          text: _isLogin ? "Login" : "Sign Up",
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).focusColor,
                        ),
                      ],
                    ),
                  ),
                ),

                // Toggle Button -> for _isLogin
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyText(
                      text: _isLogin
                          ? "Don't have an account!"
                          : "Already have an account!",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).highlightColor,
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: MyText(
                        text: _isLogin ? "Sign Up" : "Login",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UploadProfilePic extends ConsumerStatefulWidget {
  const UploadProfilePic({
    super.key,
    required this.setSelectedImage,
  });

  final Function(String) setSelectedImage;

  @override
  ConsumerState<UploadProfilePic> createState() {
    return _UploadProfilePicState();
  }
}

class _UploadProfilePicState extends ConsumerState<UploadProfilePic> {
  // Variable to store the selected image file
  File? _selectedImage;

  Function(String)? setSelectedImage;

  ImageProvider? profilePic;

  void setProfilePicWidget() {
    if (avatarList.contains(_selectedImage!.path)) {
      profilePic = AssetImage(_selectedImage!.path);
    } else {
      profilePic = FileImage(_selectedImage!);
    }
  }

  @override
  void initState() {
    super.initState();
    setSelectedImage = widget.setSelectedImage;
  }

  // Instantiating ImagePicker()
  final ImagePicker _picker = ImagePicker();

  // Function to allow user to select image (from gallery or camera -> depending on the arg)
  Future _getImage(ImageSource source) async {
    final pickedImage = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 600,
      maxHeight: 600,
    );

    if (pickedImage != null) {
      setState(() {
        // change the display image in container
        _selectedImage = File(pickedImage.path);
        setSelectedImage!(pickedImage.path);
        setProfilePicWidget();
      });
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      _cropImage();
    }
  }

  // Function to allow user to crop the selected image in a square shape
  Future<void> _cropImage() async {
    if (_selectedImage == null) return;

    final croppedImage = await ImageCropper().cropImage(
      sourcePath: _selectedImage!.path,
      aspectRatio: const CropAspectRatio(
          ratioX: 1, ratioY: 1), // Specify 1:1 aspect ratio for square
      compressQuality: 100,
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "Crop Image",
          activeControlsWidgetColor: Theme.of(context).primaryColor,
        ),
        IOSUiSettings(
          title: "Crop Image",
        ),
      ],
    );

    if (croppedImage != null) {
      setState(() {
        _selectedImage = File(croppedImage.path);
        setProfilePicWidget();
      });
    }
  }

  @override
  Widget build(context) {
    return Container(
      width: 120,
      height: 120,
      margin: const EdgeInsets.all(20),
      child: GestureDetector(
        onTap: selectProfile,
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: _selectedImage == null
                  ? const CircleAvatar(backgroundImage: AssetImage(user),)
                  : CircleAvatar(
                      backgroundImage: profilePic,
                      backgroundColor: Theme.of(context).cardColor,
                    ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Icon(Icons.mode_edit_outline_rounded, color: Theme.of(context).highlightColor),
            ),
          ],
        ),
      ),
    );
  }

  // Function to show dialog box displaying default list of profile avatars for user to choose
  void selectProfile() {
    int selectedAvatarIdx = 110;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          surfaceTintColor: Theme.of(context).cardColor,
          backgroundColor: Theme.of(context).cardColor,
          title: MyText(
            text: "Select Avatar",
            fontSize: 18,
            color: Theme.of(context).highlightColor,
            fontWeight: FontWeight.w500,
          ),
          content: StatefulBuilder(
            builder: (context, setState) => SizedBox(
              width: double.maxFinite,
              height: 400,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.0,
                ),
                itemCount: avatarList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedAvatarIdx = index;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: selectedAvatarIdx == index
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          width: 3.0,
                        ),
                      ),
                      child: Image.asset(
                        avatarList[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).primaryColor),
              ),
              onPressed: uploadProfile,
              child: MyText(
                text: "Upload",
                fontSize: 18,
                color: Theme.of(context).focusColor,
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).primaryColor),
              ),
              onPressed: () {
                setState(() {
                  if (selectedAvatarIdx >= 0 && selectedAvatarIdx < 60) {
                    // change the display image in container
                    _selectedImage = File(avatarList[selectedAvatarIdx]);
                    // ref.read(userProvider.notifier).addProfilePic(pickedImage.path);
                    setSelectedImage!(avatarList[selectedAvatarIdx]);
                    setProfilePicWidget();

                    Navigator.of(context).pop();
                  }
                });
              },
              child: MyText(
                text: "Save",
                fontSize: 18,
                color: Theme.of(context).focusColor,
              ),
            ),
          ],
          actionsAlignment: MainAxisAlignment.spaceBetween,
        );
      },
    );
  }

  // Function to show options dialog to choose profile pic from gallery or camera
  void uploadProfile() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.2,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Gallery Button
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 20),
                    child: Column(
                      children: [
                        IconButton(
                          icon: SvgPicture.asset(icoGallery, color: Theme.of(context).highlightColor,),
                          onPressed: () {
                            _getImage(ImageSource.gallery);
                          },
                        ),
                        MyText(
                          text: "Gallery",
                          fontSize: 14,
                          color: Theme.of(context).highlightColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                // Camera Button
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 20),
                    child: Column(
                      children: [
                        IconButton(
                          icon: SvgPicture.asset(icoCamera, color: Theme.of(context).highlightColor),
                          onPressed: () {
                            _getImage(ImageSource.camera);
                          },
                        ),
                        MyText(
                          text: "Camera",
                          fontSize: 14,
                          color: Theme.of(context).highlightColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
