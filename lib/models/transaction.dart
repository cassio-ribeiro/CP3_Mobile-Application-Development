// Enum: "trava" os tipos aceitos. Uma transação só pode ser Entrou ou Saiu.
enum TransactionType { entrou, saiu }

// Modelo de dados de uma movimentação do histórico.
// Os campos são final: depois de criada, a transação não muda.
class Transaction {
  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
  });

  final String id;
  final TransactionType type;
  final double amount;
}
