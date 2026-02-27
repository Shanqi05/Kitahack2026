// lib/features/wizard/widgets/step_3_financial.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/data_models.dart';
import '../../../core/models/user_session_model.dart';

class Step3Financial extends StatefulWidget {
  const Step3Financial({super.key});

  @override
  State<Step3Financial> createState() => _Step3FinancialState();
}

class _Step3FinancialState extends State<Step3Financial> {
  late TextEditingController _incomeController;

  @override
  void initState() {
    super.initState();
    final model = context.read<UserSessionModel>();
    _incomeController = TextEditingController(
      text: model.financial.income > 0
          ? model.financial.income.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  String _getBracket(double income) {
    if (income < 4850) return 'B40';
    if (income < 10960) return 'M40';
    return 'T20';
  }

  Color _getBracketColor(String bracket) {
    switch (bracket) {
      case 'B40':
        return Colors.green;
      case 'M40':
        return Colors.orange;
      case 'T20':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserSessionModel>(
      builder: (context, model, child) {
        final financial = model.financial;
        final bracket = _getBracket(financial.income);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Financial Background",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // 1. Total Monthly Household Income
              Text(
                'Total Monthly Household Income (RM)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _incomeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 5000',
                  prefixText: 'RM ',
                  prefixIcon: Icon(Icons.monetization_on),
                  helperText: "Combine income of all working household members",
                ),
                onChanged: (value) {
                  final income = double.tryParse(value) ?? 0.0;
                  model.updateFinancial(income: income);
                },
              ),
              const SizedBox(height: 24),

              // 2. Household Bracket Badge
              Row(
                children: [
                  const Text(
                    'Household Bracket: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getBracketColor(bracket).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _getBracketColor(bracket)),
                    ),
                    child: Text(
                      bracket,
                      style: TextStyle(
                        color: _getBracketColor(bracket),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 3. Number of Dependents
              Text(
                'Number of Dependents',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: financial.dependents > 0
                          ? () => model.updateFinancial(
                              dependents: financial.dependents - 1,
                            )
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      iconSize: 32,
                    ),
                    Column(
                      children: [
                        Text(
                          '${financial.dependents}',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          "Dependents",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => model.updateFinancial(
                        dependents: financial.dependents + 1,
                      ),
                      icon: const Icon(Icons.add_circle_outline),
                      iconSize: 32,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 4. Location
              Text('Location', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Urban'),
                      value: 'Urban',
                      groupValue: financial.location,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          model.updateFinancial(location: value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Rural'),
                      value: 'Rural',
                      groupValue: financial.location,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          model.updateFinancial(location: value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
