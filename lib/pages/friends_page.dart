import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:banking4students/models/user.dart';
import 'package:banking4students/providers/database_provider.dart';
import 'package:banking4students/services/auth/auth_service.dart';
import 'package:banking4students/pages/friend_profile.dart'; // Import the friend profile page

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = Provider.of<AuthService>(context).user!.uid;
    final db = Provider.of<DatabaseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddFriendDialog(context, db, currentUserId),
          ),
        ],
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: db.getFriends(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final friends = snapshot.data ?? [];
          if (friends.isEmpty) {
            return const Center(child: Text("No friends yet. Tap + to add!"));
          }

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              return Dismissible(
                key: Key(friend.uid),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text("Remove Friend"),
                          content: const Text(
                            "Are you sure you want to remove this friend?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                "Remove",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                  );
                },
                onDismissed: (direction) async {
                  try {
                    await db.deleteFriend(currentUserId, friend.uid);
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(friend.profileImageUrl),
                  ),
                  title: Text("${friend.name} ${friend.surname}"),
                  subtitle: Text(friend.email),
                  trailing: Text(
                    DateFormat(
                      'MMM dd, yyyy',
                    ).format(friend.createdAt.toDate()),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                FriendProfilePage(friendUid: friend.uid),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddFriendDialog(
    BuildContext context,
    DatabaseProvider db,
    String userId,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Friend'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: "Friend's User ID",
                hintText: "Paste user ID here",
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final friendId = controller.text.trim();
                    if (friendId.isEmpty) return;

                    await db.addFriend(userId, friendId);
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
                child: const Text('Add Friend'),
              ),
            ],
          ),
    );
  }
}
