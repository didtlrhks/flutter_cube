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
  static const int rows = 7;
  static const int cols = 10;
  static const int maxHeight = 5;
  static const double cellSize = 30.0;

  // 격자의 높이를 관리하는 상태
  List<List<int>> gridHeights =
      List.generate(rows, (_) => List.filled(cols, 0));

  void increaseHeight(int row, int col) {
    setState(() {
      if (gridHeights[row][col] < maxHeight) {
        gridHeights[row][col]++;
      } else {
        gridHeights[row][col] = 0; // 최대 높이일 경우 다시 0으로 초기화
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 고정된 각도 (라디안으로 변환)
    double rotateX = -61.13 * pi / 180; // X축 각도
    double rotateY = 192.15 * pi / 180; // Y축 각도
    double rotateZ = 125.19 * pi / 180; // Z축 각도

    return GestureDetector(
      onTapDown: (details) {
        // 터치한 위치를 계산하여 격자 좌표를 찾음
        final RenderBox box = context.findRenderObject() as RenderBox;
        final Offset localOffset = box.globalToLocal(details.globalPosition);

        // 터치한 위치를 격자 좌표로 변환
        final double offsetX = localOffset.dx - (box.size.width / 2);
        final double offsetY = localOffset.dy - (box.size.height / 2);

        final int col = (offsetX / cellSize).floor() + cols ~/ 2;
        final int row = (offsetY / cellSize).floor() + rows ~/ 2;

        if (row >= 0 && row < rows && col >= 0 && col < cols) {
          increaseHeight(row, col);
        }
      },
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Z축 깊이
          ..translate(0.0, 0.0, 0.0) // 격자를 화면 중앙에 배치
          ..rotateX(rotateX) // X축 회전
          ..rotateY(rotateY) // Y축 회전
          ..rotateZ(rotateZ), // Z축 회전
        child: CustomPaint(
          size: Size(cols * cellSize, rows * cellSize), // 캔버스 크기
          painter: SquareGridPainter(gridHeights, cellSize), // 상태 전달
        ),
      ),
    );
  }
}

class SquareGridPainter extends CustomPainter {
  final List<List<int>> gridHeights;
  final double cellSize;

  SquareGridPainter(this.gridHeights, this.cellSize);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.0;

    final Paint topPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    final Paint sidePaint = Paint()
      ..color = Colors.green.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final Paint frontPaint = Paint()
      ..color = Colors.green.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < gridHeights.length; i++) {
      for (int j = 0; j < gridHeights[i].length; j++) {
        final double x = j * cellSize;
        final double y = i * cellSize;
        final double cubeHeight = gridHeights[i][j] * 10.0;

        final Offset topLeft = Offset(x, y - cubeHeight);
        final Offset topRight = Offset(x + cellSize, y - cubeHeight);
        final Offset bottomLeft = Offset(x, y);
        final Offset bottomRight = Offset(x + cellSize, y);

        // 큐브의 위쪽 면
        if (gridHeights[i][j] > 0) {
          Path topPath = Path()
            ..moveTo(topLeft.dx, topLeft.dy)
            ..lineTo(topRight.dx, topRight.dy)
            ..lineTo(topRight.dx, topRight.dy + cubeHeight)
            ..lineTo(topLeft.dx, topLeft.dy + cubeHeight)
            ..close();
          canvas.drawPath(topPath, topPaint);

          // 큐브의 앞면
          Path frontPath = Path()
            ..moveTo(bottomLeft.dx, bottomLeft.dy)
            ..lineTo(bottomRight.dx, bottomRight.dy)
            ..lineTo(bottomRight.dx, bottomRight.dy - cubeHeight)
            ..lineTo(bottomLeft.dx, bottomLeft.dy - cubeHeight)
            ..close();
          canvas.drawPath(frontPath, frontPaint);

          // 큐브의 옆면
          Path sidePath = Path()
            ..moveTo(bottomRight.dx, bottomRight.dy)
            ..lineTo(topRight.dx, topRight.dy)
            ..lineTo(topRight.dx, topRight.dy - cubeHeight)
            ..lineTo(bottomRight.dx, bottomRight.dy - cubeHeight)
            ..close();
          canvas.drawPath(sidePath, sidePaint);
        }

        // 격자 외곽선
        canvas.drawLine(bottomLeft, bottomRight, linePaint);
        canvas.drawLine(bottomRight, topRight, linePaint);
        canvas.drawLine(topRight, topLeft, linePaint);
        canvas.drawLine(topLeft, bottomLeft, linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
