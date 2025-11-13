import 'package:flutter/material.dart';

class CreateRoomDialog extends StatefulWidget {
  final Function(String title, int maxPlayers, String? password) onCreate;

  const CreateRoomDialog({super.key, required this.onCreate});

  @override
  State<CreateRoomDialog> createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<CreateRoomDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int _maxPlayers = 4;
  bool _hasPassword = false;

  @override
  void dispose() {
    _titleController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: const Text('방 만들기', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 방 제목
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: '방 이름',
                labelStyle: TextStyle(color: Colors.grey[400]),
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
            const SizedBox(height: 16),

            // 최대 인원
            Text(
              '최대 인원: $_maxPlayers명',
              style: TextStyle(color: Colors.grey[400]),
            ),
            Slider(
              value: _maxPlayers.toDouble(),
              min: 2,
              max: 8,
              divisions: 6,
              label: '$_maxPlayers명',
              onChanged: (value) {
                setState(() {
                  _maxPlayers = value.toInt();
                });
              },
            ),
            const SizedBox(height: 16),

            // 비밀번호 설정
            CheckboxListTile(
              value: _hasPassword,
              onChanged: (value) {
                setState(() {
                  _hasPassword = value ?? false;
                  if (!_hasPassword) {
                    _passwordController.clear();
                  }
                });
              },
              title: Text('비밀번호 설정', style: TextStyle(color: Colors.grey[400])),
              contentPadding: EdgeInsets.zero,
            ),

            if (_hasPassword)
              TextField(
                controller: _passwordController,
                style: const TextStyle(color: Colors.white),
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  hintText: '비밀번호를 입력하세요',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.trim().isEmpty) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('방 이름을 입력하세요')));
              return;
            }

            widget.onCreate(
              _titleController.text.trim(),
              _maxPlayers,
              _hasPassword ? _passwordController.text : null,
            );
            Navigator.of(context).pop();
          },
          child: const Text('생성'),
        ),
      ],
    );
  }
}
