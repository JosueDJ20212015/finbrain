import 'dart:async';

import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class MovementsController {
  final TransactionService transactionService = TransactionService();

  List<TransactionModel> allTransactions = [];
  List<TransactionModel> visibleTransactions = [];

  bool isLoading = true;
  String? errorMessage;
  String selectedFilter = 'all';

  StreamSubscription<List<TransactionModel>>? subscription;

  void initialize(void Function() refreshUi) {
    isLoading = true;
    errorMessage = null;
    refreshUi();

    subscription?.cancel();
    subscription = transactionService.watchTransactions().listen(
      (items) {
        allTransactions = items;
        applyFilter(selectedFilter);
        isLoading = false;
        errorMessage = null;
        refreshUi();
      },
      onError: (_) {
        isLoading = false;
        errorMessage = 'No se pudieron cargar los movimientos.';
        refreshUi();
      },
    );
  }

  void applyFilter(String filter) {
    selectedFilter = filter;

    switch (filter) {
      case 'income':
        visibleTransactions =
            allTransactions.where((item) => item.type == 'income').toList();
        break;
      case 'expense':
        visibleTransactions =
            allTransactions.where((item) => item.type == 'expense').toList();
        break;
      default:
        visibleTransactions = [...allTransactions];
    }
  }

  double get totalIncome {
    return visibleTransactions
        .where((item) => item.type == 'income')
        .fold<double>(0, (sum, item) => sum + item.amount);
  }

  double get totalExpenses {
    return visibleTransactions
        .where((item) => item.type == 'expense')
        .fold<double>(0, (sum, item) => sum + item.amount);
  }

  double get balance {
    return totalIncome - totalExpenses;
  }

  Future<void> deleteMovement(String transactionId) async {
    await transactionService.deleteTransaction(transactionId);
  }

  void dispose() {
    subscription?.cancel();
  }
}