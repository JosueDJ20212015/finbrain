import 'package:flutter/material.dart';

import '../controllers/balance_general_controller.dart';
import '../utils/app_colors.dart';

class BalanceGeneralSheetView extends StatefulWidget {
  const BalanceGeneralSheetView({super.key});

  @override
  State<BalanceGeneralSheetView> createState() =>
      _BalanceGeneralSheetViewState();
}

class _BalanceGeneralSheetViewState extends State<BalanceGeneralSheetView> {
  final balanceGeneralController = BalanceGeneralController();

  @override
  void initState() {
    super.initState();
    balanceGeneralController.loadSummary(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  String formatMoney(double value) {
    return 'Lps ${value.toStringAsFixed(2)}';
  }

  Color amountColor(double value) {
    if (value < 0) {
      return const Color(0xFFFF6B6B);
    }

    return AppColors.textPrimary;
  }

  Widget buildSummaryCard({
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(0.92),
          borderRadius: BorderRadius.circular(20),
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

  Widget buildTableRow({
    required String concept,
    required String type,
    required double amount,
    required bool isLiability,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              concept,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              type,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isLiability ? AppColors.pink : AppColors.primarySoft,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              formatMoney(amount),
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isLiability
                    ? const Color(0xFFFF6B6B)
                    : AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final summary = balanceGeneralController.summary;

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
          child: balanceGeneralController.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
              : balanceGeneralController.errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          balanceGeneralController.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  : summary == null
                      ? const Center(
                          child: Text(
                            'No hay información disponible.',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
                                      'Balance General',
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
                              const SizedBox(height: 14),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          buildSummaryCard(
                                            title: 'Patrimonio real',
                                            value: formatMoney(summary.netWorth),
                                            valueColor:
                                                amountColor(summary.netWorth),
                                          ),
                                          const SizedBox(width: 12),
                                          buildSummaryCard(
                                            title: 'Deuda tarjetas',
                                            value: formatMoney(
                                              summary.totalCardDebt,
                                            ),
                                            valueColor:
                                                const Color(0xFFFF6B6B),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          buildSummaryCard(
                                            title: 'Balance actual',
                                            value: formatMoney(
                                              summary.currentBalance,
                                            ),
                                            valueColor: amountColor(
                                              summary.currentBalance,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          buildSummaryCard(
                                            title: 'Presupuesto disponible',
                                            value: formatMoney(
                                              summary.budgetAvailable,
                                            ),
                                            valueColor: AppColors.primarySoft,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 18),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(18),
                                        decoration: BoxDecoration(
                                          color: AppColors.card.withOpacity(0.92),
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.06),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Resumen tipo hoja financiera',
                                              style: TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Row(
                                              children: [
                                                Expanded(
                                                  flex: 4,
                                                  child: Text(
                                                    'Concepto',
                                                    style: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(0.54),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    'Tipo',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(0.54),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    'Monto',
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(0.54),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            buildTableRow(
                                              concept: 'Ingresos acumulados',
                                              type: 'Activo',
                                              amount: summary.totalIncome,
                                              isLiability: false,
                                            ),
                                            buildTableRow(
                                              concept: 'Gastos acumulados',
                                              type: 'Salida',
                                              amount: summary.totalExpenses,
                                              isLiability: false,
                                            ),
                                            buildTableRow(
                                              concept: 'Balance actual',
                                              type: 'Activo',
                                              amount: summary.currentBalance,
                                              isLiability: false,
                                            ),
                                            buildTableRow(
                                              concept: 'Presupuesto disponible',
                                              type: 'Activo',
                                              amount: summary.budgetAvailable,
                                              isLiability: false,
                                            ),
                                            buildTableRow(
                                              concept: 'Deuda total de tarjetas',
                                              type: 'Pasivo',
                                              amount: summary.totalCardDebt,
                                              isLiability: true,
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 16,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withOpacity(0.08),
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                border: Border.all(
                                                  color: AppColors.primary
                                                      .withOpacity(0.18),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Expanded(
                                                    child: Text(
                                                      'Patrimonio real',
                                                      style: TextStyle(
                                                        color: AppColors
                                                            .textPrimary,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    formatMoney(
                                                      summary.netWorth,
                                                    ),
                                                    style: TextStyle(
                                                      color: amountColor(
                                                        summary.netWorth,
                                                      ),
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
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