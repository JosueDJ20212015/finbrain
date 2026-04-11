import 'package:flutter/material.dart';

import '../controllers/analytics_controller.dart';
import '../models/category_expense_model.dart';
import '../utils/app_colors.dart';
import '../widgets/category_overview_ring.dart';
import 'category_expenses_detail_view.dart';

class CategorySelectionView extends StatefulWidget {
  final AnalyticsController analyticsController;

  const CategorySelectionView({
    super.key,
    required this.analyticsController,
  });

  @override
  State<CategorySelectionView> createState() => _CategorySelectionViewState();
}

class _CategorySelectionViewState extends State<CategorySelectionView> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      await widget.analyticsController.loadAnalytics(() {});
    } catch (_) {}

    if (!mounted) {
      return;
    }

    setState(() {
      isLoading = false;
    });
  }

  String formatMoney(double value) {
    return 'Lps ${value.toStringAsFixed(0)}';
  }

  double get totalSpent {
    return widget.analyticsController.categoryExpenses.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
  }

  void openCategory(CategoryExpenseModel category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryExpensesDetailView(
          categoryName: category.name,
          analyticsController: widget.analyticsController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.analyticsController.categoryExpenses;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.pageGradient,
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                      child: Row(
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
                              'Gastos por categoría',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: categories.isEmpty
                          ? const Center(
                              child: Text(
                                'No hay gastos registrados',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                              child: Column(
                                children: [
                                  Container(
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
                                      children: [
                                        const Text(
                                          'Resumen visual',
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Toca una categoría para ver el detalle',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.56),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                        CategoryOverviewRing(
                                          items: categories,
                                          onCategoryTap: openCategory,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: AppColors.card.withOpacity(0.92),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.06),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: _SummaryMiniCard(
                                            title: 'Categorías',
                                            value: '${categories.length}',
                                            valueColor: AppColors.primarySoft,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _SummaryMiniCard(
                                            title: 'Total',
                                            value: formatMoney(totalSpent),
                                            valueColor: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Lista rápida',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.86),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...categories.map((category) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: _CategoryListTile(
                                        category: category,
                                        onTap: () => openCategory(category),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _SummaryMiniCard extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;

  const _SummaryMiniCard({
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
        borderRadius: BorderRadius.circular(18),
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
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryListTile extends StatelessWidget {
  final CategoryExpenseModel category;
  final VoidCallback onTap;

  const _CategoryListTile({
    required this.category,
    required this.onTap,
  });

  String formatMoney(double value) {
    return 'Lps ${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorValue);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.92),
        borderRadius: BorderRadius.circular(22),
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  category.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                formatMoney(category.amount),
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.white.withOpacity(0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}