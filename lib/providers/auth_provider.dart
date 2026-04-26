import 'package:flutter/material.dart';
import '../data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoggedIn = false;
  bool isLoading = false;
  String? username;
  String? errorMessage;

  Future<void> checkAuth() async {
    isLoading = true;
    notifyListeners();

    isLoggedIn = await AuthService.isLoggedIn();
    if (isLoggedIn) {
      username = await AuthService.getUsername();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String user, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final data = await AuthService.login(user, password);
      username = data["username"];
      isLoggedIn = true;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceAll("Exception: ", "");
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    isLoggedIn = false;
    username = null;
    notifyListeners();
  }
}