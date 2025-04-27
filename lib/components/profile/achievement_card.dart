import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AchievementCard extends StatelessWidget {
  final String title;
  final String description;
  final String iconPath;

  const AchievementCard({
    Key? key,
    required this.title,
    required this.description,
    required this.iconPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // SVG Icon on the left
            SvgPicture.asset(
              iconPath,
              width: 60, // Increased size
              height: 60, // Increased size
              placeholderBuilder:
                  (context) =>
                      const CircularProgressIndicator(), // Show a loader while loading SVG
            ),
            const SizedBox(width: 16), // Spacing between icon and text
            // Text on the right
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ), // Spacing between title and description
                  // Description
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
