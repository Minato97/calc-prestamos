import 'dart:math';

enum LoanMethod { fixedPayment, fixedPrincipal, simpleInterest }

extension LoanMethodText on LoanMethod {
  String get label => switch (this) {
    LoanMethod.fixedPayment => 'Cuota fija',
    LoanMethod.fixedPrincipal => 'Capital fijo',
    LoanMethod.simpleInterest => 'Interés simple',
  };

  String get hint => switch (this) {
    LoanMethod.fixedPayment => 'Pagas lo mismo cada mes. Es el esquema más común en créditos personales y de auto.',
    LoanMethod.fixedPrincipal =>
      'Abonas el mismo capital cada mes; la cuota baja con el tiempo.',
    LoanMethod.simpleInterest =>
      'El interés se calcula sobre el monto inicial durante todo el plazo.',
  };
}

class Installment {
  const Installment({
    required this.number,
    required this.payment,
    required this.principal,
    required this.interest,
    required this.balance,
  });

  final int number;
  final double payment;
  final double principal;
  final double interest;
  final double balance;
}

class LoanResult {
  const LoanResult(this.schedule);

  final List<Installment> schedule;

  double get firstPayment => schedule.isEmpty ? 0 : schedule.first.payment;
  double get lastPayment => schedule.isEmpty ? 0 : schedule.last.payment;
  double get totalInterest => schedule.fold(0, (s, i) => s + i.interest);
  double get totalPaid => schedule.fold(0, (s, i) => s + i.payment);
}

/// [annualRate] en porcentaje (por ejemplo 24 para 24 % anual nominal).
LoanResult calculateLoan({
  required double principal,
  required double annualRate,
  required int months,
  required LoanMethod method,
}) {
  if (principal <= 0 || months <= 0) return const LoanResult([]);
  final r = annualRate / 100 / 12;
  final rows = <Installment>[];
  var balance = principal;

  switch (method) {
    case LoanMethod.fixedPayment:
      final payment = r == 0
          ? principal / months
          : principal * r / (1 - pow(1 + r, -months));
      for (var i = 1; i <= months; i++) {
        final interest = balance * r;
        final cap = i == months ? balance : payment - interest;
        balance = max(0, balance - cap);
        rows.add(
          Installment(
            number: i,
            payment: cap + interest,
            principal: cap,
            interest: interest,
            balance: balance,
          ),
        );
      }
    case LoanMethod.fixedPrincipal:
      final cap = principal / months;
      for (var i = 1; i <= months; i++) {
        final interest = balance * r;
        balance = max(0, balance - cap);
        rows.add(
          Installment(
            number: i,
            payment: cap + interest,
            principal: cap,
            interest: interest,
            balance: balance,
          ),
        );
      }
    case LoanMethod.simpleInterest:
      final totalInterest = principal * (annualRate / 100) * months / 12;
      final cap = principal / months;
      final interest = totalInterest / months;
      for (var i = 1; i <= months; i++) {
        balance = max(0, balance - cap);
        rows.add(
          Installment(
            number: i,
            payment: cap + interest,
            principal: cap,
            interest: interest,
            balance: balance,
          ),
        );
      }
  }
  return LoanResult(rows);
}

class SavingsRow {
  const SavingsRow(this.month, this.contributed, this.interest, this.balance);

  final int month;
  final double contributed;
  final double interest;
  final double balance;
}

class SavingsResult {
  const SavingsResult(this.rows, this.inflationRate);

  final List<SavingsRow> rows;
  final double inflationRate;

  double get finalBalance => rows.isEmpty ? 0 : rows.last.balance;
  double get totalContributed => rows.isEmpty ? 0 : rows.last.contributed;
  double get totalInterest => rows.isEmpty ? 0 : rows.last.interest;

  /// Poder adquisitivo del monto final en pesos de hoy.
  double get realValue {
    if (rows.isEmpty || inflationRate == 0) return finalBalance;
    return finalBalance / pow(1 + inflationRate / 100, rows.length / 12);
  }
}

/// Interés compuesto mensual; el depósito se hace al inicio de cada mes.
SavingsResult calculateSavings({
  required double initial,
  required double monthlyDeposit,
  required double annualRate,
  required int months,
  double inflationRate = 0,
}) {
  if (months <= 0) return SavingsResult(const [], inflationRate);
  final r = annualRate / 100 / 12;
  final rows = <SavingsRow>[];
  var balance = initial;
  var contributed = initial;
  for (var m = 1; m <= months; m++) {
    balance += monthlyDeposit;
    contributed += monthlyDeposit;
    balance *= 1 + r;
    rows.add(SavingsRow(m, contributed, balance - contributed, balance));
  }
  return SavingsResult(rows, inflationRate);
}

/// Formato de pesos mexicanos: $12,345.67
String pesos(double v, {int decimals = 2}) {
  final neg = v < 0;
  final fixed = v.abs().toStringAsFixed(decimals);
  final parts = fixed.split('.');
  final intPart = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  final dec = parts.length > 1 ? '.${parts[1]}' : '';
  return '${neg ? '-' : ''}\$$intPart$dec';
}

/// Convierte texto con comas o puntos a número; devuelve 0 si no es válido.
double parseNumber(String s) {
  final cleaned = s.replaceAll(',', '').replaceAll('\$', '').trim();
  return double.tryParse(cleaned) ?? 0;
}
