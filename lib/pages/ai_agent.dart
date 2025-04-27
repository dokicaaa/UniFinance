import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:banking4students/components/ai_agent/weekly_plan_card.dart';
import 'package:banking4students/components/ai_agent/spending_alternatives_card.dart';
import 'package:banking4students/components/ai_agent/budget_summary_card.dart';
import 'package:banking4students/components/ai_agent/pending_budget_card.dart';
import 'package:banking4students/providers/weekly_plan_provider.dart';
import 'package:banking4students/providers/spending_alternatives_provider.dart';
import 'package:banking4students/providers/budget_provider.dart';
import 'package:banking4students/providers/monthly_report_provider.dart';
import 'package:banking4students/components/ai_agent/monthly_report_reel.dart';

class AiAgentPage extends StatefulWidget {
  const AiAgentPage({Key? key}) : super(key: key);

  @override
  _AiAgentPageState createState() => _AiAgentPageState();
}

class _AiAgentPageState extends State<AiAgentPage> {
  bool _isGeneratingAlternatives = false;
  bool _isFetchingReport = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<WeeklyPlanProvider>(context, listen: false).loadWeeklyPlan();
      Provider.of<BudgetProvider>(context, listen: false).loadBudgetSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0), // Global page padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekly Financial Plan Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "📊 Your Weekly Financial Plan",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Consumer<WeeklyPlanProvider>(
              builder: (context, weeklyPlanProvider, child) {
                if (weeklyPlanProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (weeklyPlanProvider.weeklyPlan == null) {
                  return Column(
                    children: [
                      const Text("No weekly plan available."),
                      const SizedBox(height: 10),
                      _buildFetchButton(
                        () => weeklyPlanProvider.loadWeeklyPlan(
                          forceRefresh: true,
                        ),
                        "Fetch Weekly Plan",
                        isGradient: false,
                      ),
                    ],
                  );
                } else {
                  return WeeklyPlanCard(
                    weeklyPlan: weeklyPlanProvider.weeklyPlan!,
                  );
                }
              },
            ),
            const SizedBox(height: 20),

            // Weekly Budget Report Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "🎯 Your Weekly Budget Report",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Consumer<BudgetProvider>(
              builder: (context, budgetProvider, child) {
                if (budgetProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (budgetProvider.budgetSummary.isEmpty) {
                  return Column(
                    children: [
                      const Text("No budget summary available."),
                      const SizedBox(height: 10),
                      _buildFetchButton(
                        () => budgetProvider.loadBudgetSummary(
                          forceRefresh: true,
                        ),
                        "Fetch Budget Summary",
                        isGradient: true,
                      ),
                    ],
                  );
                } else {
                  return BudgetSummaryCard(
                    budgetUpdates: budgetProvider.budgetSummary,
                  );
                }
              },
            ),
            const SizedBox(height: 20),

            // Pending Budget Section
            Consumer<BudgetProvider>(
              builder: (context, budgetProvider, child) {
                return PendingBudgetCard(
                  pendingBudgets: budgetProvider.pendingBudgets,
                  onConfirm:
                      (category, amount) =>
                          budgetProvider.createBudget(category, amount),
                  onDecline:
                      (category) => budgetProvider.declineBudget(category),
                );
              },
            ),
            const SizedBox(height: 20),

            // Spending Alternatives Section with a placeholder card
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "💵 See what else you can spend your money on!",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Consumer<SpendingAlternativesProvider>(
              builder: (context, spendingAlternativesProvider, child) {
                if (spendingAlternativesProvider.isLoading ||
                    _isGeneratingAlternatives) {
                  return const Center(child: CircularProgressIndicator());
                } else if (spendingAlternativesProvider.spendingAlternatives ==
                    null) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Theme.of(context).colorScheme.tertiary,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment:
                              CrossAxisAlignment.start, // Align text to left
                          children: [
                            Text(
                              "Discover exciting spending alternatives!",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: _buildSimpleButton(
                                () async {
                                  setState(
                                    () => _isGeneratingAlternatives = true,
                                  );
                                  await spendingAlternativesProvider
                                      .loadSpendingAlternatives(
                                        forceRefresh: true,
                                      );
                                  setState(
                                    () => _isGeneratingAlternatives = false,
                                  );
                                },
                                "Generate Alternatives",
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return SpendingAlternativesCard(
                    spendingAlternatives:
                        spendingAlternativesProvider.spendingAlternatives!,
                  );
                }
              },
            ),
            const SizedBox(height: 30),

            // Monthly Report Section with animated call-to-action card
            _buildMonthlyReportSection(),
          ],
        ),
      ),
    );
  }

  /// Gradient Button for Monthly Report (legacy button, not used in the new monthly report section)
  Widget _buildGradientButton(VoidCallback onPressed, String text) {
    return Container(
      width: 300,
      height: 55,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.cyan],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Simple Blue Button for Alternatives and similar actions
  Widget _buildSimpleButton(
    VoidCallback onPressed,
    String text, {
    required Color color,
  }) {
    return Container(
      width: 250,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Shared Fetch Button – toggles between gradient and simple styles
  Widget _buildFetchButton(
    VoidCallback onPressed,
    String text, {
    bool isGradient = false,
  }) {
    return isGradient
        ? _buildGradientButton(onPressed, text)
        : _buildSimpleButton(onPressed, text, color: Colors.blue);
  }

  /// Monthly Report Section: Uses AnimatedSwitcher to show a loading card on tap
  Widget _buildMonthlyReportSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        child:
            _isFetchingReport
                ? _buildMonthlyReportLoadingCard(key: const ValueKey("loading"))
                : _buildMonthlyReportCard(key: const ValueKey("normal")),
      ),
    );
  }

  /// Monthly Report Card (call-to-action) when not loading
  Widget _buildMonthlyReportCard({Key? key}) {
    return GestureDetector(
      key: key,
      onTap: () async {
        setState(() => _isFetchingReport = true);
        await Provider.of<MonthlyReportProvider>(
          context,
          listen: false,
        ).loadMonthlyReport(forceRefresh: true);
        setState(() => _isFetchingReport = false);
        final monthlyReport =
            Provider.of<MonthlyReportProvider>(
              context,
              listen: false,
            ).monthlyReport;
        if (monthlyReport != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      MonthlyReportReelPage(monthlyReport: monthlyReport),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to load monthly report.")),
          );
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.cyan],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "📅 Discover Your Monthly Report",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Tap to view insights & trends, just like Spotify Wrapped!",
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, size: 30, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  /// Monthly Report Loading Card (shown during fetching)
  Widget _buildMonthlyReportLoadingCard({Key? key}) {
    return Card(
      key: key,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.cyan],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Generating your monthly report...",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Please wait",
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, size: 30, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
