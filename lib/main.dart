import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text('GitHub Grass Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: 30, // 30일 데이터
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7, // 한 줄에 7칸 (일주일)
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
          ),
          itemBuilder: (context, index) {
            // 더미 데이터
            final dummyData = [
              0,
              2,
              5,
              1,
              0,
              3,
              6,
              2,
              0,
              1,
              3,
              5,
              0,
              0,
              6,
              2,
              4,
              1,
              0,
              2,
              5,
              3,
              0,
              1,
              4,
              2,
              5,
              3,
              1,
              0,
            ];

            // 색상 결정 함수
            Color getColor(int value) {
              if (value == 0) return Colors.grey[200]!;
              if (value <= 3) return Colors.green[100]!;
              if (value <= 5) return Colors.green[400]!;
              return Colors.green[700]!;
            }

            return Container(
              decoration: BoxDecoration(
                color: getColor(dummyData[index]),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          },
        ),
      ),
    ),
  ));
}
