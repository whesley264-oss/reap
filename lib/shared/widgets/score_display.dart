import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ScoreDisplay extends StatelessWidget {
  final int score;
  final String label;
  final bool large;

  const ScoreDisplay({
    super.key,
    required this.score,
    required this.label,
    this.large = true,
  });

  Color get _scoreColor {
    if (score >= 95) return AppColors.scoreExcellent;
    if (score >= 80) return AppColors.scoreGood;
    if (score >= 60) return AppColors.scoreWarning;
    return AppColors.scoreCritical;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: large ? 120 : 80,
          height: large ? 120 : 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _scoreColor,
              width: large ? 8 : 6,
            ),
          ),
          child: Center(
            child: Text(
              score.toString(),
              style: TextStyle(
                fontSize: large ? 48 : 32,
                fontWeight: FontWeight.bold,
                color: _scoreColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: _scoreColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: large ? 16 : 14,
              fontWeight: FontWeight.w600,
              color: _scoreColor,
            ),
          ),
        ),
      ],
    );
  }
}