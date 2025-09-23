import 'dart:math';
import 'package:flutter/material.dart';

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

  final List<Map<String, String>> users = const [
    {
      "name": "Alice",
      "avatar": "https://i.pravatar.cc/150?img=1",
      "song": "Blinding Lights - The Weeknd"
    },
    {
      "name": "Bob",
      "avatar": "https://i.pravatar.cc/150?img=2",
      "song": "Levitating - Dua Lipa"
    },
    {
      "name": "Charlie",
      "avatar": "https://i.pravatar.cc/150?img=3",
      "song": "Peaches - Justin Bieber"
    },
  ];

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

  void _startScan() {
    setState(() {
      _loading = true;
      _scanned = false;
      _avatarVisible = List.filled(users.length, false);
    });

    _pulseController.forward(from: 0.0); // start pulse from current value

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _scanned = true;
      });

      // Show avatars one by one
      for (int i = 0; i < users.length; i++) {
        Future.delayed(Duration(milliseconds: 300 * i), () {
          if (mounted) setState(() => _avatarVisible[i] = true);
        });
      }

      // Move & shrink only the first time
      if (!_ballMoved) {
        _moveController.forward();
        _ballMoved = true;
      }
    });
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
                left: centerX - 60,
                child: const Column(
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
                            title: Text(user["name"]!),
                            content: Text("🎶 ${user["song"]}"),
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
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(user["avatar"]!),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user["name"]!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
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
