import 'package:flutter/material.dart';

import '../models/alert_item_model.dart';
import '../utils/app_colors.dart';

enum AlertDateFilter { today, week, month, all }

class AlertsDialog extends StatefulWidget {
  final List<AlertItemModel> alerts;

  const AlertsDialog({super.key, required this.alerts});

  static Future<void> show(
    BuildContext context, {
    required List<AlertItemModel> alerts,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AlertsDialog(alerts: alerts),
    );
  }

  @override
  State<AlertsDialog> createState() => _AlertsDialogState();
}

class _AlertsDialogState extends State<AlertsDialog> {
  AlertDateFilter _filter = AlertDateFilter.all;

  List<AlertItemModel> get _filtered {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return widget.alerts.where((alert) {
      final alertDay = DateTime(alert.date.year, alert.date.month, alert.date.day);

      return switch (_filter) {
        AlertDateFilter.today => alertDay == today,
        AlertDateFilter.week =>
          !alertDay.isBefore(today.subtract(const Duration(days: 6))),
        AlertDateFilter.month =>
          alert.date.year == now.year && alert.date.month == now.month,
        AlertDateFilter.all => true,
      };
    }).toList();
  }

  Color _levelColor(String level) => switch (level) {
        'danger' => const Color(0xFFFF5C7A),
        'warning' => AppColors.yellow,
        _ => AppColors.primary,
      };

  IconData _levelIcon(String level) => switch (level) {
        'danger' => Icons.error_rounded,
        'warning' => Icons.warning_amber_rounded,
        _ => Icons.info_outline_rounded,
      };

  Color _levelBg(String level) => switch (level) {
        'danger' => const Color(0xFFFF5C7A).withOpacity(0.12),
        'warning' => AppColors.yellow.withOpacity(0.10),
        _ => AppColors.primary.withOpacity(0.10),
      };

  String _typeLabel(String type) => switch (type) {
        'budget' => 'Presupuesto',
        'card_statement' => 'Corte de tarjeta',
        'card_due' => 'Pago de tarjeta',
        _ => 'General',
      };

  String _formatDate(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}  $hour:$minute';
  }

  Widget _buildFilterChip({
    required AlertDateFilter value,
    required String label,
  }) {
    final isSelected = _filter == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _filter = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.14)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
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

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Alertas',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (widget.alerts.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5C7A).withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.alerts.length}',
                          style: const TextStyle(
                            color: Color(0xFFFF5C7A),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.cardSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        value: AlertDateFilter.today,
                        label: 'Hoy',
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        value: AlertDateFilter.week,
                        label: 'Semana',
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        value: AlertDateFilter.month,
                        label: 'Mes',
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        value: AlertDateFilter.all,
                        label: 'Todas',
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? _EmptyState(filter: _filter)
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final alert = filtered[index];
                          return _AlertTile(
                            alert: alert,
                            levelColor: _levelColor(alert.level),
                            levelBg: _levelBg(alert.level),
                            levelIcon: _levelIcon(alert.level),
                            typeLabel: _typeLabel(alert.type),
                            formattedDate: _formatDate(alert.date),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AlertTile extends StatelessWidget {
  final AlertItemModel alert;
  final Color levelColor;
  final Color levelBg;
  final IconData levelIcon;
  final String typeLabel;
  final String formattedDate;

  const _AlertTile({
    required this.alert,
    required this.levelColor,
    required this.levelBg,
    required this.levelIcon,
    required this.typeLabel,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: levelBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: levelColor.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: levelColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(levelIcon, color: levelColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        alert.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardSoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        typeLabel,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  alert.message,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: AppColors.textMuted.withOpacity(0.75),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AlertDateFilter filter;

  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final label = switch (filter) {
      AlertDateFilter.today => 'hoy',
      AlertDateFilter.week => 'esta semana',
      AlertDateFilter.month => 'este mes',
      AlertDateFilter.all => '',
    };

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.primary,
            size: 52,
          ),
          const SizedBox(height: 14),
          const Text(
            'Sin alertas',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label.isEmpty
                ? 'No tienes alertas pendientes.'
                : 'No hay alertas para $label.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}