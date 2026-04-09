import 'package:flutter/material.dart';
import 'package:myapp/widgets/credit_card_glass_widget.dart';

import '../controllers/cards_controller.dart';
import '../models/card_purchase_model.dart';
import '../models/credit_card_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_snackbar.dart';

class CardsView extends StatefulWidget {
  const CardsView({super.key});

  @override
  State<CardsView> createState() => _CardsViewState();
}

class _CardsViewState extends State<CardsView> {
  final cardsController = CardsController();
  final pageController = PageController(viewportFraction: 0.90);

  @override
  void initState() {
    super.initState();
    cardsController.initialize(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    cardsController.dispose();
    super.dispose();
  }

  String _formatMoney(double value) {
    return 'Lps ${value.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  Future<void> _showAddCardBottomSheet() async {
    final bankNameController = TextEditingController();
    final cardNameController = TextEditingController();
    final holderNameController = TextEditingController();
    final lastFourDigitsController = TextEditingController();
    final creditLimitController = TextEditingController();
    final statementDayController = TextEditingController();
    final dueDayController = TextEditingController();

    String selectedBrand = 'Visa';

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
                      'Agregar tarjeta',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _AppField(
                      controller: bankNameController,
                      label: 'Banco',
                      hintText: 'BAC, Ficohsa, Atlantida...',
                    ),
                    const SizedBox(height: 14),
                    _AppField(
                      controller: cardNameController,
                      label: 'Nombre de la tarjeta',
                      hintText: 'Platinum',
                    ),
                    const SizedBox(height: 14),
                    _AppField(
                      controller: holderNameController,
                      label: 'Titular',
                      hintText: 'Elmer R',
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: selectedBrand,
                      dropdownColor: AppColors.card,
                      decoration: _inputDecoration(
                        label: 'Marca',
                        hintText: 'Selecciona una marca',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Visa', child: Text('Visa')),
                        DropdownMenuItem(
                          value: 'Mastercard',
                          child: Text('Mastercard'),
                        ),
                        DropdownMenuItem(value: 'Amex', child: Text('Amex')),
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          selectedBrand = value ?? 'Visa';
                        });
                      },
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _AppField(
                            controller: lastFourDigitsController,
                            label: 'Ultimos 4 digitos',
                            hintText: '1234',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _AppField(
                            controller: creditLimitController,
                            label: 'Limite',
                            hintText: '50000',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _AppField(
                            controller: statementDayController,
                            label: 'Dia de corte',
                            hintText: '15',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _AppField(
                            controller: dueDayController,
                            label: 'Dia de pago',
                            hintText: '28',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          final bankName = bankNameController.text.trim();
                          final cardName = cardNameController.text.trim();
                          final holderName = holderNameController.text.trim();
                          final lastFourDigits =
                              lastFourDigitsController.text.trim();
                          final creditLimit = double.tryParse(
                            creditLimitController.text.trim(),
                          );
                          final statementDay = int.tryParse(
                            statementDayController.text.trim(),
                          );
                          final dueDay = int.tryParse(
                            dueDayController.text.trim(),
                          );

                          if (bankName.isEmpty ||
                              cardName.isEmpty ||
                              holderName.isEmpty ||
                              lastFourDigits.length != 4 ||
                              creditLimit == null ||
                              statementDay == null ||
                              dueDay == null ||
                              statementDay < 1 ||
                              statementDay > 31 ||
                              dueDay < 1 ||
                              dueDay > 31) {
                            AppSnackbar.error(
                              context,
                              'Completa todos los campos.',
                            );
                            return;
                          }

                          try {
                            await cardsController.createCard(
                              bankName: bankName,
                              cardName: cardName,
                              holderName: holderName,
                              brand: selectedBrand,
                              lastFourDigits: lastFourDigits,
                              creditLimit: creditLimit,
                              statementDay: statementDay,
                              dueDay: dueDay,
                            );

                            if (!mounted) {
                              return;
                            }

                            Navigator.pop(context);
                            AppSnackbar.success(
                              context,
                              'Tarjeta registrada',
                            );
                          } catch (_) {
                            AppSnackbar.error(
                              context,
                              'No se pudo guardar la tarjeta.',
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
                          'Guardar tarjeta',
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

  Future<void> _showAddPurchaseBottomSheet() async {
    if (cardsController.selectedCard == null) {
      AppSnackbar.info(
        context,
        'Primero debes registrar una tarjeta',
      );
      return;
    }

    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final installmentsController = TextEditingController(text: '1');
    final notesController = TextEditingController();

    DateTime selectedDate = DateTime.now();

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
                      'Registrar compra',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _AppField(
                      controller: titleController,
                      label: 'Descripcion',
                      hintText: 'Supermercado, gasolina, Amazon...',
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _AppField(
                            controller: amountController,
                            label: 'Monto',
                            hintText: '1250.50',
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _AppField(
                            controller: installmentsController,
                            label: 'Cuotas',
                            hintText: '1',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
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
                              'Fecha de compra',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatDate(selectedDate),
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
                    _AppField(
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
                          final installments = int.tryParse(
                            installmentsController.text.trim(),
                          );
                          final notes = notesController.text.trim();

                          if (title.isEmpty ||
                              amount == null ||
                              amount <= 0 ||
                              installments == null ||
                              installments <= 0) {
                            AppSnackbar.error(
                              context,
                              'Completa los datos de la compra',
                            );
                            return;
                          }

                          try {
                            await cardsController.createPurchase(
                              title: title,
                              amount: amount,
                              purchaseDate: selectedDate,
                              installments: installments,
                              notes: notes,
                            );

                            if (!mounted) {
                              return;
                            }

                            Navigator.pop(context);
                            AppSnackbar.success(
                              context,
                              'Compra registrada',
                            );
                          } catch (_) {
                            AppSnackbar.error(
                              context,
                              'No se pudo guardar la compra.',
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
                          'Guardar compra',
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

  Future<void> _confirmDeletePurchase(CardPurchaseModel purchase) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text(
            'Eliminar compra',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            '¿Deseas eliminar "${purchase.title}"?',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (result != true) {
      return;
    }

    try {
      await cardsController.deletePurchase(purchase.id);

      if (!mounted) {
        return;
      }

      AppSnackbar.success(context, 'Compra eliminada');
    } catch (_) {
      AppSnackbar.error(context, 'No se pudo eliminar');
    }
  }

  Widget _buildAlertStrip(CreditCardModel card) {
    final nextCutDate = card.nextStatementDate();
    final nextDueDate = card.nextDueDate();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _InfoPill(
                  icon: Icons.calendar_month_rounded,
                  title: 'Proximo corte',
                  value:
                      '${_formatDate(nextCutDate)} · faltan ${card.daysUntilStatement()} dias',
                  highlight: card.shouldWarnStatementSoon,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoPill(
                  icon: Icons.notifications_active_outlined,
                  title: 'Proximo pago',
                  value:
                      '${_formatDate(nextDueDate)} · faltan ${card.daysUntilDue()} días',
                  highlight: card.shouldWarnDueSoon,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          /*Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Base lista para alertar',
              style: TextStyle(
                color: Colors.white.withOpacity(0.66),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),*/
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 94,
                height: 94,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.14),
                      blurRadius: 22,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.credit_card_off_rounded,
                  size: 42,
                  color: AppColors.primarySoft,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'No hay tarjetas',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Agrega tu primera tarjeta de credito',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.68),
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: 210,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _showAddCardBottomSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: const Color(0xFF0B1418),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(
                    'Agregar tarjeta',
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
      ),
    );
  }

  Widget _buildPurchasesSection() {
    if (cardsController.selectedCard == null) {
      return const SizedBox.shrink();
    }

    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(top: 18),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(0.88),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.07),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Compras registradas',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _showAddPurchaseBottomSheet,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: const Text('Agregar'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primarySoft,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (cardsController.isLoadingPurchases)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              )
            else if (cardsController.purchases.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'No hay compras registradas en esta tarjeta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.66),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: cardsController.purchases.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final purchase = cardsController.purchases[index];

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withOpacity(0.14),
                            ),
                            child: const Icon(
                              Icons.shopping_bag_outlined,
                              color: AppColors.primarySoft,
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
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_formatDate(purchase.purchaseDate)} · ${purchase.installments} cuota(s)',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (purchase.notes.trim().isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    purchase.notes,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.58),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatMoney(purchase.amount),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  _confirmDeletePurchase(purchase);
                                },
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: AppColors.pink,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCard = cardsController.selectedCard;

    return Scaffold(
      backgroundColor: AppColors.background,
      /*floatingActionButton: selectedCard == null
          ? FloatingActionButton.extended(
              onPressed: _showAddCardBottomSheet,
              backgroundColor: AppColors.primary,
              foregroundColor: const Color(0xFF0B1418),
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Agregar tarjeta',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            )
          : FloatingActionButton.extended(
              onPressed: _showAddPurchaseBottomSheet,
              backgroundColor: AppColors.primary,
              foregroundColor: const Color(0xFF0B1418),
              icon: const Icon(Icons.add_shopping_cart_rounded),
              label: const Text(
                'Add Compra',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),*/
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.pageGradient,
        ),
        child: SafeArea(
          child: cardsController.isLoadingCards
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    children: [
                      Row(
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
                              'Mis tarjetas',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (selectedCard != null)
                            IconButton(
                              onPressed: () async {
                                try {
                                  await cardsController.deleteSelectedCard();

                                  if (!mounted) {
                                    return;
                                  }

                                  AppSnackbar.success(
                                    context,
                                    'Tarjeta eliminada',
                                  );
                                } catch (_) {
                                  AppSnackbar.error(
                                    context,
                                    'No se pudo eliminar',
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.pink,
                              ),
                            ),
                          IconButton(
                            onPressed: _showAddCardBottomSheet,
                            icon: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.42),
                                ),
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: AppColors.primarySoft,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (cardsController.cards.isEmpty)
                        _buildEmptyState()
                      else ...[
                        SizedBox(
                          height: 245,
                          child: PageView.builder(
                            controller: pageController,
                            itemCount: cardsController.cards.length,
                            onPageChanged: (index) {
                              cardsController.selectCard(
                                cardsController.cards[index],
                                () {
                                  if (mounted) {
                                    setState(() {});
                                  }
                                },
                              );
                            },
                            itemBuilder: (context, index) {
                              final card = cardsController.cards[index];
                              final isSelected =
                                  card.id == cardsController.selectedCard?.id;

                              return AnimatedPadding(
                                duration: const Duration(milliseconds: 220),
                                padding: EdgeInsets.only(
                                  right: 10,
                                  top: isSelected ? 0 : 10,
                                  bottom: isSelected ? 0 : 10,
                                ),
                                child: CreditCardGlassWidget(
                                  card: card,
                                  currentBalance: isSelected
                                      ? cardsController.currentCardBalance
                                      : 0,
                                  availableCredit: isSelected
                                      ? cardsController.availableCredit
                                      : card.creditLimit,
                                  rotationY: isSelected ? 0 : -0.08,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildAlertStrip(selectedCard!),
                        _buildPurchasesSection(),
                      ],
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool highlight;

  const _InfoPill({
    required this.icon,
    required this.title,
    required this.value,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.primary.withOpacity(0.10)
            : Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight
              ? AppColors.primary.withOpacity(0.26)
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: highlight ? AppColors.primarySoft : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
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
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
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

class _AppField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final TextInputType keyboardType;
  final int maxLines;

  const _AppField({
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
      decoration: _inputDecoration(
        label: label,
        hintText: hintText,
      ),
    );
  }
}

InputDecoration _inputDecoration({
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