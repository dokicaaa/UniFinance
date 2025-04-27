import 'dart:io';
import 'package:banking4students/components/logout_button.dart';
import 'package:banking4students/services/auth/auth_service.dart';
import 'package:banking4students/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/database_provider.dart';
import 'package:banking4students/components/profile/achievement_card.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:banking4students/pages/friends_page.dart';
import 'package:banking4students/pages/rank_list.dart'; // Added import for rank_list.dart

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

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _imageFile;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isUploading = true;
      });

      final authService = Provider.of<AuthService>(context, listen: false);
      final User? firebaseUser = authService.user;

      if (firebaseUser != null) {
        String newProfileImageUrl = await authService.uploadProfileImage(
          _imageFile!,
        );
        await FirebaseFirestore.instance
            .collection("users")
            .doc(firebaseUser.uid)
            .update({'profileImageUrl': newProfileImageUrl});
        Provider.of<DatabaseProvider>(
          context,
          listen: false,
        ).updateContributorProfilePicture(firebaseUser.uid, newProfileImageUrl);
      }

      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final User? firebaseUser = authService.user;
    if (firebaseUser == null)
      return const Center(child: CircularProgressIndicator());

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("users")
              .doc(firebaseUser.uid)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        UserModel userData = UserModel.fromFirestore(snapshot.data!);

        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Header Row
                Padding(
                  padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, size: 28),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 0),
                      const Text(
                        "My Profile",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildCurrencySelector(userData, firebaseUser),
                    ],
                  ),
                ),
                // Profile Image Section
                Container(
                  margin: const EdgeInsets.only(top: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
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
                          Transform.translate(
                            offset: const Offset(-10, -10),
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                        // "Copy UID" row
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: userData.uid),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("User ID copied to clipboard"),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  "Copy UID",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.copy, size: 16, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20), // Reduced spacing here
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Friends count navigates to FriendsPage
                            GestureDetector(
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const FriendsPage(),
                                    ),
                                  ),
                              child: Column(
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
                            ),
                            // Savings Rank navigates to RankListPage
                            GestureDetector(
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const RankListPage(),
                                    ),
                                  ),
                              child: Column(
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
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        LogoutButton(
                          onTap: () async {
                            await Provider.of<AuthService>(
                              context,
                              listen: false,
                            ).signOut();
                            Navigator.of(context).pop();
                          },
                          text: "Logout",
                        ),
                        const SizedBox(height: 20),
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
                        // Build achievements using the static list
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

  Widget _buildCurrencySelector(UserModel userData, User firebaseUser) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFD7E4ED), // Updated background color
        borderRadius: BorderRadius.circular(20),
      ),
      child: PopupMenuButton<String>(
        onSelected: (newCurrency) async {
          if (newCurrency != userData.currency) {
            await FirebaseFirestore.instance
                .collection("users")
                .doc(firebaseUser.uid)
                .update({'currency': newCurrency});
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Currency updated to $newCurrency")),
            );
            setState(() {});
          }
        },
        itemBuilder:
            (context) =>
                ['USD', 'MKD', 'EUR'].map((currency) {
                  return PopupMenuItem<String>(
                    value: currency,
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'lib/assets/Flags/$currency.svg',
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(currency),
                      ],
                    ),
                  );
                }).toList(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: Colors.transparent,
              child: SvgPicture.asset(
                'lib/assets/Flags/${userData.currency}.svg',
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              userData.currency,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Icon(Icons.expand_more, size: 20),
          ],
        ),
      ),
    );
  }
}
