import 'package:flutter/material.dart';

import '../controllers/movements_controller.dart';
import '../models/transaction_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_snackbar.dart';
import '../widgets/transaction_tile.dart';

class MovementsView extends StatefulWidget {
  const MovementsView({super.key});

  @override
  State<MovementsView> createState() => _MovementsViewState();
}

class _MovementsViewState extends State<MovementsView> {
  final movementsController = MovementsController();

  @override
  void initState() {
    super.initState();
    movementsController.initialize(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    movementsController.dispose();
    super.dispose();
  }

  String formatMoney(double value) {
    return 'Lps ${value.toStringAsFixed(2)}';
  }

  Future<void> confirmDelete(TransactionModel transaction) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text(
            'Eliminar movimiento',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            '¿Deseas eliminar "${transaction.title}"?',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (result != true) {
      return;
    }

    try {
      await movementsController.deleteMovement(transaction.id);

      if (!mounted) {
        return;
      }

      AppSnackbar.success(context, 'Movimiento eliminado correctamente.');
    } catch (_) {
      AppSnackbar.error(context, 'No se pudo eliminar el movimiento.');
    }
  }

  Widget buildFilterChip({
    required String id,
    required String label,
  }) {
      final isSelected = movementsController.selectedTypeFilter == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          movementsController.applyTypeFilter(id);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.14)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withOpacity(0.30)
                : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primarySoft : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget buildSummaryCard({
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(0.90),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.pageGradient,
        ),
        child: SafeArea(
          child: movementsController.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
              : movementsController.errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          movementsController.errorMessage!,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Expanded(
                                child: Text(
                                  'Movimientos',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              buildSummaryCard(
                                title: 'Ingresos',
                                value: formatMoney(movementsController.totalIncome),
                                valueColor: AppColors.primarySoft,
                              ),
                              const SizedBox(width: 12),
                              buildSummaryCard(
                                title: 'Gastos',
                                value:
                                    formatMoney(movementsController.totalExpenses),
                                valueColor: AppColors.textPrimary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.card.withOpacity(0.90),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.06),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Balance filtrado',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  formatMoney(movementsController.balance),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              buildFilterChip(id: 'all', label: 'Todos'),
                              const SizedBox(width: 10),
                              buildFilterChip(id: 'income', label: 'Ingresos'),
                              const SizedBox(width: 10),
                              buildFilterChip(id: 'expense', label: 'Gastos'),
                            ],
                          ),
                          const SizedBox(height: 18),
                          if (movementsController.visibleTransactions.isEmpty)
                            Expanded(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 28,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 92,
                                        height: 92,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              AppColors.primary.withOpacity(0.14),
                                        ),
                                        child: const Icon(
                                          Icons.receipt_long_rounded,
                                          size: 42,
                                          color: AppColors.primarySoft,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        'No hay movimientos aún',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Cuando registres ingresos o gastos aparecerán aquí.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.64),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          else
                            Expanded(
                              child: ListView.separated(
                                itemCount:
                                    movementsController.visibleTransactions.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final transaction = movementsController
                                      .visibleTransactions[index];

                                  return TransactionTile(
                                    transaction: transaction,
                                    onDelete: () {
                                      confirmDelete(transaction);
                                    },
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}