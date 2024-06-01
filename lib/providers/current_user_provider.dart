// Stores the current user data -> Name, UID, MasterPassword

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:password_manager/utils/constants.dart';

class CurrentUserNotifier extends StateNotifier<Map<Enum, String>> {
  CurrentUserNotifier() : super({});

  void updateData(String email, String name, String uid, String masterPass, String userProfile) {
    state = {
      CurrentUser.email: email,
      CurrentUser.name: name,
      CurrentUser.uid: uid,
      CurrentUser.masterPass: masterPass,
      CurrentUser.userProfile: userProfile,
    };
  }

  void clearData() {
    state = {};
  }
}

final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, Map<Enum, String>>(
  (ref) => CurrentUserNotifier(),
);
