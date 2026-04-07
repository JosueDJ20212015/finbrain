import 'package:flutter/material.dart';

import '../controllers/analytics_controller.dart';
import '../utils/app_colors.dart';
import '../widgets/analytics_bar_chart.dart';
import '../widgets/analytics_line_chart.dart';

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  final analyticsController = AnalyticsController();

  @override
  void initState() {
    super.initState();
    analyticsController.loadAnalytics(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  String formatMoney(double value) {
    return 'Lps ${value.toStringAsFixed(0)}';
  }

  Color get scoreColor {
    final score = analyticsController.financialScore;

    if (score >= 85) return AppColors.primary;
    if (score >= 70) return AppColors.cyan;
    if (score >= 55) return AppColors.yellow;
    return const Color(0xFFFF6B6B);
  }

  Widget buildMiniMetric({
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(0.92),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
          ),
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
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
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

  Widget buildChartCard({
    required String title,
    required Widget chart,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
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
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          chart,
        ],
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
          child: analyticsController.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
              : analyticsController.errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          analyticsController.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                  'Balance analítico',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: AppColors.card.withOpacity(0.94),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.07),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.10),
                                  blurRadius: 24,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.24),
                                  blurRadius: 18,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Balance actual',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  formatMoney(analyticsController.currentBalance),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 22),
                                AnalyticsLineChart(
                                  values: analyticsController.monthlyNetValues,
                                  labels: analyticsController.monthLabels,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              buildMiniMetric(
                                title: 'Ingresos',
                                value: formatMoney(analyticsController.totalIncome),
                                valueColor: AppColors.primarySoft,
                              ),
                              const SizedBox(width: 12),
                              buildMiniMetric(
                                title: 'Gastos',
                                value: formatMoney(analyticsController.totalExpenses),
                                valueColor: AppColors.textPrimary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              buildMiniMetric(
                                title: 'Deuda de tarjetas',
                                value: formatMoney(analyticsController.totalCardDebt),
                                valueColor: AppColors.pink,
                              ),
                              const SizedBox(width: 12),
                              buildMiniMetric(
                                title: 'Uso de crédito',
                                value:
                                    '${(analyticsController.cardUsage * 100).toStringAsFixed(0)}%',
                                valueColor: AppColors.yellow,
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.card.withOpacity(0.92),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.06),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.22),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 94,
                                  height: 94,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: scoreColor.withOpacity(0.28),
                                      width: 6,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: scoreColor.withOpacity(0.18),
                                        blurRadius: 18,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${analyticsController.financialScore}',
                                    style: TextStyle(
                                      color: scoreColor,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Score financiero',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        analyticsController.financialLabel,
                                        style: TextStyle(
                                          color: scoreColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        analyticsController.financialMessage,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.68),
                                          fontSize: 13,
                                          height: 1.45,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          buildChartCard(
                            title: 'Gastos de los últimos meses',
                            chart: AnalyticsBarChart(
                              values: analyticsController.monthlyExpenseValues,
                              labels: analyticsController.monthLabels,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              buildMiniMetric(
                                title: 'Presupuesto total',
                                value: formatMoney(analyticsController.budgetTotal),
                                valueColor: AppColors.textPrimary,
                              ),
                              const SizedBox(width: 12),
                              buildMiniMetric(
                                title: 'Uso del presupuesto',
                                value:
                                    '${(analyticsController.budgetUsage * 100).toStringAsFixed(0)}%',
                                valueColor: analyticsController.budgetUsage >= 0.85
                                    ? const Color(0xFFFF6B6B)
                                    : AppColors.primarySoft,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}