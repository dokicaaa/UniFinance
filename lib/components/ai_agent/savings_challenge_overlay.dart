import 'package:flutter/material.dart';

class ChallengeScaleWidget extends StatelessWidget {
  final Animation<double> scaleAnimation;
  final Map<String, dynamic> challenge;
  final VoidCallback onClose;

  const ChallengeScaleWidget({
    Key? key,
    required this.scaleAnimation,
    required this.challenge,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      alignment: Alignment.topRight,
      scale: scaleAnimation,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 260,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: onClose,
                  child: const Icon(Icons.close, size: 20),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "🔥 Weekend Savings Challenge",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                challenge["challenge"] ?? "No challenge available.",
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                "Category: ${challenge["category"] ?? "Unknown"}",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                "Status: Active",
                style: const TextStyle(fontSize: 12, color: Colors.green),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
