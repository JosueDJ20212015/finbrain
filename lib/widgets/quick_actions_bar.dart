import 'package:flutter/material.dart';

import '../models/quick_action_model.dart';
import '../utils/app_colors.dart';

class QuickActionsBar extends StatelessWidget {
  final List<QuickActionModel> actions;
  final String selectedActionId;
  final ValueChanged<QuickActionModel> onActionTap;

  const QuickActionsBar({
    super.key,
    required this.actions,
    required this.selectedActionId,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: actions.map((action) {
          final isSelected = selectedActionId == action.id;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => onActionTap(action),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSelected
                          ? [
                              AppColors.primary.withOpacity(0.16),
                              AppColors.cyan.withOpacity(0.10),
                            ]
                          : [
                              Colors.white.withOpacity(0.03),
                              Colors.white.withOpacity(0.02),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.24)
                          : Colors.white.withOpacity(0.04),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        action.icon,
                        color: isSelected
                            ? AppColors.primarySoft
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOut,
                        child: isSelected
                            ? Row(
                                children: [
                                  const SizedBox(width: 8),
                                  Text(
                                    action.title,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}