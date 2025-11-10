import 'package:flutter/material.dart';

class ControlsGuideWidget extends StatelessWidget {
  const ControlsGuideWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'CONTROLS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildControlItem('←→', 'Move'),
          _buildControlItem('↓', 'Soft Drop'),
          _buildControlItem('↑ / X', 'Rotate'),
          _buildControlItem('Space', 'Hard Drop'),
          _buildControlItem('C / Shift', 'Hold'),
          _buildControlItem('P / ESC', 'Pause'),
          _buildControlItem('Enter', 'Start'),
        ],
      ),
    );
  }

  Widget _buildControlItem(String key, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white70, width: 1),
            ),
            child: Text(
              key,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            action,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
