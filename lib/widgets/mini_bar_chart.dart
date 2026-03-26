import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class MiniBarChart extends StatelessWidget {
  final List<double> values;

  const MiniBarChart({
    super.key,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    final colors = <Color>[
      AppColors.pink,
      AppColors.purple,
      AppColors.blue,
      AppColors.cyan,
      AppColors.primary,
    ];

    return SizedBox(
      height: 92,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: List.generate(values.length, (index) {
          final value = values[index].clamp(0.08, 1.0);

          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Container(
              width: 16,
              height: 70 * value,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: colors[index % colors.length],
                  width: 1.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors[index % colors.length].withOpacity(0.18),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}