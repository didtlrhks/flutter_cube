import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text('Monthly Grass with Pie Chart'),
      ),
      body: GrassGridWithPieChart(),
    ),
  ));
}

class GrassGridWithPieChart extends StatefulWidget {
  const GrassGridWithPieChart({super.key});

  @override
  _GrassGridWithPieChartState createState() => _GrassGridWithPieChartState();
}

class _GrassGridWithPieChartState extends State<GrassGridWithPieChart> {
  int? selectedIndex;

  // 더미 데이터 (한 달 기준, 30일)
  final List<Map<String, int>> dummyData = List.generate(30, (index) {
    final random = Random();
    return {
      '운동': random.nextInt(35) + 5, // 5 ~ 40
      '식단': random.nextInt(30) + 5, // 5 ~ 35
      '건강기능식품': random.nextInt(25) + 5, // 5 ~ 30
      '대체식단': random.nextInt(20) + 5, // 5 ~ 25
    };
  });

  // 최대 운동 값을 기준으로 비율 계산
  int get maxExerciseValue =>
      dummyData.map((data) => data['운동']!).reduce((a, b) => a > b ? a : b);

  // 색상 결정 함수 (운동 기준 비율로 설정)
  Color getColor(int exerciseValue) {
    final ratio = exerciseValue / maxExerciseValue;
    if (ratio <= 0.25) return const Color(0xFFe0f2f1); // 연한 초록
    if (ratio <= 0.5) return const Color(0xFFb2dfdb); // 밝은 초록
    if (ratio <= 0.75) return const Color(0xFF80cbc4); // 중간 초록
    return const Color(0xFF00796b); // 진한 초록
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: selectedIndex == null
          ? _buildGrassGrid() // 잔디 그래프 화면
          : _buildPieChart(), // 원형 차트 화면
    );
  }

  // 잔디 그래프 화면
  Widget _buildGrassGrid() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        itemCount: dummyData.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7, // 한 줄에 7칸 (한 주)
          crossAxisSpacing: 6.0,
          mainAxisSpacing: 6.0,
        ),
        itemBuilder: (context, index) {
          final data = dummyData[index];
          final exerciseValue = data['운동']!;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: getColor(exerciseValue),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          );
        },
      ),
    );
  }

  // 원형 차트 화면
  Widget _buildPieChart() {
    final data = dummyData[selectedIndex!];

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: PieChart(
              PieChartData(
                sections: _buildPieChartSections(data),
                centerSpaceRadius: 60,
                sectionsSpace: 4,
                borderData: FlBorderData(show: false),
                startDegreeOffset: -90, // 차트 시작 위치 조정
              ),
              swapAnimationDuration: Duration(milliseconds: 800), // 애니메이션 속도
              swapAnimationCurve: Curves.easeInOut, // 애니메이션 커브
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              selectedIndex = null; // 잔디로 돌아가기
            });
          },
          child: const Text(
            '돌아가기',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // PieChart 섹션 빌드
  List<PieChartSectionData> _buildPieChartSections(Map<String, int> data) {
    final total = data.values.reduce((a, b) => a + b);
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.orange,
      Colors.green,
    ];

    int i = 0;
    return data.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      final color = colors[i % colors.length];
      final isSelected = selectedIndex != null && selectedIndex == i;
      i++;

      return PieChartSectionData(
        value: entry.value.toDouble(),
        color: color,
        radius: isSelected ? 100 : 80, // 선택된 섹션 강조
        title: '${entry.key}\n${percentage.toStringAsFixed(1)}%',
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: isSelected
            ? Icon(Icons.star, color: Colors.yellow, size: 24)
            : null, // 선택된 섹션 배지 추가
        badgePositionPercentageOffset: 1.2,
      );
    }).toList();
  }
}
