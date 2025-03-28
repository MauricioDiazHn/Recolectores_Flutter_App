import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.name,
    required this.profession,
    required this.versionApp,
  });

  final String? name;
  final String? profession;
  final String? versionApp;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.white24,
        child: Icon(
          CupertinoIcons.person,
          color: Colors.white,
        ),
      ),
      title: Text(
        name ?? "",
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 0.2),
          Text(
            profession ?? "",
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 0.2),
          Text(
            versionApp ?? "",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}