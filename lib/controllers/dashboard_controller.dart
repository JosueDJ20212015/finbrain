import 'dart:async';

import 'package:flutter/material.dart';

import '../models/dashboard_summary_model.dart';
import '../models/quick_action_model.dart';
import '../services/auth_service.dart';
import '../services/dashboard_service.dart';

class DashboardController {
  final DashboardService dashboardService = DashboardService();
  final AuthService authService = AuthService();

  DashboardSummaryModel? summary;
  bool isLoading = true;
  String? errorMessage;

  StreamSubscription<DashboardSummaryModel>? _subscription;

  final List<QuickActionModel> quickActions = const [
    QuickActionModel(
      id: 'expense',
      title: '+ Gasto',
      icon: Icons.remove_circle_outline_rounded,
    ),
    QuickActionModel(
      id: 'income',
      title: '+ Ingreso',
      icon: Icons.add_circle_outline_rounded,
    ),
    QuickActionModel(
      id: 'budget',
      title: '+ Presupuesto',
      icon: Icons.account_balance_wallet_outlined,
    ),
  ];

  void listenDashboard(VoidCallback refreshUi) {
    isLoading = true;
    errorMessage = null;
    refreshUi();

    dashboardService.syncDashboardSummary();

    _subscription?.cancel();
    _subscription = dashboardService.watchDashboard().listen(
      (dashboard) {
        summary = dashboard;
        isLoading = false;
        errorMessage = null;
        refreshUi();
      },
      onError: (_) {
        isLoading = false;
        errorMessage = 'No se pudo cargar el dashboard.';
        refreshUi();
      },
    );
  }

  String get displayName {
    final dashboardName = summary?.userName.trim();
    if (dashboardName != null && dashboardName.isNotEmpty) {
      return dashboardName.split(' ').first;
    }

    final authName = authService.currentUser?.displayName?.trim();
    if (authName != null && authName.isNotEmpty) {
      return authName.split(' ').first;
    }

    final email = authService.currentUser?.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'Usuario';
  }

  Future<void> signOut() async {
    await authService.signOut();
  }

  void dispose() {
    _subscription?.cancel();
  }
}