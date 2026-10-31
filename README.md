# CP3 — Controle de Gastos (Flutter)

Projeto do CheckPoint 3 de Mobile Application Development.

## 1. Como é o app

O **Controle de Gastos** é um app de uma tela que ajuda o usuário a acompanhar quanto dinheiro entrou e saiu.

### O que o usuário pode fazer

1. Ver o **saldo total** no topo da tela. Ele começa em `R$ 0,00`, fica verde quando é positivo e vermelho quando é negativo.
2. Digitar um valor no campo **Valor (R$)**. Aceita vírgula ou ponto (ex.: `10`, `5,50`, `5.50`).
3. Tocar em **Entrou** para somar o valor ao saldo, ou em **Saiu** para subtrair.
4. Ver o **histórico** das movimentações, com a mais recente no topo (ex.: "Entrou: R$ 50,00", "Saiu: R$ 12,00").
5. Tocar no **X** ao lado de um item para removê-lo do histórico. A remoção **não altera o saldo total**: ela só limpa a lista.

### Cenários de sucesso

| Ação | Resultado |
| --- | --- |
| Valor válido + Entrou | Saldo aumenta, item verde no histórico, campo limpo, mensagem verde "Entrou: R$ X registrado com sucesso!" |
| Valor válido + Saiu | Saldo diminui (pode ficar negativo), item vermelho no histórico, campo limpo, mensagem verde de sucesso |
| X em um item | Item sai da lista, saldo continua igual, mensagem "Item removido do histórico. O saldo total não foi alterado." |
| Histórico vazio | Aparece "Nenhuma transação registrada." |

### Cenários de erro

Em todo erro aparecem um aviso vermelho embaixo da tela (SnackBar) e a mensagem em vermelho embaixo dos botões. O saldo e o histórico não mudam.

| Entrada | Mensagem |
| --- | --- |
| Campo vazio ou só com espaços | Digite um valor antes de clicar em Entrou ou Saiu. |
| Letras ou texto que não é número (`abc`, `1,2,3`) | Valor inválido. Digite apenas números, por exemplo: 10 ou 5,50. |
| Zero, negativo ou menor que 1 centavo (`0`, `-5`, `0,001`) | O valor precisa ser maior que zero (mínimo R$ 0,01). |
| Acima de R$ 1.000.000,00 | O valor máximo por transação é R$ 1000000,00. |

### Estrutura de pastas

```
lib/
├── main.dart                  # Ponto de entrada e widget raiz (MyApp)
├── models/
│   └── transaction.dart       # Enum TransactionType e classe Transaction
├── utils/
│   └── finance.dart           # Regras de negócio: validar, calcular, formatar
├── pages/
│   └── expenses_page.dart     # A tela (StatefulWidget) com o estado do app
└── widgets/
    ├── balance_card.dart      # Card do saldo (StatelessWidget)
    └── history_item.dart      # Linha do histórico com o botão X (StatelessWidget)
test/
└── widget_test.dart           # Testes da lógica e do fluxo da tela
```

### Como rodar

```bash
flutter pub get
flutter run
```

Para rodar os testes:

```bash
flutter test
```

## 3. Conceitos utilizados

### StatelessWidget x StatefulWidget

- **`MyApp`**, **`BalanceCard`** e **`HistoryItem`** são `StatelessWidget`: não têm estado próprio, só desenham o que recebem. Quando o saldo muda, quem reconstrói o `BalanceCard` é o pai, passando o novo `total`.
- **`ExpensesPage`** é um `StatefulWidget`, porque o saldo, o histórico e a mensagem mudam conforme o usuário usa o app.

### As duas classes do StatefulWidget

Em `expenses_page.dart`:

1. **`ExpensesPage`** (Classe 1) define as propriedades da tela (`title`) e cria o estado em `createState()`.
2. **`_ExpensesPageState`** (Classe 2) guarda o estado (`_total`, `_history`, `_message`, `_isError`) e desenha a tela no `build`. Dentro dela, `widget.title` acessa a propriedade da Classe 1.

### setState

Toda mudança de estado acontece dentro de `setState(() { ... })`. É ele que avisa o Flutter que algo mudou e que o `build` precisa rodar de novo. Sem o `setState`, a variável mudaria, mas a tela continuaria igual. É o mesmo papel do setter do `useState` no React Native.

### Imutabilidade da lista (spread e filtro)

O histórico nunca é alterado "por dentro" com `.add()` ou `.remove()`. Sempre é criada uma lista nova:

- Para adicionar, usamos o **spread** (`...`): `_history = [createTransaction(type, amount), ..._history];`
- Para remover, usamos a HOF **`.where()`** (equivalente ao `.filter()` do JavaScript) e depois `.toList()`: `_history = _history.where((item) => item.id != idToDelete).toList();`

Cada item tem um `id` único, então a exclusão remove o item certo mesmo depois de outros itens saírem da lista.

### Callbacks

- **Validação com onSuccess / onError**: `validateAmount` (em `finance.dart`) recebe o texto e duas funções. Se o valor for válido, chama `onSuccess(valor)`; se não, chama `onError(mensagem)`. A tela decide o que fazer em cada caso. É o mesmo padrão da calculadora de IMC (versão 2) vista em aula.
- **Filho → pai**: o `HistoryItem` recebe `onDelete` pelo construtor. Ao tocar no X, o filho só chama `onDelete`; quem remove o item do estado é a tela (o pai). Os dados descem pelo construtor, e os eventos sobem pelos callbacks.
- **Referência x arrow function**: no `IconButton` do `HistoryItem`, `onPressed: onDelete` passa só a referência, porque não há nenhum valor extra a enviar. Nos botões Entrou/Saiu usamos `onPressed: () => _handleTransaction(TransactionType.entrou)`, porque precisamos "envelopar" a chamada para passar o tipo certo.

### Function signatures tipadas

Os callbacks têm a assinatura declarada: `void Function(double amount) onSuccess`, `void Function(String errorMessage) onError` e `void Function() onDelete`. Assim o Dart não deixa passar uma função com parâmetros errados.

### Early return

Em `validateAmount`, cada erro é testado no começo da função e termina com `return`. O caminho de sucesso (`onSuccess(roundedAmount)`) fica no fim, sem `if/else` aninhados.

### Enum

`TransactionType` só aceita `entrou` ou `saiu`. Não existe como passar uma string qualquer como tipo de transação.

### Classes, construtores e `required`

- `Transaction` é uma classe com campos `final` (não mudam depois de criados) e construtor com parâmetros nomeados `required`.
- Os widgets usam `required` nas propriedades obrigatórias (`required this.total`, `required this.onDelete`). Se alguém criar o widget sem passar o dado, o código não compila.
- `super.key` repassa a `key` opcional para a classe pai.

### Membros privados (`_`)

`_ExpensesPageState`, `_amountController`, `_total`, `_history`, `_handleTransaction`, `_handleDelete` e `_showErrorSnackBar` começam com `_`, então só podem ser usados dentro do próprio arquivo.

### `const`

Widgets com valores fixos (`const Text('Histórico')`, `const SizedBox(height: 16)`, `const Icon(Icons.close)`) usam `const`. Widgets com valores dinâmicos, como `Text(widget.title)` ou `Text(_message)`, não podem ser `const`, porque o valor só é conhecido em tempo de execução.

### Separação entre lógica e interface

- `models/` guarda o formato dos dados.
- `utils/finance.dart` tem só regras de negócio (validar, calcular o saldo, criar transação, formatar moeda) e não importa nada do Flutter.
- `pages/` e `widgets/` cuidam só da interface.

Isso deixa cada arquivo com uma responsabilidade e permite testar a lógica sozinha (veja `test/widget_test.dart`).

### Componentização e imports pela raiz

`BalanceCard` e `HistoryItem` ficam em `widgets/` e são reaproveitáveis. Os imports usam `package:cp3_controle_gastos/...`, que sempre aponta para a pasta `lib/` do projeto. É a mesma ideia do alias `@/` do React Native: o import não quebra se o arquivo mudar de pasta.

### Widgets usados e seus equivalentes no React Native

| Flutter | React Native | Uso no app |
| --- | --- | --- |
| `MaterialApp` | (raiz do app) | Tema e tela inicial |
| `Scaffold` + `AppBar` | `SafeAreaView` + cabeçalho | Estrutura da tela |
| `Column` / `Row` | `View` com `flexDirection` | Layout vertical e horizontal |
| `Text` | `Text` | Saldo, mensagens, itens |
| `TextField` + `TextEditingController` | `TextInput` com `value` / `onChangeText` | Campo do valor. O controller lê o texto e limpa o campo depois do sucesso; ele é liberado no `dispose()` quando a tela sai de uso |
| `ElevatedButton` / `IconButton` | `Button` / `TouchableOpacity` | Botões Entrou, Saiu e X |
| `ListView.builder` | `FlatList` | Histórico. Só monta os itens visíveis, como a `FlatList` |
| `SnackBar` | `Alert.alert` | Aviso de erro |
| `if (...)` dentro da lista de `children` | `{condicao && <Componente />}` | Mostrar a mensagem só quando ela existe |
| Operador ternário (`? :`) | Operador ternário | Mostrar "Nenhuma transação registrada." ou a lista |
