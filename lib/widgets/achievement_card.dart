import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AchievementCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final Color color;

  const AchievementCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAchievementDetails(context),
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked
              ? color.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked
                ? color.withOpacity(0.3)
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: isUnlocked ? color : Colors.grey,
                ),
                if (isUnlocked)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 8,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isUnlocked ? Colors.black : Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAchievementDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: isUnlocked ? color : Colors.grey),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
            if (isUnlocked)
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? Colors.green.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isUnlocked ? Icons.check : Icons.lock,
                    size: 16,
                    color: isUnlocked ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isUnlocked ? 'Unlocked' : 'Locked',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Enhanced user provider extensions
extension UserProfileExtensions on User {
  String get displayInitials {
    if (displayName?.isNotEmpty == true) {
      final names = displayName!.split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      }
      return displayName![0].toUpperCase();
    }
    return email?[0].toUpperCase() ?? 'U';
  }

  String get shortName {
    if (displayName?.isNotEmpty == true) {
      return displayName!.split(' ')[0];
    }
    return 'User';
  }

  bool get hasCompleteProfile {
    return displayName?.isNotEmpty == true &&
        email?.isNotEmpty == true &&
        photoURL?.isNotEmpty == true;
  }
}
