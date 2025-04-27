import 'package:banking4students/components/ai_agent/weekly_plan_card.dart';
import 'package:banking4students/components/whole_components/transactions_graphic.dart';
import 'package:banking4students/components/dashboard/dashboard_budget_card.dart';
import 'package:banking4students/components/dashboard/dashboard_savings_card.dart'; // New import
import 'package:banking4students/providers/weekly_plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy weekly data for the transaction graph (if needed)
    final weeklyData = [
      {"day": "S", "income": 5123.47, "expense": 1123.47},
      {"day": "M", "income": 4500.00, "expense": 1000.00},
      {"day": "T", "income": 3000.00, "expense": 1500.00},
      {"day": "W", "income": 5200.00, "expense": 2200.00},
      {"day": "T", "income": 4100.00, "expense": 1900.00},
      {"day": "F", "income": 3900.00, "expense": 800.00},
      {"day": "S", "income": 6200.00, "expense": 2700.00},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 40, top: 16),
      child: Column(
        children: [
          // The transactions graph (dummy data for now)
          TransactionsGraphic(),

          const SizedBox(height: 10),

          Consumer<WeeklyPlanProvider>(
            builder: (context, weeklyPlanProvider, child) {
              if (weeklyPlanProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (weeklyPlanProvider.weeklyPlan == null) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: Title and Robot Icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "Custom AI Finance Plan for Smarter Spendings!",
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18, // Customizable font size
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            SizedBox(width: 20),
                            Container(
                              width: 50, // Ensure it's a perfect circle
                              height: 50,
                              decoration: const BoxDecoration(
                                color: Color(
                                  0xFFEBF2FF,
                                ), // Soft blue background
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 3),
                                child: Icon(
                                  FontAwesomeIcons.robot,
                                  size: 24, // Adjusted for better centering
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Centered Button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 140, // Shorter button width
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                              ),
                              onPressed: () {
                                weeklyPlanProvider.loadWeeklyPlan(
                                  forceRefresh: true,
                                );
                              },
                              child: const Text(
                                "Generate",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return WeeklyPlanCard(
                  weeklyPlan: weeklyPlanProvider.weeklyPlan!,
                );
              }
            },
          ),

          const SizedBox(height: 10),
          // Existing budgets carousel
          const DashboardBudgetCarousel(),
          const SizedBox(height: 10),
          // New savings carousel component
          const DashboardSavingsCarousel(), // Carousel logic moved to dashboard_budget_card.dart
        ],
      ),
    );
  }
}
