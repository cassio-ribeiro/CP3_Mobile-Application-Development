import 'package:flutter/material.dart';

import 'package:cp3_controle_gastos/utils/finance.dart';

// Mostra o saldo total. Também é Stateless: quando o saldo muda,
// quem reconstrói é o pai (a tela), passando o novo total.
class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key, required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Saldo total', style: TextStyle(fontSize: 16)),
            Text(
              formatCurrency(total),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: total < 0 ? Colors.red.shade700 : Colors.green.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
