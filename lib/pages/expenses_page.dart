import 'package:flutter/material.dart';

import 'package:cp3_controle_gastos/models/transaction.dart';
import 'package:cp3_controle_gastos/utils/finance.dart';
import 'package:cp3_controle_gastos/widgets/balance_card.dart';
import 'package:cp3_controle_gastos/widgets/history_item.dart';

// Classe 1: a estrutura da tela e as propriedades que ela recebe
class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key, required this.title});

  final String title;

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

// Classe 2: guarda o estado e desenha a tela
class _ExpensesPageState extends State<ExpensesPage> {
  // Controla o campo de texto: lê o que foi digitado e permite limpar
  final TextEditingController _amountController = TextEditingController();

  double _total = 0;
  List<Transaction> _history = [];
  String _message = '';
  bool _isError = false;

  @override
  void dispose() {
    // Libera o controller quando a tela sai de uso
    _amountController.dispose();
    super.dispose();
  }

  void _handleTransaction(TransactionType type) {
    validateAmount(
      _amountController.text,
      (amount) {
        setState(() {
          _total = calculateNewTotal(_total, type, amount);
          // Lista nova com spread, em vez de alterar a antiga com .add()
          _history = [createTransaction(type, amount), ..._history];
          _isError = false;
          _message =
              '${getTypeLabel(type)}: ${formatCurrency(amount)} registrado com sucesso!';
        });
        _amountController.clear();
      },
      (errorMessage) {
        setState(() {
          _isError = true;
          _message = errorMessage;
        });
        _showErrorSnackBar(errorMessage);
      },
    );
  }

  void _handleDelete(String idToDelete) {
    setState(() {
      // .where() devolve só os itens com id diferente; .toList() cria a lista nova
      _history = _history.where((item) => item.id != idToDelete).toList();
      _isError = false;
      _message = 'Item removido do histórico. O saldo total não foi alterado.';
    });
  }

  void _showErrorSnackBar(String errorMessage) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BalanceCard(total: _total),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Valor (R\$)',
                hintText: 'Ex.: 10 ou 5,50',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    // Arrow function: onPressed não entrega o tipo,
                    // então "envelopamos" a chamada passando o valor certo
                    onPressed: () => _handleTransaction(TransactionType.entrou),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Entrou'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleTransaction(TransactionType.saiu),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Saiu'),
                  ),
                ),
              ],
            ),
            // Renderização condicional: a mensagem só aparece se existir
            if (_message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isError ? Colors.red.shade700 : Colors.green.shade700,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'Histórico',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: _history.isEmpty
                  ? const Center(child: Text('Nenhuma transação registrada.'))
                  // ListView.builder: equivalente à FlatList, só monta
                  // os itens que aparecem na tela
                  : ListView.builder(
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final item = _history[index];
                        return HistoryItem(
                          key: ValueKey(item.id),
                          transaction: item,
                          onDelete: () => _handleDelete(item.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
