import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("3D 바닥 격자")),
        body: Center(
          child: GitHubGrass3D(),
        ),
      ),
    );
  }
}

class GitHubGrass3D extends StatefulWidget {
  const GitHubGrass3D({super.key});

  @override
  _GitHubGrass3DState createState() => _GitHubGrass3DState();
}

class _GitHubGrass3DState extends State<GitHubGrass3D> {
  double rotateX = -pi / 6; // X축 회전 초기값
  double rotateY = pi / 6; // Y축 회전 초기값
  double rotateZ = 0.0; // Z축 회전 초기값

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          // 드래그한 거리에 따라 회전 각도 조정
          rotateX += details.delta.dy * 0.01; // 세로 드래그 → X축 회전
          rotateY += details.delta.dx * 0.01; // 가로 드래그 → Y축 회전

          // Z축 회전 (예: 두 손가락 드래그 시나 특정 방식으로 설정 가능)
          if (details.delta.dx.abs() > details.delta.dy.abs()) {
            rotateZ += details.delta.dx * 0.005; // Z축 회전 증가
          }
        });
      },
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Z축 깊이
          ..rotateX(rotateX) // X축 회전
          ..rotateY(rotateY) // Y축 회전
          ..rotateZ(rotateZ), // Z축 회전 추가
        child: CustomPaint(
          size: Size(600, 400), // 캔버스 크기
          painter: SquareGridPainter(7, 20), // 7행 20열 격자
        ),
      ),
    );
  }
}

class SquareGridPainter extends CustomPainter {
  final int rows;
  final int cols;

  SquareGridPainter(this.rows, this.cols);

  @override
  void paint(Canvas canvas, Size size) {
    final double cellSize = 30.0; // 각 격자의 크기
    final Paint linePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.0;

    // 바닥 격자 생성
    for (int i = 0; i <= rows; i++) {
      for (int j = 0; j <= cols; j++) {
        // 격자 사각형의 네 꼭짓점 계산
        final double x = j * cellSize; // X 위치
        final double y = i * cellSize; // Y 위치

        final Offset topLeft = Offset(x, y);
        final Offset topRight = Offset(x + cellSize, y);
        final Offset bottomLeft = Offset(x, y + cellSize);
        final Offset bottomRight = Offset(x + cellSize, y + cellSize);

        // 격자 외곽선 그리기
        canvas.drawLine(topLeft, topRight, linePaint); // 위쪽
        canvas.drawLine(topRight, bottomRight, linePaint); // 오른쪽
        canvas.drawLine(bottomRight, bottomLeft, linePaint); // 아래쪽
        canvas.drawLine(bottomLeft, topLeft, linePaint); // 왼쪽
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
