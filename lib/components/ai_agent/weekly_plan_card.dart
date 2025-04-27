import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // For better icons
import 'package:banking4students/providers/navigation_provider.dart';

class WeeklyPlanCard extends StatefulWidget {
  final Map<String, dynamic> weeklyPlan;

  const WeeklyPlanCard({Key? key, required this.weeklyPlan}) : super(key: key);

  @override
  _WeeklyPlanCardState createState() => _WeeklyPlanCardState();
}

class _WeeklyPlanCardState extends State<WeeklyPlanCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    final weeklyPlan = widget.weeklyPlan;

    if (weeklyPlan.isEmpty) {
      return Center(
        child: Text(
          "No weekly plan data available.",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    // Build the pages for the PageView
    List<Widget> pages = [
      _buildSummaryPage(weeklyPlan),
      _buildBudgetStatusPage(weeklyPlan),
    ];

    // 3) Pages: Each recommendation is its own page
    final List recs = weeklyPlan["recommendations"] ?? [];
    for (var rec in recs) {
      pages.add(_buildRecommendationPage(rec));
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            navProvider.setSelectedIndex(4);
          },
          child: Container(
            width: double.infinity,
            height: 190, // Fixed height for consistency
            decoration: BoxDecoration(
              color:
                  Theme.of(
                    context,
                  ).colorScheme.secondary, // Darker blueish-gray shade
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                // The horizontal PageView
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    children: pages,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Dots moved OUTSIDE the card
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(pages.length, (index) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index ? Colors.blueAccent : Colors.grey,
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Page 1: Weekly Summary only
  Widget _buildSummaryPage(Map<String, dynamic> weeklyPlan) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(FontAwesomeIcons.calendarCheck, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                "Weekly Plan Summary",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            weeklyPlan["summary"] ?? "No summary available.",
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  /// Page 2: Budget Status + Areas to Improve
  Widget _buildBudgetStatusPage(Map<String, dynamic> weeklyPlan) {
    String budgetStatus = weeklyPlan["budget_health"]?["status"] ?? "Unknown";
    List needsAttention = weeklyPlan["budget_health"]?["needs_attention"] ?? [];

    // Color logic: Green if "within budget", Red if "overspent"
    Color statusColor =
        budgetStatus == "within budget" ? Colors.greenAccent : Colors.redAccent;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(FontAwesomeIcons.wallet, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                "Budget Status: $budgetStatus",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Areas to Improve:",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          if (needsAttention.isNotEmpty)
            for (var area in needsAttention)
              Text(
                "- $area",
                style: const TextStyle(color: Colors.black87, fontSize: 15),
              ),
          if (needsAttention.isEmpty)
            const Text(
              "✅ Nothing to worry about! 🎉",
              style: TextStyle(color: Colors.greenAccent),
            ),
        ],
      ),
    );
  }

  /// Page 3..N: One recommendation per page
  Widget _buildRecommendationPage(dynamic rec) {
    String type = rec.keys.first; // e.g. "adjust_budget", "weekly_goal"
    String text = rec[type] ?? "No details available.";

    // Determine the icon
    IconData icon = FontAwesomeIcons.lightbulb;
    if (type == "adjust_budget") icon = FontAwesomeIcons.slidersH;
    if (type == "weekly_goal") icon = FontAwesomeIcons.flagCheckered;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(fontSize: 16.5, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
