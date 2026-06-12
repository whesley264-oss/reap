import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class StorageIndicator extends StatelessWidget {
  final double percent;
  final String label;
  final String value;

  const StorageIndicator({
    super.key,
    required this.percent,
    required this.label,
    required this.value,
  });

  Color get _color {
    if (percent >= 90) return AppColors.error;
    if (percent >= 75) return AppColors.warning;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent / 100,
            backgroundColor: AppColors.grey200,
            valueColor: AlwaysStoppedAnimation<Color>(_color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}