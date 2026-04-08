import 'package:flutter/material.dart';

import '../controllers/dashboard_controller.dart';
import '../services/transaction_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_snackbar.dart';
import '../views/analytics_view.dart';
import '../views/balance_general_sheet_view.dart';
import '../views/cards_view.dart';
import '../views/movements_sheet_view.dart';
import '../widgets/alerts_card.dart';
import '../widgets/alerts_dialog.dart';
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
  final transactionService = TransactionService();

  static const double smallCardHeight = 200;
  static const double quickActionsReservedSpace = 120;

  String selectedActionId = '';

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

  Future<void> showTransactionBottomSheet({
    required String type,
  }) async {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    DateTime selectedDate = DateTime.now();
    bool isRecurring = false;

    String selectedCategory = type == 'income' ? 'Salario' : 'Comida';
    String selectedClassification =
        type == 'income' ? 'recurrent' : 'variable';
    String selectedRecurrence = 'monthly';

    final incomeCategories = <String>[
      'Salario',
      'Freelance',
      'Bono',
      'Venta',
      'Otro ingreso',
    ];

    final expenseCategories = <String>[
      'Comida',
      'Transporte',
      'Servicios básicos',
      'Salud',
      'Entretenimiento',
      'Educación',
      'Compras',
      'Otros',
    ];

    final categories = type == 'income' ? incomeCategories : expenseCategories;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type == 'income' ? 'Registrar ingreso' : 'Registrar gasto',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _DashboardField(
                      controller: titleController,
                      label: 'Concepto',
                      hintText: type == 'income'
                          ? 'Salario, freelance, bono...'
                          : 'Supermercado, transporte, luz...',
                    ),
                    const SizedBox(height: 14),
                    _DashboardField(
                      controller: amountController,
                      label: 'Monto',
                      hintText: '1500',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      dropdownColor: AppColors.card,
                      decoration: dashboardInputDecoration(
                        label: 'Categoría',
                        hintText: 'Selecciona una categoría',
                      ),
                      items: categories.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedCategory = value ?? categories.first;
                        });
                      },
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: selectedClassification,
                      dropdownColor: AppColors.card,
                      decoration: dashboardInputDecoration(
                        label: 'Clasificación',
                        hintText: 'Selecciona un tipo',
                      ),
                      items: (type == 'income'
                              ? const ['recurrent', 'variable']
                              : const ['fixed', 'variable'])
                          .map((item) {
                        final label = switch (item) {
                          'recurrent' => 'Recurrente',
                          'fixed' => 'Fijo',
                          _ => 'Variable',
                        };

                        return DropdownMenuItem(
                          value: item,
                          child: Text(label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedClassification =
                              value ?? selectedClassification;
                        });
                      },
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      value: isRecurring,
                      activeColor: AppColors.primary,
                      title: const Text(
                        '¿Es recurrente?',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        'Actívalo si este movimiento se repite periódicamente.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.58),
                          fontSize: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setModalState(() {
                          isRecurring = value;
                          if (!isRecurring) {
                            selectedRecurrence = 'monthly';
                          }
                        });
                      },
                    ),
                    if (isRecurring) ...[
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: selectedRecurrence,
                        dropdownColor: AppColors.card,
                        decoration: dashboardInputDecoration(
                          label: 'Frecuencia',
                          hintText: 'Selecciona una frecuencia',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'weekly',
                            child: Text('Semanal'),
                          ),
                          DropdownMenuItem(
                            value: 'biweekly',
                            child: Text('Quincenal'),
                          ),
                          DropdownMenuItem(
                            value: 'monthly',
                            child: Text('Mensual'),
                          ),
                        ],
                        onChanged: (value) {
                          setModalState(() {
                            selectedRecurrence = value ?? 'monthly';
                          });
                        },
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2100),
                        );

                        if (pickedDate != null) {
                          setModalState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardSoft,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Fecha',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              formatDate(selectedDate),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _DashboardField(
                      controller: notesController,
                      label: 'Notas',
                      hintText: 'Opcional',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          final title = titleController.text.trim();
                          final amount = double.tryParse(
                            amountController.text.trim(),
                          );
                          final notes = notesController.text.trim();

                          if (title.isEmpty || amount == null || amount <= 0) {
                            AppSnackbar.error(
                              context,
                              'Completa correctamente los datos.',
                            );
                            return;
                          }

                          try {
                            await transactionService.createTransaction(
                              type: type,
                              title: title,
                              category: selectedCategory,
                              classification: selectedClassification,
                              amount: amount,
                              date: selectedDate,
                              notes: notes,
                              isRecurring: isRecurring,
                              recurrence:
                                  isRecurring ? selectedRecurrence : 'none',
                            );

                            if (!mounted) {
                              return;
                            }

                            Navigator.pop(context);
                            AppSnackbar.success(
                              context,
                              type == 'income'
                                  ? 'Ingreso registrado correctamente.'
                                  : 'Gasto registrado correctamente.',
                            );
                          } catch (_) {
                            AppSnackbar.error(
                              context,
                              'No se pudo guardar el movimiento.',
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: const Color(0xFF0B1418),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          type == 'income'
                              ? 'Guardar ingreso'
                              : 'Guardar gasto',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> showBudgetBottomSheet() async {
    final amountController = TextEditingController();
    String selectedPeriod = 'monthly';

    final currentBudget = dashboardController.summary?.budgetSummary;
    if (currentBudget != null && currentBudget.totalBudget > 0) {
      amountController.text = currentBudget.totalBudget.toStringAsFixed(0);
      selectedPeriod = currentBudget.period;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configurar presupuesto',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _DashboardField(
                      controller: amountController,
                      label: 'Monto del presupuesto',
                      hintText: '10000',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: selectedPeriod,
                      dropdownColor: AppColors.card,
                      decoration: dashboardInputDecoration(
                        label: 'Periodo',
                        hintText: 'Selecciona un periodo',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'weekly',
                          child: Text('Semanal'),
                        ),
                        DropdownMenuItem(
                          value: 'monthly',
                          child: Text('Mensual'),
                        ),
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          selectedPeriod = value ?? 'monthly';
                        });
                      },
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          final totalBudget =
                              double.tryParse(amountController.text.trim());

                          if (totalBudget == null || totalBudget < 0) {
                            AppSnackbar.error(
                              context,
                              'Ingresa un monto válido.',
                            );
                            return;
                          }

                          try {
                            await transactionService.setBudget(
                              totalBudget: totalBudget,
                              period: selectedPeriod,
                            );

                            if (!mounted) {
                              return;
                            }

                            Navigator.pop(context);
                            AppSnackbar.success(
                              context,
                              'Presupuesto actualizado correctamente.',
                            );
                          } catch (_) {
                            AppSnackbar.error(
                              context,
                              'No se pudo guardar el presupuesto.',
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: const Color(0xFF0B1418),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          'Guardar presupuesto',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> showMovementsBottomSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MovementsSheetView(),
    );
  }

  Future<void> showBalanceGeneralBottomSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BalanceGeneralSheetView(),
    );
  }

  Future<void> handleQuickActionTap(String actionId) async {
    setState(() {
      selectedActionId = actionId;
    });

    switch (actionId) {
      case 'expense':
        await showTransactionBottomSheet(type: 'expense');
        break;
      case 'income':
        await showTransactionBottomSheet(type: 'income');
        break;
      case 'movements':
        await showMovementsBottomSheet();
        break;
      case 'generalBalance':
        await showBalanceGeneralBottomSheet();
        break;
      default:
        break;
    }

    if (mounted) {
      setState(() {
        selectedActionId = '';
      });
    }
  }

  String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AnalyticsView(),
                                    ),
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
                                        onTap: showBudgetBottomSheet,
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
                                          AlertsDialog.show(
                                            context,
                                            alerts: summary.alerts,
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
              selectedActionId: selectedActionId,
              onActionTap: (action) {
                handleQuickActionTap(action.id);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final TextInputType keyboardType;
  final int maxLines;

  const _DashboardField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
      ),
      cursorColor: AppColors.primary,
      decoration: dashboardInputDecoration(
        label: label,
        hintText: hintText,
      ),
    );
  }
}

InputDecoration dashboardInputDecoration({
  required String label,
  required String hintText,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hintText,
    labelStyle: const TextStyle(
      color: AppColors.textSecondary,
      fontSize: 13,
    ),
    hintStyle: TextStyle(
      color: Colors.white.withOpacity(0.36),
    ),
    filled: true,
    fillColor: AppColors.cardSoft,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 18,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(
        color: Colors.white.withOpacity(0.06),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(
        color: AppColors.primary,
        width: 1.3,
      ),
    ),
  );
}