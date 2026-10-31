import 'package:flutter/material.dart';

import 'package:cp3_controle_gastos/pages/expenses_page.dart';

void main() {
  runApp(const MyApp()); // Ponto de entrada
}

// Widget raiz: não tem estado próprio, só configura o app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Gastos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const ExpensesPage(title: 'Controle de Gastos'),
    );
  }
}
