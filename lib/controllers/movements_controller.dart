import 'dart:async';

import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

enum MovementsDateFilter {
  all,
  today,
  week,
  month,
  custom,
}

class MovementsController {
  final TransactionService transactionService = TransactionService();

  List<TransactionModel> allTransactions = [];
  List<TransactionModel> visibleTransactions = [];

  bool isLoading = true;
  String? errorMessage;

  String selectedTypeFilter = 'all';
  MovementsDateFilter selectedDateFilter = MovementsDateFilter.all;
  DateTimeRange? customRange;

  StreamSubscription<List<TransactionModel>>? subscription;

  void initialize(void Function() refreshUi) {
    isLoading = true;
    errorMessage = null;
    refreshUi();

    subscription?.cancel();
    subscription = transactionService.watchTransactions().listen(
      (items) {
        allTransactions = items;
        _applyFilters();
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

  void applyTypeFilter(String filter) {
    selectedTypeFilter = filter;
    _applyFilters();
  }

  void applyDateFilter(MovementsDateFilter filter) {
    selectedDateFilter = filter;
    if (filter != MovementsDateFilter.custom) {
      customRange = null;
    }
    _applyFilters();
  }

  void applyCustomRange(DateTimeRange range) {
    customRange = range;
    selectedDateFilter = MovementsDateFilter.custom;
    _applyFilters();
  }

  void _applyFilters() {
    visibleTransactions = allTransactions.where((item) {
      final matchesType = _matchesType(item);
      final matchesDate = _matchesDate(item.date);
      return matchesType && matchesDate;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  bool _matchesType(TransactionModel item) {
    switch (selectedTypeFilter) {
      case 'income':
        return item.type == 'income';
      case 'expense':
        return item.type == 'expense';
      default:
        return true;
    }
  }

  bool _matchesDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (selectedDateFilter) {
      case MovementsDateFilter.today:
        return normalizedDate == today;

      case MovementsDateFilter.week:
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 7));
        return !normalizedDate.isBefore(weekStart) &&
            normalizedDate.isBefore(weekEnd);

      case MovementsDateFilter.month:
        return normalizedDate.year == today.year &&
            normalizedDate.month == today.month;

      case MovementsDateFilter.custom:
        if (customRange == null) {
          return true;
        }

        final rangeStart = DateTime(
          customRange!.start.year,
          customRange!.start.month,
          customRange!.start.day,
        );

        final rangeEndExclusive = DateTime(
          customRange!.end.year,
          customRange!.end.month,
          customRange!.end.day,
        ).add(const Duration(days: 1));

        return !normalizedDate.isBefore(rangeStart) &&
            normalizedDate.isBefore(rangeEndExclusive);

      case MovementsDateFilter.all:
        return true;
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

  List<TransactionModel> get currentMonthTransactions {
    final now = DateTime.now();

    return allTransactions.where((item) {
      return item.date.year == now.year && item.date.month == now.month;
    }).toList();
  }

  double get projectedMonthIncome {
    final now = DateTime.now();
    final currentMonthItems = currentMonthTransactions
        .where((item) => item.type == 'income')
        .toList();

    final monthIncome = currentMonthItems.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );

    if (monthIncome <= 0) {
      return 0;
    }

    final daysElapsed = now.day.clamp(1, 31);
    final totalDaysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final averagePerDay = monthIncome / daysElapsed;

    return averagePerDay * totalDaysInMonth;
  }

  double get projectedMonthExpenses {
    final now = DateTime.now();
    final currentMonthItems = currentMonthTransactions
        .where((item) => item.type == 'expense')
        .toList();

    final monthExpenses = currentMonthItems.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );

    if (monthExpenses <= 0) {
      return 0;
    }

    final daysElapsed = now.day.clamp(1, 31);
    final totalDaysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final averagePerDay = monthExpenses / daysElapsed;

    return averagePerDay * totalDaysInMonth;
  }

  double get projectedMonthBalance {
    return projectedMonthIncome - projectedMonthExpenses;
  }

  String get activeRangeLabel {
    switch (selectedDateFilter) {
      case MovementsDateFilter.today:
        return 'Hoy';
      case MovementsDateFilter.week:
        return 'Esta semana';
      case MovementsDateFilter.month:
        return 'Este mes';
      case MovementsDateFilter.custom:
        if (customRange == null) {
          return 'Personalizado';
        }

        final start = customRange!.start;
        final end = customRange!.end;
        return '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
      case MovementsDateFilter.all:
        return 'Todo el historial';
    }
  }

  Future<void> deleteMovement(String transactionId) async {
    await transactionService.deleteTransaction(transactionId);
  }

  void dispose() {
    subscription?.cancel();
  }
}