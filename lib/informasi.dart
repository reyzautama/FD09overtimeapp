import 'package:fd9otj/daily_report.dart';
import 'package:fd9otj/login.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Halaman Kosong',
      theme: ThemeData(
        primaryColor: const Color(0xFF00BFFF), // Warna biru muda Shopee
        scaffoldBackgroundColor:
            const Color(0xFFFFFFFF), // Warna latar belakang putih
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00BFFF), // Warna biru muda untuk app bar
        ),
      ),
      home: const InformasiPage(),
    );
  }
}

class InformasiPage extends StatelessWidget {
  const InformasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Informasi'),
      ),
      drawer: const NavigationDrawer(), // Tambahkan drawer ke halaman informasi
      body: const InformasiBody(),
    );
  }
}

// Widget untuk menampilkan drawer dengan menu navigasi
class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 10),
                Icon(
                  Icons.shopping_bag,
                  color: Colors.white,
                  size: 40,
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.assignment), // Icon untuk laporan harian
            title: Text(
              'Laporan Harian',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            onTap: () {
              Navigator.pop(context); // Menutup drawer sebelum navigasi
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DailyReport()),
              );
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.calendar_today), // Icon untuk laporan bulanan
            title: Text(
              'Laporan Bulanan',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            onTap: () {
              Navigator.pop(context); // Menutup drawer sebelum navigasi
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MonthlyReport()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.event), // Icon untuk laporan tahunan
            title: Text(
              'Laporan Tahunan',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            onTap: () {
              Navigator.pop(context); // Menutup drawer sebelum navigasi
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const YearlyReport()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people), // Icon untuk laporan man power
            title: Text(
              'Laporan Man Power',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            onTap: () {
              Navigator.pop(context); // Menutup drawer sebelum navigasi
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManPowerReport()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.category), // Icon untuk laporan kategori
            title: Text(
              'Laporan Kategori',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            onTap: () {
              Navigator.pop(context); // Menutup drawer sebelum navigasi
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoryReport()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout), // Icon untuk logout
            title: Text(
              'Logout',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            onTap: () {
              Navigator.pop(context); // Menutup drawer sebelum navigasi
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class InformasiBody extends StatefulWidget {
  const InformasiBody({super.key});

  @override
  InformasiBodyState createState() => InformasiBodyState();
}

class InformasiBodyState extends State<InformasiBody> {
  int totalHoursPending = 0;
  int totalHoursApproved = 0;
  int totalHoursRejected = 0;

  @override
  void initState() {
    super.initState();
    _calculateTotalHours();
  }

  Future<void> _calculateTotalHours() async {
    int pendingTotal = 0;
    int approvedTotal = 0;
    int rejectedTotal = 0;

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('tb_overtime').get();

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String totalJam = data['totalJam'] ?? '00:00';
      List<String> timeParts = totalJam.split(':');
      int hours = int.parse(timeParts[0]);
      int minutes = int.parse(timeParts[1]);
      int total = (hours * 60) + minutes;

      // Tentukan kategori dan tambahkan total jam ke kategori yang sesuai
      String approvalStatus = data['approvalKadepo'] ?? '';
      if (approvalStatus == 'Pending') {
        pendingTotal += total;
      } else if (approvalStatus == 'Approved') {
        approvedTotal += total;
      } else if (approvalStatus == 'Rejected') {
        rejectedTotal += total;
      }
    }

    setState(() {
      totalHoursPending = pendingTotal ~/ 60;
      totalHoursApproved = approvedTotal ~/ 60;
      totalHoursRejected = rejectedTotal ~/ 60;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.access_time,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          Text(
            'Total Jam Overtime: ${totalHoursPending + totalHoursApproved + totalHoursRejected} jam',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildOvertimeCategory(
                  'Pending', totalHoursPending, Colors.orange),
              _buildOvertimeCategory(
                  'Approved', totalHoursApproved, Colors.green),
              _buildOvertimeCategory(
                  'Rejected', totalHoursRejected, Colors.red),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 200,
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: Colors.orange,
                    value: totalHoursPending.toDouble(),
                    title: '$totalHoursPending jam',
                    radius: 50,
                  ),
                  PieChartSectionData(
                    color: Colors.green,
                    value: totalHoursApproved.toDouble(),
                    title: '$totalHoursApproved jam',
                    radius: 50,
                  ),
                  PieChartSectionData(
                    color: Colors.red,
                    value: totalHoursRejected.toDouble(),
                    title: '$totalHoursRejected jam',
                    radius: 50,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOvertimeCategory(String category, int totalHours, Color color) {
    return Column(
      children: [
        Text(
          category,
          style: TextStyle(fontSize: 20, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          '$totalHours jam',
          style: TextStyle(fontSize: 18, color: color),
        ),
      ],
    );
  }
}

class MonthlyReport extends StatelessWidget {
  const MonthlyReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Bulanan'),
      ),
      body: const Center(
        child: Text('Ini adalah laporan bulanan'),
      ),
    );
  }
}

class YearlyReport extends StatelessWidget {
  const YearlyReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Tahunan'),
      ),
      body: const Center(
        child: Text('Ini adalah laporan tahunan'),
      ),
    );
  }
}

class ManPowerReport extends StatelessWidget {
  const ManPowerReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Man Power'),
      ),
      body: const Center(
        child: Text('Ini adalah laporan Man Power'),
      ),
    );
  }
}

class CategoryReport extends StatelessWidget {
  const CategoryReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Kategori'),
      ),
      body: const Center(
        child: Text('Ini adalah laporan kategori'),
      ),
    );
  }
}
