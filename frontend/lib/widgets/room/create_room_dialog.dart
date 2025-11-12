import 'package:flutter/material.dart';

class CreateRoomDialog extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onCancel;
  final VoidCallback onCreate;

  const CreateRoomDialog({
    super.key,
    required this.controller,
    required this.onCancel,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: const Text('방 만들기', style: TextStyle(color: Colors.white)),
      content: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: '방 이름을 입력하세요',
          hintStyle: TextStyle(color: Colors.grey[600]),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(onPressed: onCancel, child: const Text('취소')),
        ElevatedButton(onPressed: onCreate, child: const Text('생성')),
      ],
    );
  }
}
