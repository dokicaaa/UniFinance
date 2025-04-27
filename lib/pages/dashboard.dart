import 'package:banking4students/components/nav_bottom_dialog.dart';
import 'package:banking4students/pages/ai_agent.dart';
import 'package:banking4students/providers/navigation_provider.dart';
import 'package:banking4students/providers/savings_challenge_provider.dart';
import 'package:banking4students/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Example pages
import 'package:banking4students/components/whole_components/dashboard_content.dart';
import 'package:banking4students/pages/balance.dart';
import 'package:banking4students/pages/budget.dart';
import 'package:banking4students/pages/savings.dart';
import 'package:banking4students/pages/bill_splitting.dart';
import 'package:banking4students/components/whole_components/dashboard_content.dart';
import 'package:banking4students/services/auth/auth_service.dart';
import 'package:banking4students/providers/navigation_provider.dart';
import 'package:banking4students/pages/profile.dart';
import 'package:banking4students/components/ai_agent/savings_challenge_overlay.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  // For the lightning icon’s position
  final GlobalKey _lightningKey = GlobalKey();

  // Overlay for the weekend challenge popover
  OverlayEntry? _challengeOverlay;
  bool _isChallengeOpen = false;

  // Animation controller for scaling the popover
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Set up the animation (300ms, ease in/out)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Show or hide the weekend challenge
  void _toggleWeekendChallenge(BuildContext context) async {
    if (_isChallengeOpen) {
      // If open, animate collapse
      _animationController.reverse().then((_) => _removeOverlay());
      _isChallengeOpen = false;
      return;
    }

    // 1) Fetch the weekend challenge
    final challengeProvider = Provider.of<SavingsChallengeProvider>(
      context,
      listen: false,
    );
    await challengeProvider.loadSavingsChallenge(forceRefresh: true);
    final challenge = challengeProvider.savingsChallenge;

    if (challenge == null || challenge.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No weekend challenge available.")),
      );
      return;
    }

    // 2) Build and insert the overlay
    _challengeOverlay = _createChallengeOverlay(challenge);
    Overlay.of(context)!.insert(_challengeOverlay!);

    // 3) Animate open
    _animationController.forward();
    _isChallengeOpen = true;
  }

  // Removes the overlay entry
  void _removeOverlay() {
    _challengeOverlay?.remove();
    _challengeOverlay = null;
  }

  // Creates the overlay entry with scale transition
  OverlayEntry _createChallengeOverlay(Map<String, dynamic> challenge) {
    // Calculate the lightning icon’s position
    final RenderBox iconRenderBox =
        _lightningKey.currentContext!.findRenderObject() as RenderBox;
    final iconPosition = iconRenderBox.localToGlobal(Offset.zero);
    final iconSize = iconRenderBox.size;

    return OverlayEntry(
      builder: (context) {
        // Tapping outside will close it
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (_isChallengeOpen) {
              _animationController.reverse().then((_) => _removeOverlay());
              _isChallengeOpen = false;
            }
          },
          child: Stack(
            children: [
              // The popover near the icon
              Positioned(
                left: iconPosition.dx - 230, // Adjust horizontally
                top: iconPosition.dy + iconSize.height + 6,
                child: ChallengeScaleWidget(
                  scaleAnimation: _scaleAnimation,
                  challenge: challenge,
                  onClose: () {
                    // Close button
                    _animationController.reverse().then(
                      (_) => _removeOverlay(),
                    );
                    _isChallengeOpen = false;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // A helper to show a SnackBar at the top
  void _showTopSnackBar(BuildContext context, String message) {
    final double topMargin =
        kToolbarHeight + MediaQuery.of(context).padding.top + 20;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(top: topMargin, left: 20, right: 20),
      ),
    );
  }

  // Show the separate bottom sheet
  void _showAddOptions(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.user;
    if (user == null) return;

    final currentCurrency = "USD";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => AddNewBottomSheet(
            userId: user.uid,
            currentCurrency: currentCurrency,
            onItemAdded: (String message) {
              _showTopSnackBar(context, message);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        // Titles for each bottom nav item
        final List<String> titles = [
          "Dashboard",
          "Balance",
          "Budget",
          "Savings",
          "Ai-Agent",
          "Bill Splitting",
        ];

        // Pages for each bottom nav index
        final List<Widget> pages = [
          const DashboardContent(),
          const BalancePage(),
          const BudgetPage(),
          const SavingsPage(),
          const AiAgentPage(),
          const BillSplittingPage(),
        ];

        return Scaffold(
          appBar: AppBar(
            actionsPadding: const EdgeInsets.only(right: 10),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  titles[navigationProvider.selectedIndex],
                  style: const TextStyle(fontSize: 24),
                ),
              ],
            ),
            actions: [
              // Lightning icon
              IconButton(
                key: _lightningKey,
                icon: const Icon(Icons.flash_on, color: Colors.blue),
                onPressed: () => _toggleWeekendChallenge(context),
              ),
              // Profile icon
              IconButton(
                icon: const Icon(
                  Icons.account_circle_outlined,
                  color: Color.fromARGB(255, 70, 70, 70),
                ),
                iconSize: 34,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: pages[navigationProvider.selectedIndex],
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddOptions(context),
            child: const Icon(Icons.add),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: const CircleBorder(),
          ),
          bottomNavigationBar: SizedBox(
            height: 80,
            child: BottomAppBar(
              shape: const CircularNotchedRectangle(),
              notchMargin: 8,
              color: Colors.grey.shade200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.dashboard,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 26,
                    ),
                    onPressed: () => navigationProvider.setSelectedIndex(0),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.account_balance_wallet,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 26,
                    ),
                    onPressed: () => navigationProvider.setSelectedIndex(1),
                  ),
                  const SizedBox(width: 48),
                  IconButton(
                    icon: Icon(
                      Icons.pie_chart,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 26,
                    ),
                    onPressed: () => navigationProvider.setSelectedIndex(2),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.savings,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 26,
                    ),
                    onPressed: () => navigationProvider.setSelectedIndex(3),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// A widget that scales in/out from 0..1
