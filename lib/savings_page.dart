import 'package:flutter/material.dart';

import 'ads.dart';
import 'finance.dart';

class SavingsPage extends StatefulWidget {
  const SavingsPage({super.key});

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  final _initial = TextEditingController(text: '10000');
  final _deposit = TextEditingController(text: '1000');
  final _rate = TextEditingController(text: '8');
  final _months = TextEditingController(text: '24');
  final _inflation = TextEditingController(text: '4');
  SavingsResult? _result;

  @override
  void initState() {
    super.initState();
    _calculate(showAd: false);
  }

  @override
  void dispose() {
    for (final c in [_initial, _deposit, _rate, _months, _inflation]) {
      c.dispose();
    }
    super.dispose();
  }

  void _calculate({bool showAd = true}) {
    FocusScope.of(context).unfocus();
    setState(() {
      _result = calculateSavings(
        initial: parseNumber(_initial.text),
        monthlyDeposit: parseNumber(_deposit.text),
        annualRate: parseNumber(_rate.text),
        months: parseNumber(_months.text).round(),
        inflationRate: parseNumber(_inflation.text),
      );
    });
    if (showAd) AdService.instance.maybeShowInterstitial(every: 4);
  }

  Widget _field(TextEditingController c, String label, {String? suffix}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: label,
            suffixText: suffix,
            border: const OutlineInputBorder(),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final res = _result;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _field(_initial, 'Ahorro inicial', suffix: 'MXN'),
        _field(_deposit, 'Aportación mensual', suffix: 'MXN'),
        _field(_rate, 'Rendimiento anual', suffix: '%'),
        _field(_months, 'Plazo', suffix: 'meses'),
        _field(_inflation, 'Inflación anual estimada', suffix: '%'),
        FilledButton.icon(
          onPressed: _calculate,
          icon: const Icon(Icons.savings),
          label: const Text('Calcular'),
        ),
        if (res != null && res.rows.isNotEmpty) ...[
          const SizedBox(height: 20),
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tendrás al final'),
                  Text(
                    pesos(res.finalBalance),
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (res.inflationRate > 0)
                    Text(
                      'Equivale a ${pesos(res.realValue)} de hoy tras la inflación',
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _stat('Aportaste', pesos(res.totalContributed))),
              const SizedBox(width: 8),
              Expanded(child: _stat('Ganancia', pesos(res.totalInterest))),
            ],
          ),
          const SizedBox(height: 16),
          Text('Por mes', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final r in res.rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(children: [
                Expanded(
                    flex: 1,
                    child: Text('${r.month}', style: theme.textTheme.bodySmall)),
                Expanded(
                    flex: 3,
                    child: Text(pesos(r.contributed),
                        style: theme.textTheme.bodySmall)),
                Expanded(
                    flex: 3,
                    child: Text(pesos(r.interest),
                        style: theme.textTheme.bodySmall)),
                Expanded(
                    flex: 3,
                    child: Text(pesos(r.balance),
                        style: theme.textTheme.bodySmall)),
              ]),
            ),
          const SizedBox(height: 12),
          Text(
            'Cálculo informativo con interés compuesto mensual. Los rendimientos reales pueden variar.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  Widget _stat(String label, String value) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
}
