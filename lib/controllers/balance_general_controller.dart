import '../models/balance_general_summary_model.dart';
import '../services/balance_general_service.dart';

class BalanceGeneralController {
  final BalanceGeneralService balanceGeneralService = BalanceGeneralService();

  bool isLoading = true;
  String? errorMessage;
  BalanceGeneralSummaryModel? summary;

  Future<void> loadSummary(void Function() refreshUi) async {
    isLoading = true;
    errorMessage = null;
    refreshUi();

    try {
      summary = await balanceGeneralService.getSummary();
      isLoading = false;
      errorMessage = null;
      refreshUi();
    } catch (_) {
      isLoading = false;
      errorMessage = 'No se pudo cargar el balance general.';
      refreshUi();
    }
  }
}