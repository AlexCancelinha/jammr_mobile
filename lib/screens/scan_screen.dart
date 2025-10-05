import 'dart:math';
import 'package:flutter/material.dart';

import '../services/backend_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with TickerProviderStateMixin {
  bool _loading = false;
  bool _scanned = false;
  bool _ballMoved = false;

  double get _baseScale => _ballMoved ? 0.3 : 1.0;

  late AnimationController _pulseController;
  late AnimationController _moveController;

  late Animation<Offset> _scanPositionAnimation;
  late Animation<double> _scanScaleAnimation;

  List<bool> _avatarVisible = [];

  List<Map<String, dynamic>> users = const [];

  @override
  void initState() {
    super.initState();

    // Pulsing controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.9,
      upperBound: 1.1,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _pulseController.forward();
      }
    });

    // Move & shrink controller
    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _moveController.dispose();
    super.dispose();
  }

  void _startScan() async {
    setState(() {
      _loading = true;
      _scanned = false;
      _avatarVisible = [];
    });

    // Simulate delay for "scanning"
    await Future.delayed(const Duration(seconds: 2));

    try {
      final fetchedUsers = await BackendService.fetchUsers();

      if (!mounted) return;

      setState(() {
        users = fetchedUsers;
        _loading = false;
        _scanned = true;
        _avatarVisible = List.filled(users.length, false);
      });

      // Show avatars one by one
      for (int i = 0; i < users.length; i++) {
        Future.delayed(Duration(milliseconds: 300 * i), () {
          if (mounted) setState(() => _avatarVisible[i] = true);
        });
      }

      if (!_ballMoved) {
        _moveController.forward();
        _ballMoved = true;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _scanned = false;
        });
      }
      print("Error fetching users: $e");
    }
  }

  /// ✅ Safe avatar widget with placeholder fallback
  Widget avatar(String? url, {double radius = 40}) {
    if (url == null || url.isEmpty || !url.startsWith("http")) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: const AssetImage('assets/images/default_avatar.png'),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(url),
      onBackgroundImageError: (_, __) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // ✅ Build tweens here, based on actual screen size
    _scanPositionAnimation = Tween<Offset>(
      begin: Offset(centerX - 90, centerY - 90),
      end: Offset(centerX - 90, size.height - 150),
    ).animate(CurvedAnimation(
      parent: _moveController,
      curve: Curves.easeInOut,
    ));

    _scanScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _moveController,
      curve: Curves.easeInOut,
    ));

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Stack(
          children: [
            // Loading spinner
            if (_loading)
              Positioned(
                bottom: size.height * 0.15,
                child: SizedBox(
                  width: size.width,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.greenAccent),
                      SizedBox(height: 12),
                      Text(
                        "Scanning nearby users...",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

            // Avatars in circle
            if (_scanned)
              ...List.generate(users.length, (index) {
                final angle = (2 * pi / users.length) * index;
                final radius = 180.0;

                final offsetX = radius * cos(angle);
                final offsetY = radius * sin(angle);

                final user = users[index];

                return Positioned(
                  left: centerX + offsetX - 40,
                  top: centerY + offsetY - 40,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 600),
                    opacity: _avatarVisible[index] ? 1.0 : 0.0,
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(user["name"] ?? ""),
                            content: Text("🎶 ${user["currentSong"] ?? "Unknown"}"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Close"),
                              )
                            ],
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          avatar(user["avatarUrl"], radius: 40),
                          Text(
                            user["name"] ?? "",
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

            // Scan button
            AnimatedBuilder(
              animation: Listenable.merge([_pulseController, _moveController]),
              builder: (context, child) {
                final scale = _baseScale * _pulseController.value;
                final offset = _scanPositionAnimation.value;

                return Positioned(
                  left: offset.dx,
                  top: offset.dy,
                  child: Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                );
              },
              child: GestureDetector(
                onTap: _startScan,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.greenAccent,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.6),
                        blurRadius: 40,
                        spreadRadius: 15,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.waves, size: 90, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
