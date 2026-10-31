import 'package:flutter/material.dart';

import 'package:cp3_controle_gastos/models/transaction.dart';
import 'package:cp3_controle_gastos/utils/finance.dart';

// Componente de um item do histórico. É Stateless: não guarda estado,
// só desenha os dados que recebe do pai pelo construtor.
class HistoryItem extends StatelessWidget {
  const HistoryItem({
    super.key,
    required this.transaction,
    required this.onDelete,
  });

  final Transaction transaction;

  // Callback do pai: o filho não remove nada, só avisa que o X foi clicado
  final void Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final isIn = transaction.type == TransactionType.entrou;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isIn ? Icons.arrow_upward : Icons.arrow_downward,
            color: isIn ? Colors.green.shade700 : Colors.red.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${getTypeLabel(transaction.type)}: ${formatCurrency(transaction.amount)}',
              style: TextStyle(
                fontSize: 18,
                color: isIn ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
          ),
          IconButton(
            onPressed: onDelete,
            tooltip: 'Remover do histórico',
            icon: const Icon(Icons.close),
            color: Colors.red.shade700,
          ),
        ],
      ),
    );
  }
}
