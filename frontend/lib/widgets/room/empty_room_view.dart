import 'package:flutter/material.dart';

class EmptyRoomView extends StatelessWidget {
  final bool isSearchResult;

  const EmptyRoomView({super.key, this.isSearchResult = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            isSearchResult ? '검색 결과가 없습니다' : '생성된 방이 없습니다',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
