import 'package:flutter/material.dart';
import 'package:jammr_mobile/screens/scan/widgets/user_card.dart';
import 'package:provider/provider.dart';
import '../../controllers/scan_controller.dart';
import 'widgets/scan_button.dart';
import 'widgets/pulse_effect.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  double _buttonYPosition = 0.5; // 0.5 = middle, 0.9 = bottom
  double _buttonSize = 140;

  void _moveBallDown() {
    setState(() {
      _buttonYPosition = 0.9; // ⬇️ a bit lower than before (was 0.85)
      _buttonSize = 70;
    });
  }

  void _resetButton() {
    setState(() {
      _buttonYPosition = 0.5;
      _buttonSize = 140;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScanController(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final controller = Provider.of<ScanController>(context);
              final screenHeight = constraints.maxHeight;
              final screenWidth = constraints.maxWidth;

              // Calculate button position in pixels
              final buttonTop =
                  screenHeight * _buttonYPosition - _buttonSize / 2;
              final buttonLeft = screenWidth / 2 - _buttonSize / 2;
              final pulseScale = _buttonYPosition > 0.7 ? 0.7 : 1.0; // smaller at bottom

              return Stack(
                children: [
                  // Pulse effect that follows the button
                  // Pulse effect that follows the button
                  // Pulse effect that follows the button
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                    top: buttonTop - (_buttonSize * 1.8 - _buttonSize) / 2,
                    left: buttonLeft - (_buttonSize * 1.8 - _buttonSize) / 2,
                    child: IgnorePointer(
                      child: Transform.scale(
                        scale: pulseScale,
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: _buttonSize * 1.8,
                          height: _buttonSize * 1.8,
                          child: const PulseEffect(),
                        ),
                      ),
                    ),
                  ),

                  // Animated scan button
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                    top: buttonTop,
                    left: buttonLeft,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeInOut,
                      width: _buttonSize,
                      height: _buttonSize,
                      child: ScanButton(
                        isLoading: controller.loading,
                        size: _buttonSize,
                        onTap: () {
                          if (controller.loading) return;

                          if (controller.scanned) {
                            // reset scan and bring button back to center
                            controller.scanned = false;
                            controller.users = [];
                            controller.ballMoved = false;
                            _resetButton();
                            controller.notifyListeners();
                          } else {
                            controller.startScan(_moveBallDown);
                          }
                        },
                      ),
                    ),
                  ),

                  // User results (avatars / names)
                  if (controller.scanned && controller.users.isNotEmpty)
                    Positioned(
                      top: 80,
                      left: 0,
                      right: 0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i < controller.users.length; i++)
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: controller.avatarVisible[i] ? 1 : 0,
                              child: Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 8.0),
                                child: UserCard(
                                  user: controller.users[i],
                                  visible: controller.avatarVisible[i],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
