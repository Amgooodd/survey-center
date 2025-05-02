import 'dart:math';
import 'dart:typed_data';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/rendering.dart';
import '../../widgets/Bottom_bar.dart';

class DataPage extends StatefulWidget {
  const DataPage({super.key});
  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  Map<String, int> departmentCounts = {};
  int totalStudents = 0;
  int totalSurveys = 0;
  bool isLoading = true;
  String? errorMessage;
  List<MapEntry<String, int>> sortedDepartments = [];

  Color getRandomColor() {
    final random = Random();
    return Color.fromARGB(
        255, random.nextInt(200), random.nextInt(200), random.nextInt(200));
  }

  final GlobalKey _screenshotKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final studentsSnapshot =
          await FirebaseFirestore.instance.collection('students').get();
      final surveysSnapshot =
          await FirebaseFirestore.instance.collection('surveys').get();

      departmentCounts.clear();
      totalStudents = 0;
      totalSurveys = surveysSnapshot.size;

      if (studentsSnapshot.docs.isNotEmpty) {
        for (var doc in studentsSnapshot.docs) {
          final data = doc.data();
          final department = data['group'] ?? '';
          departmentCounts[department] =
              (departmentCounts[department] ?? 0) + 1;
          totalStudents++;
        }
      }

      setState(() {
        isLoading = false;
        errorMessage = null;
        sortedDepartments = departmentCounts.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Error fetching data: $e";
      });
    }
  }

  Future<void> _generatePdf() async {
    if (sortedDepartments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No data to export")),
      );
      return;
    }

    try {
      RenderRepaintBoundary boundary = _screenshotKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List imageBytes = byteData!.buffer.asUint8List();

      final pdf = pw.Document();
      final chartImage = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Center(
              child: pw.Text(
                "Student Department Analysis",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Department', 'Count'],
              data: sortedDepartments
                  .map((e) => [e.key, e.value.toString()])
                  .toList(),
            ),
            pw.SizedBox(height: 30),
            pw.Text("Charts:", style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Image(chartImage, width: 300, height: 200),
            ),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      print("PDF error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to generate PDF")),
      );
    }
  }

  Widget buildInfoCard(String title, int count, IconData icon, Color color) {
    return Flexible(
      child: Container(
        margin: const EdgeInsets.all(8),
        child: Card(
          color: color.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return constraints.maxWidth > 200
                    ? Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: color,
                            child: Icon(icon, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize:
                                        constraints.maxWidth > 300 ? 16 : 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "$count",
                                  style: TextStyle(
                                    fontSize:
                                        constraints.maxWidth > 300 ? 24 : 20,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: color,
                            child: Icon(icon, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$count",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }
    if (departmentCounts.isEmpty) {
      return const Center(child: Text("No student data available"));
    }
    final colors = sortedDepartments.map((_) => getRandomColor()).toList();

    return Scaffold(
      appBar: AppBar(
        title:
            Text('Students analytics', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 28, 51, 95),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/firsrforadminn');
          },
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                buildInfoCard(
                  "NUMBER OF STUDENTS",
                  totalStudents,
                  Icons.people,
                  const Color.fromARGB(255, 28, 51, 95),
                ),
                buildInfoCard(
                  "NUMBER OF SURVEYS",
                  totalSurveys,
                  Icons.assignment,
                  Colors.deepPurple,
                ),
                buildInfoCard(
                  "NUMBER OF DEPARTMENTS",
                  departmentCounts.length,
                  Icons.school,
                  Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 30),
            RepaintBoundary(
              key: _screenshotKey,
              child: Column(
                children: [
                  const Text(
                    " DEPARTMENT ANALYSIS",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      const Text(
                        " PIE CHART",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 300,
                        child: PieChart(
                          PieChartData(
                            sections: sortedDepartments.map((entry) {
                              final index = sortedDepartments.indexOf(entry);
                              final percentage =
                                  (entry.value / totalStudents) * 100;
                              return PieChartSectionData(
                                value: entry.value.toDouble(),
                                title:
                                    "${entry.key}\n${percentage.toStringAsFixed(1)}%",
                                color: colors[index],
                                radius: 80,
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Column(
                    children: [
                      const Text(
                        " BAR CHART",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 300,
                        child: BarChart(
                          BarChartData(
                            barGroups: sortedDepartments.map((entry) {
                              final index = sortedDepartments.indexOf(entry);
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.value.toDouble(),
                                    width: 20,
                                    color: colors[index],
                                  ),
                                ],
                              );
                            }).toList(),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, _) {
                                    int index = value.toInt();
                                    if (index < sortedDepartments.length) {
                                      return Text(
                                        sortedDepartments[index].key,
                                        style: const TextStyle(
                                          fontSize: 8,
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                ),
                              ),
                              rightTitles: const AxisTitles(),
                              topTitles: const AxisTitles(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            if (departmentCounts.isNotEmpty) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _generatePdf,
                icon: Icon(Icons.picture_as_pdf, color: Colors.black),
                label: const Text("Export PDF"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 253, 200, 0),
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(anall: true),
    );
  }
}
