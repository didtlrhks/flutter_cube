import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'dart:math';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text('Monthly Grass with Horizontal Wheel'),
      ),
      body: GrassGridWithHorizontalWheel(),
    ),
  ));
}

class GrassGridWithHorizontalWheel extends StatefulWidget {
  const GrassGridWithHorizontalWheel({super.key});

  @override
  _GrassGridWithHorizontalWheelState createState() =>
      _GrassGridWithHorizontalWheelState();
}

class _GrassGridWithHorizontalWheelState
    extends State<GrassGridWithHorizontalWheel> {
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

  // 평균 데이터 계산
  double calculateAverage(String key) {
    final total = dummyData.map((data) => data[key]!).reduce((a, b) => a + b);
    return total / dummyData.length;
  }

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
    return Column(
      children: [
        // 잔디 그래프 또는 원형 차트 화면
        Expanded(
          flex: 3,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: selectedIndex == null
                ? _buildGrassGrid() // 잔디 그래프 화면
                : _buildPieChart(), // 원형 차트 화면
          ),
        ),
        // 좌우 휠 방식의 진행도 섹션
        SizedBox(
          height: 200,
          child: PageView(
            controller: PageController(viewportFraction: 0.7), // 중앙 강조 효과
            children: [
              _buildProgressIndicator('운동', calculateAverage('운동')),
              _buildProgressIndicator('식단', calculateAverage('식단')),
              _buildProgressIndicator('건강기능식품', calculateAverage('건강기능식품')),
              _buildProgressIndicator('대체식단', calculateAverage('대체식단')),
            ],
          ),
        ),
      ],
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
                centerSpaceRadius: 50,
                sectionsSpace: 2,
                borderData: FlBorderData(show: false),
                startDegreeOffset: -90,
              ),
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

  // Progress Indicator 생성
  Widget _buildProgressIndicator(String title, double average) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularStepProgressIndicator(
            totalSteps: 100,
            currentStep: (average / maxExerciseValue * 100).toInt(),
            stepSize: 10,
            selectedColor: Colors.green,
            unselectedColor: Colors.grey[300]!,
            padding: 0,
            width: 120,
            height: 120,
            selectedStepSize: 15,
            unselectedStepSize: 10,
            roundedCap: (_, __) => true,
            child: Center(
              child: Text(
                '${(average / maxExerciseValue * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
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
      i++;

      return PieChartSectionData(
        value: entry.value.toDouble(),
        color: color,
        radius: 80,
        title: '${entry.key}\n${percentage.toStringAsFixed(1)}%',
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}
