import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class ChartDatum {
  final String label;
  final double value;
  final Color color;
  const ChartDatum(this.label, this.value, this.color);
}

class MiniPieChart extends StatelessWidget {
  final List<ChartDatum> data;
  final double pieWidthRatio;
  final double minChartRadius;
  final double maxChartRadius;
  final double maxAreaHeight;
  final double legendRowHeight;

  const MiniPieChart({
    super.key,
    required this.data,
    this.pieWidthRatio = 0.42,
    this.minChartRadius = 78.0,
    this.maxChartRadius = 120.0,
    this.maxAreaHeight = 260.0,
    this.legendRowHeight = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    final total = data.fold<double>(0, (sum, d) => sum + d.value);
    if (total == 0) {
      return const SizedBox.shrink();
    }

    final dataMap = <String, double>{for (final d in data) d.label: d.value};
    final colorList = <Color>[for (final d in data) d.color];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final pieColWidth = width * pieWidthRatio;
        
        final chartR = (pieColWidth * 0.72).clamp(minChartRadius, maxChartRadius);

        final pieAreaH = chartR + 34;
        final legendH = data.length * legendRowHeight;
        final areaH = math.max(pieAreaH, math.min(legendH, maxAreaHeight));

        return SizedBox(
          height: areaH,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: pieColWidth,
                child: Center(
                  child: PieChart(
                    dataMap: dataMap,
                    colorList: colorList,
                    chartType: ChartType.disc,
                    chartRadius: chartR,
                    animationDuration: const Duration(milliseconds: 600),
                    legendOptions: const LegendOptions(showLegends: false),
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValuesInPercentage: true,
                      decimalPlaces: 0,
                      showChartValuesOutside: true,
                      showChartValueBackground: false,
                      chartValueStyle: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final d in data)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: d.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  d.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
