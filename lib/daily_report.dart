import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MaterialApp(
    home: DailyReport(),
  ));
}

class DailyReport extends StatelessWidget {
  const DailyReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Harian'),
      ),
      body: const DailyReportChart(),
    );
  }
}

class DailyReportChart extends StatefulWidget {
  const DailyReportChart({super.key});

  @override
  DailyReportChartState createState() => DailyReportChartState();
}

class DailyReportChartState extends State<DailyReportChart> {
  List<OvertimeData> _overtimeDataList = [];
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchOvertimeData();
  }

  Future<void> _fetchOvertimeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('tb_overtime').get();

      List<OvertimeData> overtimeDataList = querySnapshot.docs
          .map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            DateTime? overtimeDate =
                data['tanggal'] != null ? _parseDate(data['tanggal']) : null;
            int totalHours = _calculateTotalHours(data['totalJam']);

            return OvertimeData(overtimeDate, totalHours);
          })
          .where((data) =>
              data.date != null &&
              data.date!.isAfter(_startDate) &&
              data.date!.isBefore(_endDate))
          .toList();

      setState(() {
        _overtimeDataList = overtimeDataList;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  DateTime? _parseDate(String? dateString) {
    if (dateString == null) return null;
    try {
      List<String> dateParts = dateString.split('-');
      if (dateParts.length >= 3) {
        int year = int.parse(dateParts[0]);
        int month = int.parse(dateParts[1]);
        int day = int.parse(dateParts[2]);
        return DateTime(year, month, day);
      }
      return null;
    } catch (e) {
      debugPrint('Error parsing date: $e');
      return null;
    }
  }

  int _calculateTotalHours(String? totalJam) {
    if (totalJam == null) {
      return 0;
    }

    try {
      List<String> timeParts = totalJam.split(':');
      if (timeParts.length < 2) {
        return 0;
      }

      int hours = int.parse(timeParts[0]);
      int minutes = int.parse(timeParts[1]);

      return hours + (minutes / 60).round();
    } catch (e) {
      debugPrint('Error calculating total hours: $e');
      return 0;
    }
  }

  void _updateDateRange(DateTime startDate, DateTime endDate) {
    setState(() {
      _startDate = startDate;
      _endDate = endDate;
    });

    // Periksa apakah endDate lebih besar dari startDate untuk menghindari rentang tanggal yang tidak valid
    if (endDate.isAfter(startDate)) {
      // Periksa apakah endDate berada di bulan berikutnya
      if (endDate.month > startDate.month || endDate.year > startDate.year) {
        // Atur endDate ke hari terakhir bulan saat ini
        _endDate = DateTime(startDate.year, startDate.month + 1, 0);
      }
      _fetchOvertimeData();
    } else {
      // Tampilkan pesan kesalahan jika rentang tanggal tidak valid
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Rentang Tanggal Tidak Valid'),
          content: const Text('Tanggal berakhir harus setelah tanggal mulai.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            final initialDateRange = DateTimeRange(
              start: _startDate,
              end: _endDate,
            );

            final newDateRange = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              initialDateRange: initialDateRange,
            );

            if (newDateRange != null) {
              _updateDateRange(newDateRange.start, newDateRange.end);
            }
          },
          child: const Text('Pilih Rentang Tanggal'),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _overtimeDataList.isNotEmpty
                  ? _buildChart()
                  : const Center(child: Text('Tidak ada data')),
        ),
      ],
    );
  }

  Widget _buildChart() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SfCartesianChart(
        primaryXAxis: DateTimeAxis(
          dateFormat: DateFormat('yyyy-MM-dd'),
          labelRotation: 45,
          title: const AxisTitle(text: 'Tanggal'),
        ),
        primaryYAxis: const NumericAxis(
          labelFormat: '{value} jam',
          interval: 1,
          title: AxisTitle(text: 'Total Jam'),
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries>[
          ColumnSeries<OvertimeData, DateTime>(
            dataSource: _overtimeDataList,
            xValueMapper: (OvertimeData data, _) => data.date!,
            yValueMapper: (OvertimeData data, _) => data.totalHours,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
  }
}

class OvertimeData {
  final DateTime? date;
  final int totalHours;

  OvertimeData(this.date, this.totalHours);
}
