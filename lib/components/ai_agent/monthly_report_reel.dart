import 'package:flutter/material.dart';

class MonthlyReportReelPage extends StatelessWidget {
  final Map<String, dynamic> monthlyReport;

  const MonthlyReportReelPage({Key? key, required this.monthlyReport})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract the detailed report from the JSON.
    final Map<String, dynamic> detail = monthlyReport["detailed_report"] ?? {};

    // Overall summary and category analysis.
    final String overallSummary =
        detail["overall_summary"] ?? "No overall summary available.";
    final List<dynamic> categoryAnalysis = detail["category_analysis"] ?? [];

    // List of background images from assets.
    final List<String> backgroundImages = [
      "lib/assets/ai_agent/bg1.jpg",
      "lib/assets/ai_agent/bg2.jpg",
      "lib/assets/ai_agent/bg3.jpg",
      "lib/assets/ai_agent/bg4.jpg",
      "lib/assets/ai_agent/bg5.jpg",
    ];

    // Build pages list:
    List<Widget> pages = [];

    // Page 1: Overall Summary.
    pages.add(
      _buildPage(
        context: context,
        backgroundImage: backgroundImages[0],
        content: Center(
          child: Text(
            overallSummary,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 2,
                  color: Colors.black45,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    // For each category, create a page.
    for (int i = 0; i < categoryAnalysis.length; i++) {
      final category = categoryAnalysis[i];
      // Cycle background images if there are more pages than images.
      final bgImage = backgroundImages[i % backgroundImages.length];
      pages.add(
        _buildPage(
          context: context,
          backgroundImage: bgImage,
          content: _buildCategoryContent(category),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Monthly Report Reel")),
      body: Stack(
        children: [
          // Vertical PageView for the reels.
          PageView(scrollDirection: Axis.vertical, children: pages),
          // Bouncing indicator at the bottom center.
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(child: BounceIndicator()),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required BuildContext context,
    required String backgroundImage,
    required Widget content,
  }) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backgroundImage),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.3),
            BlendMode.darken,
          ),
        ),
      ),
      child: Padding(padding: const EdgeInsets.all(24.0), child: content),
    );
  }

  Widget _buildCategoryContent(dynamic category) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          category["category"] ?? "Unknown Category",
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 2,
                color: Colors.black45,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          "Actual Spending: ${category["actual_spending"] ?? "N/A"} MKD",
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 2,
                color: Colors.black45,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          "Expected Budget: ${category["expected_budget"] ?? "N/A"} MKD",
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 2,
                color: Colors.black45,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          "Deviation: ${category["deviation"] ?? "N/A"}",
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 2,
                color: Colors.black45,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          category["category_summary"] ?? "",
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 2,
                color: Colors.black45,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        if (category["recommendations"] != null)
          ...List<Widget>.from(
            (category["recommendations"] as List).map((rec) {
              return Text(
                "• $rec",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 2,
                      color: Colors.black45,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              );
            }),
          ),
      ],
    );
  }
}

// BounceIndicator widget for a bouncing arrow
class BounceIndicator extends StatefulWidget {
  const BounceIndicator({Key? key}) : super(key: key);

  @override
  _BounceIndicatorState createState() => _BounceIndicatorState();
}

class _BounceIndicatorState extends State<BounceIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: const Icon(
        Icons.keyboard_arrow_down,
        size: 40,
        color: Colors.white,
      ),
    );
  }
}
