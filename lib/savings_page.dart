import 'package:flutter/material.dart';

import 'ads.dart';
import 'finance.dart';
import 'widgets.dart';

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

  TextStyle? _head(ThemeData t) =>
      t.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold);

  Widget _cell(ThemeData t, int flex, String text) => Expanded(
    flex: flex,
    child: Text(text, style: t.textTheme.bodySmall),
  );

  @override
  Widget build(BuildContext context) {
    final res = _result;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const HeroHeader(
          title: 'Haz crecer tu ahorro',
          subtitle: 'Interés compuesto con aportaciones e inflación.',
        ),
        const SizedBox(height: 16),
        Section(
          title: 'Datos del ahorro',
          child: Column(
            children: [
              _field(
                _initial,
                'Ahorro inicial',
                suffix: 'MXN',
                icon: Icons.account_balance_wallet,
              ),
              _field(
                _deposit,
                'Aportación mensual',
                suffix: 'MXN',
                icon: Icons.add_card,
              ),
              _field(
                _rate,
                'Rendimiento anual',
                suffix: '%',
                icon: Icons.show_chart,
              ),
              _field(
                _months,
                'Plazo',
                suffix: 'meses',
                icon: Icons.calendar_month,
              ),
              _field(
                _inflation,
                'Inflación anual estimada',
                suffix: '%',
                icon: Icons.local_fire_department,
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _calculate,
                  icon: const Icon(Icons.savings),
                  label: const Text(
                    'Calcular',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (res != null && res.rows.isNotEmpty) ...[
          const SizedBox(height: 16),
          ResultCard(
            label: 'Tendrás al final',
            value: pesos(res.finalBalance),
            footnote: res.inflationRate > 0
                ? 'Equivale a ${pesos(res.realValue)} de hoy tras la inflación'
                : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: Icons.south_west,
                  label: 'Aportaste',
                  value: pesos(res.totalContributed),
                  color: kBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  icon: Icons.auto_graph,
                  label: 'Ganancia',
                  value: pesos(res.totalInterest),
                  color: kTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Section(
            title: 'Aportado vs. ganancia',
            child: DonutChart(
              principal: res.totalContributed,
              interest: res.totalInterest,
            ),
          ),
          const SizedBox(height: 16),
          Section(
            title: 'Crecimiento mes a mes',
            child: LineChart(
              series: [
                Series([for (final r in res.rows) r.balance], kTeal, 'Saldo'),
                Series(
                  [for (final r in res.rows) r.contributed],
                  kBlue,
                  'Aportado',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Section(
            title: 'Por mes',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(flex: 1, child: Text('#', style: _head(theme))),
                    Expanded(
                      flex: 3,
                      child: Text('Aportado', style: _head(theme)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text('Ganancia', style: _head(theme)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text('Saldo', style: _head(theme)),
                    ),
                  ],
                ),
                const Divider(),
                for (final r in res.rows)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        _cell(theme, 1, '${r.month}'),
                        _cell(theme, 3, pesos(r.contributed)),
                        _cell(theme, 3, pesos(r.interest)),
                        _cell(theme, 3, pesos(r.balance)),
                      ],
                    ),
                  ),
              ],
            ),
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
}
