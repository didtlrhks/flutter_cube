import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("3D 격자 큐브")),
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
  // 격자 크기와 초기 높이 상태 저장
  final int rows = 7;
  final int cols = 20;
  late List<List<int>> grid; // 각 격자의 클릭 횟수 저장 (0 ~ 5)

  @override
  void initState() {
    super.initState();
    grid = List.generate(rows, (_) => List.generate(cols, (_) => 0)); // 초기값 0
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => _handleTap(details, context),
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Z축 깊이
          ..rotateX(pi / 4) // X축 기울기
          ..rotateY(-pi / 8), // Y축 기울기
        child: CustomPaint(
          size: Size(600, 400), // 캔버스 크기
          painter: Grass3DPainter(grid),
        ),
      ),
    );
  }

  void _handleTap(TapDownDetails details, BuildContext context) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(details.globalPosition);

    final double cellSize = 30.0; // 각 격자의 크기
    final double spacing = 5.0; // 각 격자 간 간격

    // 격자 좌표 계산
    final int col = (localPosition.dx / (cellSize + spacing)).floor();
    final int row = (localPosition.dy / (cellSize + spacing)).floor();

    if (row >= 0 && row < rows && col >= 0 && col < cols) {
      setState(() {
        grid[row][col] = (grid[row][col] + 1) % 6; // 5를 넘으면 다시 0으로
      });
    }
  }
}

class Grass3DPainter extends CustomPainter {
  final List<List<int>> grid;

  Grass3DPainter(this.grid);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final double cellSize = 30.0; // 각 큐브의 크기
    final double spacing = 5.0; // 큐브 간 간격

    for (int i = 0; i < grid.length; i++) {
      for (int j = 0; j < grid[i].length; j++) {
        final height = grid[i][j] * 15.0; // 클릭 횟수에 따른 높이
        final x = j * (cellSize + spacing); // X 위치
        final y = i * (cellSize + spacing); // Z 위치 (2D 평면에서 Y)

        // 큐브 색상
        paint.color = getColorForIntensity(grid[i][j]);

        // 큐브 그리기
        drawCube(canvas, paint, x, y, cellSize, height);
      }
    }
  }

  void drawCube(Canvas canvas, Paint paint, double x, double y, double size,
      double height) {
    final topColor = paint.color.withOpacity(0.9);
    final frontColor = paint.color.withOpacity(0.8);
    final sideColor = paint.color.withOpacity(0.7);

    // 위쪽 면
    final pathTop = Path()
      ..moveTo(x, y - height)
      ..lineTo(x + size, y - height)
      ..lineTo(x + size - 10, y - height - 10)
      ..lineTo(x - 10, y - height - 10)
      ..close();
    paint.color = topColor;
    canvas.drawPath(pathTop, paint);

    // 앞면
    final pathFront = Path()
      ..moveTo(x, y)
      ..lineTo(x + size, y)
      ..lineTo(x + size, y - height)
      ..lineTo(x, y - height)
      ..close();
    paint.color = frontColor;
    canvas.drawPath(pathFront, paint);

    // 옆면
    final pathSide = Path()
      ..moveTo(x + size, y)
      ..lineTo(x + size - 10, y - 10)
      ..lineTo(x + size - 10, y - height - 10)
      ..lineTo(x + size, y - height)
      ..close();
    paint.color = sideColor;
    canvas.drawPath(pathSide, paint);
  }

  Color getColorForIntensity(int intensity) {
    switch (intensity) {
      case 0:
        return Colors.green.withOpacity(0.3);
      case 1:
        return Colors.green.withOpacity(0.5);
      case 2:
        return Colors.green.withOpacity(0.7);
      case 3:
        return Colors.green.withOpacity(0.9);
      case 4:
        return Colors.green;
      case 5:
        return Colors.red; // 최대 클릭 시 빨간색
      default:
        return Colors.grey;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
