import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../savings/savings_currency_converter.dart';
import 'package:provider/provider.dart';
import 'package:banking4students/providers/navigation_provider.dart';
import 'package:banking4students/pages/savings.dart'; // Optional: if using Navigator.push

class DashboardSavingsCarousel extends StatefulWidget {
  const DashboardSavingsCarousel({Key? key}) : super(key: key);

  @override
  _DashboardSavingsCarouselState createState() =>
      _DashboardSavingsCarouselState();
}

class _DashboardSavingsCarouselState extends State<DashboardSavingsCarousel> {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _routeToSavings() {
    // Routing using the NavigationProvider (assuming savings tab is index 3)
    Provider.of<NavigationProvider>(context, listen: false).setSelectedIndex(3);

    // Alternatively, if you use Navigator.push:
    // Navigator.push(context, MaterialPageRoute(builder: (_) => const SavingsPage()));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please log in to view savings goals.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('savings')
              .snapshots(),
      builder: (context, savingsSnapshot) {
        if (savingsSnapshot.hasError) {
          return Center(child: Text('Error: ${savingsSnapshot.error}'));
        }
        if (!savingsSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = savingsSnapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No savings goals available.'));
        }
        // Convert Firestore documents to a list of maps.
        List<Map<String, dynamic>> savings =
            docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

        return StreamBuilder<DocumentSnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.hasError) {
              return Center(child: Text('Error: ${userSnapshot.error}'));
            }
            if (!userSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final userData = userSnapshot.data!.data() as Map<String, dynamic>;
            final String currentCurrency = userData['currency'] ?? 'MKD';

            return SizedBox(
              height:
                  200, // Increased height to accommodate dots inside the card
              child: PageView.builder(
                controller: _pageController,
                itemCount: savings.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final saving = savings[index];
                  return FutureBuilder<Map<String, dynamic>>(
                    future: SavingsCurrencyConverter().convertSavings(saving),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final convertedSaving = snapshot.data!;
                      double limit =
                          (convertedSaving['limit'] as num).toDouble();
                      double contribution =
                          (convertedSaving['contribution'] as num).toDouble();
                      double remaining =
                          (convertedSaving['remaining'] as num).toDouble();
                      double progress =
                          (limit > 0)
                              ? (contribution / limit).clamp(0.0, 1.0)
                              : 0.0;

                      String formatAmount(double value) {
                        if (currentCurrency == "MKD") {
                          return value.toStringAsFixed(0) + " MKD";
                        } else if (currentCurrency == "USD") {
                          return "\$" + value.toStringAsFixed(2);
                        } else if (currentCurrency == "EUR") {
                          return "€" + value.toStringAsFixed(2);
                        } else {
                          return "$currentCurrency " + value.toStringAsFixed(2);
                        }
                      }

                      String limitDisplay = formatAmount(limit);
                      String contributionDisplay = formatAmount(contribution);
                      String remainingDisplay = formatAmount(remaining);
                      String emoji = saving['symbol'] ?? "💰";
                      Color accentColor = Color(
                        saving['accentColor'] ?? 0xFF007AFF,
                      );

                      return InkWell(
                        onTap: _routeToSavings,
                        child: Card(
                          color: Theme.of(context).colorScheme.tertiary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Main content
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: accentColor.withOpacity(
                                        0.2,
                                      ),
                                      child: Text(
                                        emoji,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            saving['title'] ?? 'Unknown',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'Target: $limitDisplay',
                                            style: const TextStyle(
                                              color: Color.fromARGB(
                                                255,
                                                63,
                                                62,
                                                62,
                                              ),
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      contributionDisplay,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Remaining: $remainingDisplay',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color.fromARGB(255, 63, 62, 62),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 8,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${(progress * 100).toStringAsFixed(0)}% saved',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                // Dot indicators inside the card
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(savings.length, (
                                    dotIndex,
                                  ) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      width: _currentPage == dotIndex ? 10 : 8,
                                      height: _currentPage == dotIndex ? 10 : 8,
                                      decoration: BoxDecoration(
                                        color:
                                            _currentPage == dotIndex
                                                ? Colors.blue
                                                : Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
