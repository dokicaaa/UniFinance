import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:banking4students/models/user.dart';
import 'package:banking4students/pages/friend_profile.dart'; // Or replace with your dedicated user profile page

class RankListPage extends StatelessWidget {
  const RankListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Query all users ordered by their 'rank' field (ascending order)
    return Scaffold(
      appBar: AppBar(title: const Text('Savings Rank List')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .orderBy('rank')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          // Convert Firestore documents into UserModel objects
          List<UserModel> users =
              snapshot.data!.docs
                  .map((doc) => UserModel.fromFirestore(doc))
                  .toList();

          // Use a ListView with a header for the description
          return ListView.builder(
            itemCount: users.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                // Header with a polished description
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "See where you stand! This leaderboard ranks users based on the number of savings goals completed. Keep saving to climb the ranks!",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                );
              }
              final user = users[index - 1];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.profileImageUrl),
                ),
                title: Text("${user.name} ${user.surname}"),
                subtitle: Text("Rank #${user.rank}"),
                onTap: () {
                  // Navigate to the user's profile page. Replace with your dedicated page if available.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => FriendProfilePage(friendUid: user.uid),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
