import 'package:calc_prestamos/finance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cuota fija: 50,000 al 24% a 12 meses', () {
    final r = calculateLoan(
        principal: 50000, annualRate: 24, months: 12, method: LoanMethod.fixedPayment);
    expect(r.firstPayment, closeTo(4727.98, 0.01));
    expect(r.schedule.last.balance, closeTo(0, 0.01));
    expect(r.totalPaid, closeTo(r.firstPayment * 12, 0.05));
  });
  test('tasa cero reparte el capital', () {
    final r = calculateLoan(
        principal: 12000, annualRate: 0, months: 12, method: LoanMethod.fixedPayment);
    expect(r.firstPayment, 1000);
    expect(r.totalInterest, 0);
  });
  test('capital fijo: pagos decrecientes', () {
    final r = calculateLoan(
        principal: 12000, annualRate: 12, months: 12, method: LoanMethod.fixedPrincipal);
    expect(r.firstPayment, greaterThan(r.lastPayment));
    expect(r.schedule.last.balance, closeTo(0, 0.01));
  });
  test('interes simple', () {
    final r = calculateLoan(
        principal: 10000, annualRate: 12, months: 12, method: LoanMethod.simpleInterest);
    expect(r.totalInterest, closeTo(1200, 0.01));
    expect(r.firstPayment, closeTo(933.33, 0.01));
  });
  test('entradas invalidas', () {
    expect(calculateLoan(principal: 0, annualRate: 10, months: 12, method: LoanMethod.fixedPayment).schedule, isEmpty);
    expect(calculateLoan(principal: 1000, annualRate: 10, months: 0, method: LoanMethod.fixedPayment).schedule, isEmpty);
  });
  test('ahorro compuesto', () {
    final r = calculateSavings(initial: 10000, monthlyDeposit: 0, annualRate: 12, months: 12);
    expect(r.finalBalance, closeTo(11268.25, 0.01));
    final s = calculateSavings(initial: 0, monthlyDeposit: 1000, annualRate: 0, months: 10);
    expect(s.finalBalance, 10000);
    expect(s.totalInterest, 0);
  });
  test('formato de pesos y parseo', () {
    expect(pesos(1234567.891), '\$1,234,567.89');
    expect(pesos(-50), '-\$50.00');
    expect(parseNumber('1,500.50'), 1500.5);
    expect(parseNumber('abc'), 0);
  });
}
