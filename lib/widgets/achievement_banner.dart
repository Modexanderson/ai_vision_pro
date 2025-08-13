// widgets/achievement_banner.dart

import 'package:flutter/material.dart';
import '../models/achievement.dart';

class AchievementBanner extends StatelessWidget {
  final Achievement achievement;

  const AchievementBanner({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: achievement.isUnlocked
            ? achievement.color.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.isUnlocked
              ? achievement.color.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: achievement.isUnlocked ? achievement.color : Colors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              achievement.icon,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: achievement.isUnlocked
                        ? Colors.black
                        : Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 10,
                    color: achievement.isUnlocked
                        ? Colors.grey[600]
                        : Colors.grey[500],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            achievement.isUnlocked ? Icons.check_circle : Icons.lock,
            color:
                achievement.isUnlocked ? achievement.color : Colors.grey[400],
            size: 16,
          ),
        ],
      ),
    );
  }
}
