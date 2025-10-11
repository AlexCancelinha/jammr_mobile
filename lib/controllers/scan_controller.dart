import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/scan_service.dart';

class ScanController extends ChangeNotifier {
  bool loading = false;
  bool scanned = false;
  bool ballMoved = false;
  List<bool> avatarVisible = [];
  List<UserModel> users = [];

  Future<void> startScan(VoidCallback onMoveBall) async {
    loading = true;
    scanned = false;
    avatarVisible = [];
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    try {
      final fetchedUsers = await ScanService.fetchUsers();
      users = fetchedUsers;
      loading = false;
      scanned = true;
      avatarVisible = List.filled(users.length, false);
      notifyListeners();

      // Animate one by one
      for (int i = 0; i < users.length; i++) {
        await Future.delayed(Duration(milliseconds: 300 * i));
        avatarVisible[i] = true;
        notifyListeners();
      }

      if (!ballMoved) {
        ballMoved = true;
        onMoveBall();
      }
    } catch (e) {
      loading = false;
      scanned = false;
      notifyListeners();
      debugPrint("Error fetching users: $e");
    }
  }
}
