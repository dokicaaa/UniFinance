import 'package:banking4students/components/income_and_expenses/edit_income_dialog.dart';
import 'package:banking4students/components/income_and_expenses/income_dialog.dart';
import 'package:banking4students/utility/category_color.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IncomeCard extends StatefulWidget {
  final String userId;
  const IncomeCard({Key? key, required this.userId}) : super(key: key);

  @override
  State<IncomeCard> createState() => _IncomeCardState();
}

class _IncomeCardState extends State<IncomeCard> {
  String _userCurrency = 'USD'; // Default currency if not found

  @override
  void initState() {
    super.initState();
    _fetchUserCurrency();
  }

  // Fetch the user document once to get the currency
  Future<void> _fetchUserCurrency() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        _userCurrency = data['currency'] ?? 'MKD';
      });
    }
  }

  // Show the AddIncomeDialog, passing the user's currency
  void _showAddIncomeDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AddIncomeDialog(
            userId: widget.userId,
            userCurrency: _userCurrency,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top Row: "Income" title + Plus icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Income',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _showAddIncomeDialog,
                  tooltip: 'Add Income',
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Now display the list of incomes in a StreamBuilder
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.userId)
                      .collection('incomes')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('No incomes yet.');
                }

                final docs = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;
                    final source = data['source'] ?? 'Unknown';
                    final amount = data['amount'] ?? 0.0;
                    final frequency = data['frequency'] ?? 'Monthly';

                    return ListTile(
                      leading: SizedBox(
                        height: double.infinity,
                        child: CircleAvatar(
                          radius: 8,
                          backgroundColor: getIncomeColor(source),
                        ),
                      ),
                      title: Text('$source: $amount $_userCurrency'),
                      subtitle: Text('Frequency: $frequency'),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            // Show the edit dialog with pre-filled data.
                            await showDialog(
                              context: context,
                              builder:
                                  (context) => EditIncomeDialog(
                                    userId: widget.userId,
                                    incomeData: data,
                                    docId: docId,
                                  ),
                            );
                          } else if (value == 'delete') {
                            // Delete this income document.
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.userId)
                                .collection('incomes')
                                .doc(docId)
                                .delete();
                          }
                        },
                        itemBuilder:
                            (context) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
