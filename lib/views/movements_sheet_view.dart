import 'package:flutter/material.dart';

import '../controllers/movements_controller.dart';
import '../models/transaction_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_snackbar.dart';
import '../widgets/transaction_tile.dart';

class MovementsSheetView extends StatefulWidget {
  const MovementsSheetView({super.key});

  @override
  State<MovementsSheetView> createState() => _MovementsSheetViewState();
}

class _MovementsSheetViewState extends State<MovementsSheetView> {
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

  Future<void> pickCustomRange() async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
      initialDateRange: movementsController.customRange ??
          DateTimeRange(
            start: DateTime(now.year, now.month, 1),
            end: now,
          ),
    );

    if (result == null) {
      return;
    }

    setState(() {
      movementsController.applyCustomRange(result);
    });
  }

  Widget buildTypeChip({
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

  Widget buildDateChip({
    required MovementsDateFilter filter,
    required String label,
    required VoidCallback onTap,
  }) {
    final isSelected = movementsController.selectedDateFilter == filter;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
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
            fontSize: 12,
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

  Widget buildProjectionCard() {
    final projectedIncome = movementsController.projectedMonthIncome;
    final projectedExpenses = movementsController.projectedMonthExpenses;
    final projectedBalance = movementsController.projectedMonthBalance;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Proyección del flujo de caja mensual',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Estimación basada en el ritmo actual del mes.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.56),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ProjectionMiniMetric(
                  title: 'Ingreso estimado',
                  value: formatMoney(projectedIncome),
                  valueColor: AppColors.primarySoft,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProjectionMiniMetric(
                  title: 'Gasto estimado',
                  value: formatMoney(projectedExpenses),
                  valueColor: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: projectedBalance < 0
                  ? const Color(0xFFFF6B6B).withOpacity(0.10)
                  : AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: projectedBalance < 0
                    ? const Color(0xFFFF6B6B).withOpacity(0.20)
                    : AppColors.primary.withOpacity(0.18),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Balance proyectado',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  formatMoney(projectedBalance),
                  style: TextStyle(
                    color: projectedBalance < 0
                        ? const Color(0xFFFF6B6B)
                        : AppColors.primarySoft,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.92,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: SafeArea(
          top: false,
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
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      child: Column(
                        children: [
                          Container(
                            width: 52,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
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
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    movementsController.activeRangeLabel,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.56),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        buildDateChip(
                                          filter: MovementsDateFilter.all,
                                          label: 'Todo',
                                          onTap: () {
                                            setState(() {
                                              movementsController.applyDateFilter(
                                                MovementsDateFilter.all,
                                              );
                                            });
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        buildDateChip(
                                          filter: MovementsDateFilter.today,
                                          label: 'Hoy',
                                          onTap: () {
                                            setState(() {
                                              movementsController.applyDateFilter(
                                                MovementsDateFilter.today,
                                              );
                                            });
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        buildDateChip(
                                          filter: MovementsDateFilter.week,
                                          label: 'Semana',
                                          onTap: () {
                                            setState(() {
                                              movementsController.applyDateFilter(
                                                MovementsDateFilter.week,
                                              );
                                            });
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        buildDateChip(
                                          filter: MovementsDateFilter.month,
                                          label: 'Mes',
                                          onTap: () {
                                            setState(() {
                                              movementsController.applyDateFilter(
                                                MovementsDateFilter.month,
                                              );
                                            });
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        buildDateChip(
                                          filter: MovementsDateFilter.custom,
                                          label: 'Personalizado',
                                          onTap: pickCustomRange,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        buildTypeChip(id: 'all', label: 'Todos'),
                                        const SizedBox(width: 10),
                                        buildTypeChip(
                                          id: 'income',
                                          label: 'Ingresos',
                                        ),
                                        const SizedBox(width: 10),
                                        buildTypeChip(
                                          id: 'expense',
                                          label: 'Gastos',
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      buildSummaryCard(
                                        title: 'Ingresos',
                                        value: formatMoney(
                                          movementsController.totalIncome,
                                        ),
                                        valueColor: AppColors.primarySoft,
                                      ),
                                      const SizedBox(width: 12),
                                      buildSummaryCard(
                                        title: 'Gastos',
                                        value: formatMoney(
                                          movementsController.totalExpenses,
                                        ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Balance del rango',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          formatMoney(movementsController.balance),
                                          style: TextStyle(
                                            color: movementsController.balance < 0
                                                ? const Color(0xFFFF6B6B)
                                                : AppColors.textPrimary,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  buildProjectionCard(),
                                  const SizedBox(height: 16),
                                  if (movementsController
                                      .visibleTransactions.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 28,
                                        vertical: 36,
                                      ),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Container(
                                              width: 92,
                                              height: 92,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.primary
                                                    .withOpacity(0.14),
                                              ),
                                              child: const Icon(
                                                Icons.receipt_long_rounded,
                                                size: 42,
                                                color: AppColors.primarySoft,
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            const Text(
                                              'No hay movimientos en este rango',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 24,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Prueba con otro filtro o registra nuevos movimientos.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.64),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  else
                                    ListView.separated(
                                      itemCount: movementsController
                                          .visibleTransactions.length,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
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
                                  const SizedBox(height: 12),
                                ],
                              ),
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

class _ProjectionMiniMetric extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;

  const _ProjectionMiniMetric({
    required this.title,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
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
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}