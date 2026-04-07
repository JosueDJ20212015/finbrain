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

    final fixedHeights = <double>[
      18,
      24,
      30,
      34,
      38,
    ];

    return SizedBox(
      height: 92,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: List.generate(fixedHeights.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Container(
              width: 16,
              height: fixedHeights[index],
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