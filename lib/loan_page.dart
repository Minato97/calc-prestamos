import 'package:flutter/material.dart';

import 'ads.dart';
import 'finance.dart';
import 'widgets.dart';

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

  Widget _field(
    TextEditingController c,
    String label, {
    String? suffix,
    IconData? icon,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixIcon: icon == null ? null : Icon(icon),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
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
        const HeroHeader(
          title: 'Simula tu préstamo',
          subtitle: 'Pago mensual, intereses y tabla de pagos al instante.',
        ),
        const SizedBox(height: 16),
        Section(
          title: 'Datos del crédito',
          child: Column(
            children: [
              _field(
                _amount,
                'Monto del préstamo',
                suffix: 'MXN',
                icon: Icons.attach_money,
              ),
              _field(
                _rate,
                'Tasa de interés anual',
                suffix: '%',
                icon: Icons.percent,
              ),
              _field(
                _months,
                'Plazo',
                suffix: 'meses',
                icon: Icons.calendar_month,
              ),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<LoanMethod>(
                  showSelectedIcon: false,
                  segments: [
                    for (final m in LoanMethod.values)
                      ButtonSegment(value: m, label: Text(m.label)),
                  ],
                  selected: {_method},
                  onSelectionChanged: (s) => setState(() => _method = s.first),
                ),
              ),
              const SizedBox(height: 8),
              Text(_method.hint, style: theme.textTheme.bodySmall),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _calculate,
                  icon: const Icon(Icons.calculate),
                  label: const Text(
                    'Calcular',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (res != null && res.schedule.isNotEmpty) ...[
          const SizedBox(height: 16),
          ResultCard(
            label: _method == LoanMethod.fixedPrincipal
                ? 'Primer pago mensual'
                : 'Pago mensual',
            value: pesos(res.firstPayment),
            footnote: _method == LoanMethod.fixedPrincipal
                ? 'Último pago: ${pesos(res.lastPayment)}'
                : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: Icons.trending_up,
                  label: 'Intereses',
                  value: pesos(res.totalInterest),
                  color: kGold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  icon: Icons.payments,
                  label: 'Total a pagar',
                  value: pesos(res.totalPaid),
                  color: kBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Section(
            title: 'Capital vs. intereses',
            child: DonutChart(
              principal: parseNumber(_amount.text),
              interest: res.totalInterest,
            ),
          ),
          const SizedBox(height: 16),
          Section(
            title: 'Saldo pendiente',
            child: LineChart(
              series: [
                Series(
                  [
                    parseNumber(_amount.text),
                    for (final r in res.schedule) r.balance,
                  ],
                  kBlue,
                  'Saldo',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Section(
            title: 'Tabla de pagos',
            child: _ScheduleTable(rows: res.schedule),
          ),
          const SizedBox(height: 12),
          Text(
            'Cálculo informativo. El costo real de un crédito puede incluir comisiones, seguros e IVA.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
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
        Row(
          children: [
            Expanded(flex: 1, child: Text('#', style: head)),
            Expanded(flex: 3, child: Text('Pago', style: head)),
            Expanded(flex: 3, child: Text('Interés', style: head)),
            Expanded(flex: 3, child: Text('Saldo', style: head)),
          ],
        ),
        const Divider(),
        for (final r in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Expanded(flex: 1, child: Text('${r.number}', style: style)),
                Expanded(flex: 3, child: Text(pesos(r.payment), style: style)),
                Expanded(flex: 3, child: Text(pesos(r.interest), style: style)),
                Expanded(flex: 3, child: Text(pesos(r.balance), style: style)),
              ],
            ),
          ),
      ],
    );
  }
}
