import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cp3_controle_gastos/main.dart';
import 'package:cp3_controle_gastos/models/transaction.dart';
import 'package:cp3_controle_gastos/utils/finance.dart';

void main() {
  group('validateAmount', () {
    String? error;
    double? value;

    void run(String text) {
      error = null;
      value = null;
      validateAmount(text, (amount) => value = amount, (msg) => error = msg);
    }

    test('aceita vírgula e ponto', () {
      run('5,50');
      expect(value, 5.5);
      run(' 10.25 ');
      expect(value, 10.25);
    });

    test('rejeita vazio, letras, zero, negativo e acima do máximo', () {
      for (final text in ['', '   ', 'abc', '1,2,3', 'NaN', 'Infinity', '0', '0,001', '-5', '2000000']) {
        run(text);
        expect(value, isNull, reason: text);
        expect(error, isNotNull, reason: text);
      }
    });
  });

  test('calculateNewTotal soma e subtrai com 2 casas', () {
    expect(calculateNewTotal(0.1, TransactionType.entrou, 0.2), 0.3);
    expect(calculateNewTotal(5, TransactionType.saiu, 12), -7);
  });

  test('formatCurrency', () {
    expect(formatCurrency(0), 'R\$ 0,00');
    expect(formatCurrency(5.5), 'R\$ 5,50');
    expect(formatCurrency(-7), '- R\$ 7,00');
  });

  testWidgets('fluxo completo: erro, entrada, saída e exclusão', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('R\$ 0,00'), findsOneWidget);
    expect(find.text('Nenhuma transação registrada.'), findsOneWidget);

    // Erro: campo vazio
    await tester.tap(find.text('Entrou'));
    await tester.pump();
    expect(find.text('Digite um valor antes de clicar em Entrou ou Saiu.'), findsWidgets);

    // Sucesso: entrada
    await tester.enterText(find.byType(TextField), '20');
    await tester.tap(find.text('Entrou'));
    await tester.pump();
    expect(find.text('R\$ 20,00'), findsOneWidget);
    expect(find.text('Entrou: R\$ 20,00'), findsOneWidget);

    // Sucesso: saída deixa o saldo negativo
    await tester.enterText(find.byType(TextField), '25,5');
    await tester.tap(find.text('Saiu'));
    await tester.pump();
    expect(find.text('- R\$ 5,50'), findsOneWidget);
    expect(find.text('Saiu: R\$ 25,50'), findsOneWidget);

    // Exclusão remove só do histórico
    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pump();
    expect(find.text('Saiu: R\$ 25,50'), findsNothing);
    expect(find.text('Entrou: R\$ 20,00'), findsOneWidget);
    expect(find.text('- R\$ 5,50'), findsOneWidget);
  });
}
