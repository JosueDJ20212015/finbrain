import 'dart:async';

import '../models/card_purchase_model.dart';
import '../models/credit_card_model.dart';
import '../services/credit_card_service.dart';

class CardsController {
  final CreditCardService creditCardService = CreditCardService();

  List<CreditCardModel> cards = [];
  List<CardPurchaseModel> purchases = [];

  CreditCardModel? selectedCard;

  bool isLoadingCards = true;
  bool isLoadingPurchases = false;
  String? errorMessage;

  StreamSubscription<List<CreditCardModel>>? _cardsSubscription;
  StreamSubscription<List<CardPurchaseModel>>? _purchasesSubscription;

  void initialize(void Function() refreshUi) {
    _listenCards(refreshUi);
  }

  void _listenCards(void Function() refreshUi) {
    isLoadingCards = true;
    errorMessage = null;
    refreshUi();

    _cardsSubscription?.cancel();

    _cardsSubscription = creditCardService.watchCards().listen(
      (items) {
        cards = items;
        isLoadingCards = false;

        if (cards.isEmpty) {
          selectedCard = null;
          purchases = [];
          isLoadingPurchases = false;
          refreshUi();
          return;
        }

        final selectedStillExists = selectedCard != null &&
            cards.any((item) => item.id == selectedCard!.id);

        if (!selectedStillExists) {
          selectedCard = cards.first;
          _listenPurchases(selectedCard!.id, refreshUi);
        } else {
          selectedCard = cards.firstWhere((item) => item.id == selectedCard!.id);
        }

        refreshUi();
      },
      onError: (_) {
        isLoadingCards = false;
        errorMessage = 'No se pudieron cargar las tarjetas';
        refreshUi();
      },
    );
  }

  void selectCard(CreditCardModel card, void Function() refreshUi) {
    if (selectedCard?.id == card.id) {
      return;
    }

    selectedCard = card;
    _listenPurchases(card.id, refreshUi);
    refreshUi();
  }

  void _listenPurchases(String cardId, void Function() refreshUi) {
    isLoadingPurchases = true;
    refreshUi();

    _purchasesSubscription?.cancel();

    _purchasesSubscription = creditCardService.watchPurchases(cardId).listen(
      (items) {
        purchases = items;
        isLoadingPurchases = false;
        refreshUi();
      },
      onError: (_) {
        purchases = [];
        isLoadingPurchases = false;
        errorMessage = 'No se pudieron cargar las compras';
        refreshUi();
      },
    );
  }

  double get currentCardBalance {
    return purchases.fold<double>(0, (sum, item) => sum + item.amount);
  }

  double get availableCredit {
    final limit = selectedCard?.creditLimit ?? 0;
    final available = limit - currentCardBalance;
    return available < 0 ? 0 : available;
  }

  Future<void> createCard({
    required String bankName,
    required String cardName,
    required String holderName,
    required String brand,
    required String lastFourDigits,
    required double creditLimit,
    required int statementDay,
    required int dueDay,
  }) async {
    await creditCardService.createCard(
      bankName: bankName,
      cardName: cardName,
      holderName: holderName,
      brand: brand,
      lastFourDigits: lastFourDigits,
      creditLimit: creditLimit,
      statementDay: statementDay,
      dueDay: dueDay,
    );
  }

  Future<void> createPurchase({
    required String title,
    required double amount,
    required DateTime purchaseDate,
    required int installments,
    required String notes,
  }) async {
    final card = selectedCard;
    if (card == null) {
      throw Exception('Selecciona una tarjeta');
    }

    await creditCardService.createPurchase(
      cardId: card.id,
      title: title,
      amount: amount,
      purchaseDate: purchaseDate,
      installments: installments,
      notes: notes,
    );
  }

  Future<void> deletePurchase(String purchaseId) async {
    final card = selectedCard;
    if (card == null) {
      throw Exception('Selecciona una tarjera');
    }

    await creditCardService.deletePurchase(
      cardId: card.id,
      purchaseId: purchaseId,
    );
  }

  Future<void> deleteSelectedCard() async {
    final card = selectedCard;
    if (card == null) {
      throw Exception('Selecciona una tarjeta');
    }

    await creditCardService.deleteCard(card.id);
  }

  void dispose() {
    _cardsSubscription?.cancel();
    _purchasesSubscription?.cancel();
  }
}