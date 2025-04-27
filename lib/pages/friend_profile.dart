import 'package:banking4students/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:banking4students/components/profile/achievement_card.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// FriendProfilePage loads and displays a friend’s profile based on their uid.
class FriendProfilePage extends StatelessWidget {
  final String friendUid;
  const FriendProfilePage({Key? key, required this.friendUid})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("users")
              .doc(friendUid)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        UserModel userData = UserModel.fromFirestore(snapshot.data!);

        return Scaffold(
          appBar: AppBar(
            title: const Text("Friend Profile"),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Profile Image Section (without edit overlay)
                Container(
                  margin: const EdgeInsets.only(top: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 75,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 70,
                          backgroundImage: NetworkImage(
                            userData.profileImageUrl,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Main Content
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Updated Display Name label
                        const Opacity(
                          opacity: 1.0,
                          child: Text(
                            "Display Name",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${userData.name} ${userData.surname}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20), // Reduced spacing here
                        // Friends count and Savings Rank (non-interactive)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "${userData.friendsCount}",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text("Friends"),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "#${userData.rank}",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text("Savings Rank"),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        // Achievements Section
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Achievements",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "See All",
                                style: TextStyle(color: Colors.blueAccent),
                              ),
                            ],
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: staticAchievements.length,
                          itemBuilder: (context, index) {
                            final achievement = staticAchievements[index];
                            final title = achievement['title'] ?? 'No Title';
                            return AchievementCard(
                              title: title,
                              description: achievement['description'] ?? '',
                              iconPath:
                                  achievementIcons[title] ??
                                  'lib/assets/achievements_svgs/default.svg',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Mapping from achievement title to SVG asset path.
final Map<String, String> achievementIcons = {
  "First Step Saver": "lib/assets/achievements_svgs/First_Step_Saver.svg",
  "Goal Getter": "lib/assets/achievements_svgs/Goal_Getter.svg",
  "Challenge Newbie": "lib/assets/achievements_svgs/Challenge_Newbie.svg",
  "Double Down": "lib/assets/achievements_svgs/Double_Down.svg",
  "Month Master": "lib/assets/achievements_svgs/Month_Master.svg",
  "Social Starter": "lib/assets/achievements_svgs/Social_Starter.svg",
};

// Static list of achievements (hardcoded)
final List<Map<String, String>> staticAchievements = [
  {
    "title": "First Step Saver",
    "description": "Completed your first savings goal",
    "icon": "First_Step_Saver.svg",
  },
  {
    "title": "Goal Getter",
    "description": "Completed 5 savings goals",
    "icon": "Goal_Getter.svg",
  },
  {
    "title": "Challenge Newbie",
    "description": "Completed a weekly challenge",
    "icon": "Challenge_Newbie.svg",
  },
  {
    "title": "Double Down",
    "description": "Completed weekly challenges 2 weeks in a row",
    "icon": "Double_Down.svg",
  },
  {
    "title": "Month Master",
    "description": "Completed weekly challenges for 4 consecutive weeks",
    "icon": "Month_Master.svg",
  },
  {
    "title": "Social Starter",
    "description": "Added their first friend",
    "icon": "Social_Starter.svg",
  },
];
