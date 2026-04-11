import 'package:flutter/material.dart';

import '../controllers/analytics_controller.dart';
import '../models/card_purchase_model.dart';
import '../models/credit_card_model.dart';
import '../models/transaction_model.dart';
import '../utils/app_colors.dart';

class CategoryExpensesDetailView extends StatefulWidget {
  final String categoryName;
  final AnalyticsController analyticsController;

  const CategoryExpensesDetailView({
    super.key,
    required this.categoryName,
    required this.analyticsController,
  });

  @override
  State<CategoryExpensesDetailView> createState() =>
      _CategoryExpensesDetailViewState();
}

class _CategoryExpensesDetailViewState
    extends State<CategoryExpensesDetailView> {
  bool isLoading = true;
  List<TransactionModel> categoryTransactions = [];
  List<CardPurchaseWithCard> categoryPurchases = [];
  double totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _loadCategoryExpenses();
  }

  Future<void> _loadCategoryExpenses() async {
    setState(() {
      isLoading = true;
    });

    try {
      await widget.analyticsController.loadAnalytics(() {});

      final uid = widget.analyticsController.auth.currentUser?.uid;
      if (uid != null) {
        final transactionsSnapshot = await widget.analyticsController.firestore
            .collection('users')
            .doc(uid)
            .collection('transactions')
            .where('type', isEqualTo: 'expense')
            .where('category', isEqualTo: widget.categoryName)
            .orderBy('date', descending: true)
            .get();

        categoryTransactions = transactionsSnapshot.docs.map((doc) {
          return TransactionModel.fromMap(doc.data(), id: doc.id);
        }).toList();

        final cardsSnapshot = await widget.analyticsController.firestore
            .collection('users')
            .doc(uid)
            .collection('cards')
            .get();

        for (final cardDoc in cardsSnapshot.docs) {
          final card = CreditCardModel.fromMap(cardDoc.data(), id: cardDoc.id);

          final purchasesSnapshot = await cardDoc.reference
              .collection('purchases')
              .orderBy('purchaseDate', descending: true)
              .get();

          for (final purchaseDoc in purchasesSnapshot.docs) {
            final purchase = CardPurchaseModel.fromMap(
              purchaseDoc.data(),
              id: purchaseDoc.id,
            );

            if ((purchase.title.toLowerCase())
                .contains(widget.categoryName.toLowerCase())) {
              categoryPurchases.add(
                CardPurchaseWithCard(
                  purchase: purchase,
                  card: card,
                ),
              );
            }
          }
        }

        totalAmount = categoryTransactions.fold<double>(
              0,
              (sum, transaction) => sum + transaction.amount,
            ) +
            categoryPurchases.fold<double>(
              0,
              (sum, item) => sum + item.purchase.amount,
            );
      }
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

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final totalEntries = categoryTransactions.length + categoryPurchases.length;

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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Detalle de categoría',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.categoryName,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
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
                            'Total gastado',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            formatMoney(totalAmount),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _DetailMiniStat(
                                  title: 'Movimientos',
                                  value: '$totalEntries',
                                  valueColor: AppColors.primarySoft,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _DetailMiniStat(
                                  title: 'Tarjetas',
                                  value: '${categoryPurchases.length}',
                                  valueColor: AppColors.pink,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (categoryTransactions.isNotEmpty) ...[
                              const Text(
                                'Transacciones',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...categoryTransactions.map((transaction) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildTransactionTile(transaction),
                                );
                              }),
                              const SizedBox(height: 18),
                            ],
                            if (categoryPurchases.isNotEmpty) ...[
                              const Text(
                                'Compras con tarjeta',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...categoryPurchases.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildPurchaseTile(item),
                                );
                              }),
                            ],
                            if (categoryTransactions.isEmpty &&
                                categoryPurchases.isEmpty)
                              Container(
                                height: 220,
                                alignment: Alignment.center,
                                child: const Text(
                                  'No hay gastos en esta categoría',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 30),
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

  Widget _buildTransactionTile(TransactionModel transaction) {
    return Container(
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
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.12),
            ),
            child: const Icon(
              Icons.arrow_upward_rounded,
              color: AppColors.primarySoft,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  formatDate(transaction.date),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (transaction.notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    transaction.notes,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.52),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            formatMoney(transaction.amount),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseTile(CardPurchaseWithCard item) {
    final purchase = item.purchase;
    final card = item.card;

    return Container(
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
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.pink.withOpacity(0.12),
            ),
            child: const Icon(
              Icons.credit_card_rounded,
              color: AppColors.pink,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  purchase.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${card.bankName} ****${card.lastFourDigits}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatDate(purchase.purchaseDate),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.52),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            formatMoney(purchase.amount),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailMiniStat extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;

  const _DetailMiniStat({
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

class CardPurchaseWithCard {
  final CardPurchaseModel purchase;
  final CreditCardModel card;

  CardPurchaseWithCard({
    required this.purchase,
    required this.card,
  });
}