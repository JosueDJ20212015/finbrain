import 'package:flutter/material.dart';

import '../models/budget_summary_model.dart';
import '../utils/app_colors.dart';

class BudgetCard extends StatelessWidget {
  final BudgetSummaryModel budgetSummary;
  final VoidCallback onTap;

  const BudgetCard({
    super.key,
    required this.budgetSummary,
    required this.onTap,
  });

  String _formatCurrency(double value) {
    return 'Lps ${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Presupuesto',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Total: ${_formatCurrency(budgetSummary.totalBudget)}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Gastado: ${_formatCurrency(budgetSummary.spentAmount)}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Disponible: ${_formatCurrency(budgetSummary.availableAmount)}',
              style: const TextStyle(
                color: AppColors.primarySoft,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 16,
                color: AppColors.backgroundSecondary,
                child: FractionallySizedBox(
                  widthFactor: budgetSummary.progress,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.cyan,
                          AppColors.blue,
                          AppColors.primary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
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
