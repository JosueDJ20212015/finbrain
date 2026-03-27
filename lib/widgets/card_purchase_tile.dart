import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/card_purchase_model.dart';

class CardPurchaseTile extends StatelessWidget {
  final CardPurchaseModel purchase;

  const CardPurchaseTile({
    super.key,
    required this.purchase,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'es',
      symbol: 'Lps ',
      decimalDigits: 2,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF131C27).withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFF35D6C8).withOpacity(0.12),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Color(0xFF8FE9DD),
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
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  DateFormat('dd/MM/yyyy').format(purchase.purchaseDate),
                  style: const TextStyle(
                    color: Color(0xFFA8B4C4),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (purchase.notes != null && purchase.notes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    purchase.notes!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF7E8A9A),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            currency.format(purchase.amount),
            style: const TextStyle(
              color: Color(0xFF8FE9DD),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}