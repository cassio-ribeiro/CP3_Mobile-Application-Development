import 'package:cp3_controle_gastos/models/transaction.dart';

// Regras de negócio do app. Nada aqui conhece a interface (UI):
// a tela só chama estas funções e mostra o resultado.

const double maxAmount = 1000000;

// Valida o texto digitado. Em vez de devolver um valor, avisa o resultado
// por callbacks: onSuccess recebe o valor pronto, onError recebe a mensagem.
void validateAmount(
  String text,
  void Function(double amount) onSuccess,
  void Function(String errorMessage) onError,
) {
  final cleanText = text.trim().replaceAll(',', '.');

  // Early return: cada erro é tratado e a função para ali mesmo
  if (cleanText.isEmpty) {
    onError('Digite um valor antes de clicar em Entrou ou Saiu.');
    return;
  }

  final amount = double.tryParse(cleanText);

  if (amount == null || !amount.isFinite) {
    onError('Valor inválido. Digite apenas números, por exemplo: 10 ou 5,50.');
    return;
  }

  final roundedAmount = double.parse(amount.toStringAsFixed(2));

  if (roundedAmount <= 0) {
    onError('O valor precisa ser maior que zero (mínimo R\$ 0,01).');
    return;
  }

  if (roundedAmount > maxAmount) {
    onError('O valor máximo por transação é ${formatCurrency(maxAmount)}.');
    return;
  }

  onSuccess(roundedAmount);
}

double calculateNewTotal(
  double currentTotal,
  TransactionType type,
  double amount,
) {
  double newTotal = 0;

  if (type == TransactionType.entrou) {
    newTotal = currentTotal + amount;
  } else {
    newTotal = currentTotal - amount;
  }

  return double.parse(newTotal.toStringAsFixed(2));
}

Transaction createTransaction(TransactionType type, double amount) {
  return Transaction(
    id: DateTime.now().microsecondsSinceEpoch.toString(),
    type: type,
    amount: amount,
  );
}

String getTypeLabel(TransactionType type) {
  if (type == TransactionType.entrou) return 'Entrou';
  return 'Saiu';
}

String formatCurrency(double value) {
  final sign = value < 0 ? '- ' : '';
  final absoluteValue = value.abs().toStringAsFixed(2).replaceAll('.', ',');
  return '${sign}R\$ $absoluteValue';
}
