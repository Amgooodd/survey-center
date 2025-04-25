import 'package:flutter/material.dart';

class ActiveUsersCard extends StatelessWidget {
  final int activeUsers;
  final int totalUsers;

  const ActiveUsersCard({
    super.key,
    required this.activeUsers,
    required this.totalUsers,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      color: Colors.grey,
      surfaceTintColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 160,
        height: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Number of Submits",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$activeUsers",
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: "/$totalUsers",
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.black45,
                    ),
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
