import 'package:flutter/material.dart';

import 'ads.dart';
import 'finance.dart';

class LoanPage extends StatefulWidget {
  const LoanPage({super.key});

  @override
  State<LoanPage> createState() => _LoanPageState();
}

class _LoanPageState extends State<LoanPage> {
  final _amount = TextEditingController(text: '50000');
  final _rate = TextEditingController(text: '24');
  final _months = TextEditingController(text: '12');
  LoanMethod _method = LoanMethod.fixedPayment;
  LoanResult? _result;

  @override
  void initState() {
    super.initState();
    _calculate(showAd: false);
  }

  @override
  void dispose() {
    _amount.dispose();
    _rate.dispose();
    _months.dispose();
    super.dispose();
  }

  void _calculate({bool showAd = true}) {
    FocusScope.of(context).unfocus();
    setState(() {
      _result = calculateLoan(
        principal: parseNumber(_amount.text),
        annualRate: parseNumber(_rate.text),
        months: parseNumber(_months.text).round(),
        method: _method,
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
        _field(_amount, 'Monto del préstamo', suffix: 'MXN'),
        _field(_rate, 'Tasa de interés anual', suffix: '%'),
        _field(_months, 'Plazo', suffix: 'meses'),
        SegmentedButton<LoanMethod>(
          showSelectedIcon: false,
          segments: [
            for (final m in LoanMethod.values)
              ButtonSegment(value: m, label: Text(m.label)),
          ],
          selected: {_method},
          onSelectionChanged: (s) => setState(() => _method = s.first),
        ),
        const SizedBox(height: 6),
        Text(_method.hint, style: theme.textTheme.bodySmall),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _calculate,
          icon: const Icon(Icons.calculate),
          label: const Text('Calcular'),
        ),
        if (res != null && res.schedule.isNotEmpty) ...[
          const SizedBox(height: 20),
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _method == LoanMethod.fixedPrincipal
                        ? 'Primer pago mensual'
                        : 'Pago mensual',
                  ),
                  Text(
                    pesos(res.firstPayment),
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (_method == LoanMethod.fixedPrincipal)
                    Text('Último pago: ${pesos(res.lastPayment)}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _stat('Intereses', pesos(res.totalInterest))),
              const SizedBox(width: 8),
              Expanded(child: _stat('Total a pagar', pesos(res.totalPaid))),
            ],
          ),
          const SizedBox(height: 16),
          Text('Tabla de pagos', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _ScheduleTable(rows: res.schedule),
          const SizedBox(height: 12),
          Text(
            'Cálculo informativo. El costo real de un crédito puede incluir comisiones, seguros e IVA.',
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

class _ScheduleTable extends StatelessWidget {
  const _ScheduleTable({required this.rows});

  final List<Installment> rows;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    final head = style?.copyWith(fontWeight: FontWeight.bold);
    return Column(
      children: [
        Row(children: [
          Expanded(flex: 1, child: Text('#', style: head)),
          Expanded(flex: 3, child: Text('Pago', style: head)),
          Expanded(flex: 3, child: Text('Interés', style: head)),
          Expanded(flex: 3, child: Text('Saldo', style: head)),
        ]),
        const Divider(),
        for (final r in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(children: [
              Expanded(flex: 1, child: Text('${r.number}', style: style)),
              Expanded(flex: 3, child: Text(pesos(r.payment), style: style)),
              Expanded(flex: 3, child: Text(pesos(r.interest), style: style)),
              Expanded(flex: 3, child: Text(pesos(r.balance), style: style)),
            ]),
          ),
      ],
    );
  }
}
