import 'package:flutter/material.dart';

import '../controllers/dashboard_controller.dart';
import '../utils/app_colors.dart';
import '../utils/app_snackbar.dart';
import '../views/cards_view.dart';
import '../widgets/alerts_card.dart';
import '../widgets/balance_card.dart';
import '../widgets/budget_card.dart';
import '../widgets/cards_summary_card.dart';
import '../widgets/category_chart_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/quick_actions_bar.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final dashboardController = DashboardController();

  static const double smallCardHeight = 210;
  static const double quickActionsReservedSpace = 120;

  @override
  void initState() {
    super.initState();
    dashboardController.listenDashboard(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    dashboardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summary = dashboardController.summary;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.pageGradient,
        ),
        child: SafeArea(
          child: dashboardController.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
              : dashboardController.errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          dashboardController.errorMessage!,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : summary == null
                      ? const Center(
                          child: Text(
                            'No hay información para mostrar.',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            14,
                            20,
                            quickActionsReservedSpace,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DashboardHeader(
                                appTitle: 'finBrain',
                                userName: dashboardController.displayName,
                                photoUrl: summary.photoUrl,
                                onLogout: () async {
                                  await dashboardController.signOut();
                                },
                              ),
                              const SizedBox(height: 22),
                              BalanceCard(
                                currentBalance: summary.currentBalance,
                                totalIncome: summary.totalIncome,
                                totalExpenses: summary.totalExpenses,
                                chartBars: summary.chartBars,
                                onTap: () {
                                  AppSnackbar.info(
                                    context,
                                    'Pronto verás el detalle del balance.',
                                  );
                                },
                              ),
                              const SizedBox(height: 18),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: smallCardHeight,
                                      child: BudgetCard(
                                        budgetSummary: summary.budgetSummary,
                                        onTap: () {
                                          AppSnackbar.info(
                                            context,
                                            'Pronto verás el detalle del presupuesto.',
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: SizedBox(
                                      height: smallCardHeight,
                                      child: CategoryChartCard(
                                        items: summary.categoryExpenses,
                                        onTap: () {
                                          AppSnackbar.info(
                                            context,
                                            'Pronto verás los gastos por categoría.',
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: smallCardHeight,
                                      child: CardsSummaryCard(
                                        cardsCount: summary.cardsCount,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const CardsView(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: SizedBox(
                                      height: smallCardHeight,
                                      child: AlertsCard(
                                        alerts: summary.alerts,
                                        onTap: () {
                                          AppSnackbar.info(
                                            context,
                                            'Pronto verás todas tus alertas.',
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: AppColors.pageGradient,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 18,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: QuickActionsBar(
              actions: dashboardController.quickActions,
              onActionTap: (action) {
                AppSnackbar.info(
                  context,
                  'La acción ${action.title} se conectará después.',
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}