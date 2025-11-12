import 'package:flutter/material.dart';

class RoomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool showClearButton;

  const RoomSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.showClearButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: '방 이름 또는 호스트 검색',
        hintStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
        suffixIcon: showClearButton
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: onClear,
              )
            : null,
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: onChanged,
    );
  }
}
