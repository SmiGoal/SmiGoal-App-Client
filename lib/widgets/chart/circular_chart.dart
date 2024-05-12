// @dart=2.17
import 'dart:math';

import '../../resources/app_resources.dart';
import 'package:fl_chart/fl_chart.dart';
import './indicator.dart';
import 'package:flutter/material.dart';


class CircularChart extends StatefulWidget {
  CircularChart({
    super.key,
    required this.ham,
    required this.spam
  });

  int ham;
  int spam;

  set setHam(int ham) => ham = ham;
  set setSpam(int spam) => spam = spam;

  int get getHam => ham;
  int get getSpam => spam;

  @override
  State<StatefulWidget> createState() => CircularChartState();
}

class CircularChartState extends State<CircularChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    print("Chart");
    return AspectRatio(
      aspectRatio: 1.3,
      child: Row(
        children: <Widget>[
          const SizedBox(
            height: 18,
          ),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: showingSections(),
                ),
              ),
            ),
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Indicator(
                color: AppColors.contentColorBlue,
                text: '안전한 문자',
                isSquare: true,
              ),
              SizedBox(
                height: 4,
              ),
              Indicator(
                color: AppColors.contentColorRed,
                text: '스미싱 문자',
                isSquare: true,
              ),
              SizedBox(
                height: 18,
              ),
            ],
          ),
          const SizedBox(
            width: 28,
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    int total = widget.ham + widget.spam;
    if (total == 0) {
      return [];  // 총합이 0이면 나눗셈 오류를 방지하기 위해 빈 리스트 반환
    }

    int ham = widget.getHam;
    int spam = widget.getSpam;

    // 값들이 양수인지 확인
    double hamPercentage = max(0, ham) / total * 100;
    double spamPercentage = max(0, spam) / total * 100;

    return List.generate(2, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: AppColors.contentColorBlue,
            value: hamPercentage,
            title: '${hamPercentage.toStringAsFixed(1)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.mainTextColor1,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: AppColors.contentColorRed,
            value: spamPercentage,
            title: '${spamPercentage.toStringAsFixed(1)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.mainTextColor1,
              shadows: shadows,
            ),
          );
        default:
          throw Error();
      }
    });
  }
  // List<PieChartSectionData> showingSections() {
  //   int ham = widget.getHam;
  //   int spam = widget.getSpam;
  //   return List.generate(2, (i) {
  //     final isTouched = i == touchedIndex;
  //     final fontSize = isTouched ? 25.0 : 16.0;
  //     final radius = isTouched ? 60.0 : 50.0;
  //     const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
  //     switch (i) {
  //       case 0:
  //         return PieChartSectionData(
  //           color: AppColors.contentColorBlue,
  //           value: ham/(ham+spam)*100,
  //           title: '${ham/(ham+spam)*100}%',
  //           radius: radius,
  //           titleStyle: TextStyle(
  //             fontSize: fontSize,
  //             fontWeight: FontWeight.bold,
  //             color: AppColors.mainTextColor1,
  //             shadows: shadows,
  //           ),
  //         );
  //       case 1:
  //         return PieChartSectionData(
  //           color: AppColors.contentColorRed,
  //           value: spam/(ham+spam)*100,
  //           title: '${spam/(ham+spam)*100}%',
  //           radius: radius,
  //           titleStyle: TextStyle(
  //             fontSize: fontSize,
  //             fontWeight: FontWeight.bold,
  //             color: AppColors.mainTextColor1,
  //             shadows: shadows,
  //           ),
  //         );
  //       default:
  //         throw Error();
  //     }
  //   });
  // }
}