import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showLogo;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showLogo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showLogo) ...[
          const Icon(Icons.videogame_asset, size: 80, color: Colors.blue),
          const SizedBox(height: 20),
        ],
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: showLogo ? 48 : 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: showLogo ? 4 : 0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.white60),
        ),
      ],
    );
  }
}
