// lib/features/wizard/widgets/step_5_analysis.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/user_session_model.dart';
import '../../dashboard/screens/main_dashboard_shell.dart';
import 'dart:convert';

class Step5Analysis extends StatefulWidget {
  const Step5Analysis({super.key});

  @override
  State<Step5Analysis> createState() => _Step5AnalysisState();
}

class _Step5AnalysisState extends State<Step5Analysis> {
  void _handleSubmit(BuildContext context, UserSessionModel model) {
    final jsonData = model.exportJson();
    // Pretty print JSON
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
    print('FINAL JSON:\n$jsonString');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile submitted! Redirecting to Dashboard...'),
      ),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainDashboardShell()),
    );
  }

  Color _getIncomeColor(String bracket) {
    switch (bracket.toUpperCase()) {
      case 'B40':
        return Colors.green;
      case 'M40':
        return Colors.orange;
      case 'T20':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserSessionModel>(
      builder: (context, model, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Profile Analysis & Summary",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Summary Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive Grid: 2 columns if wide enough, else 1
                  int crossAxisCount = constraints.maxWidth > 500 ? 2 : 1;
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 2.5, // Adjust based on content
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildSummaryCard(
                        title: "Identity",
                        icon: Icons.person,
                        content: [
                          "Name: ${model.fullName}",
                          "State: ${model.state}",
                          "Ethnicity: ${model.ethnicity}",
                        ],
                      ),
                      _buildSummaryCard(
                        title: "Academic",
                        icon: Icons.school,
                        content: [
                          "Status: ${model.currentStatus}",
                          "SPM Passed: ${model.hasSpm ? 'Yes' : 'No'}",
                          if (model.cgpa != null)
                            "CGPA: ${model.cgpa!.toStringAsFixed(2)}",
                        ],
                      ),
                      _buildSummaryCard(
                        title: "Financial",
                        icon: Icons.attach_money,
                        content: [
                          "Household Income: RM ${model.householdIncome}",
                          "Dependents: ${model.dependents}",
                        ],
                        trailing: Chip(
                          label: Text(model.incomeBracket),
                          backgroundColor: _getIncomeColor(
                            model.incomeBracket,
                          ).withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: _getIncomeColor(model.incomeBracket),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildSummaryCard(
                        title: "Talent",
                        icon: Icons.star,
                        content: [
                          "PAJSK: ${model.pajskScore.toStringAsFixed(1)}",
                          "Top Interest: ${model.topInterest}",
                        ],
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 30),

              // Merit Score Display
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      "Predicted Merit Score",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      model.calculateMeritScore().toStringAsFixed(2),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Based on (Academic * 0.9) + PAJSK",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => _handleSubmit(context, model),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text("Submit & Get Recommendations"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required IconData icon,
    required List<String> content,
    Widget? trailing,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20, color: Colors.blueGrey),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                if (trailing != null) trailing,
              ],
            ),
            const Divider(height: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: content
                    .map(
                      (text) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
