import 'package:flutter/material.dart';
import '../../../models/user_model.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final bool visible;

  const UserCard({
    super.key,
    required this.user,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    final avatarImage = (user.avatarUrl != null && user.avatarUrl!.startsWith('http'))
        ? NetworkImage(user.avatarUrl!)
        : const AssetImage('assets/images/default_avatar.png') as ImageProvider;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 600),
      opacity: visible ? 1.0 : 0.0,
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(user.name),
              content: Text('🎶 ${user.currentSong ?? "Unknown song"}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            ),
          );
        },
        child: Column(
          children: [
            CircleAvatar(radius: 40, backgroundImage: avatarImage),
            Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
