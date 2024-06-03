import 'package:fd9otj/informasi.dart';
import 'package:fd9otj/jabatan.dart';
import 'package:fd9otj/koordinator.dart';
import 'package:fd9otj/login.dart';
import 'package:fd9otj/pekerjaan.dart';
import 'package:fd9otj/posisi.dart';
import 'package:fd9otj/rincian.dart';
import 'package:fd9otj/satuan.dart';
import 'package:flutter/material.dart';
import 'pengguna.dart';
import 'area.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.lightBlueAccent,
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Page'),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.lightBlueAccent.shade200,
                Colors.lightBlueAccent.shade700,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Selamat datang, Admin!',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        color: Colors.blueAccent,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            gradient: LinearGradient(
                              colors: [
                                Colors.lightBlueAccent.shade100,
                                Colors.lightBlue.shade500,
                                Colors.lightBlue.shade800,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.3, 0.6, 0.9],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildButton(
                                  context,
                                  Icons.people,
                                  'Manajemen Pengguna',
                                  Colors.white,
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PenggunaPage(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                _buildButton(
                                  context,
                                  Icons.business,
                                  'Manajemen Area',
                                  Colors.white,
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const AreaPage(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                _buildButton(
                                  context,
                                  Icons.work,
                                  'Manajemen Jabatan',
                                  Colors.white,
                                  () {
                                    // Tambahkan fungsi navigasi ke halaman Manajemen Jabatan
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => JabatanPage(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                _buildButton(
                                  context,
                                  Icons.location_city,
                                  'Manajemen Posisi',
                                  Colors.white,
                                  () {
                                    // Navigator ke halaman posisi.dart
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PosisiPage(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                _buildButton(
                                  context,
                                  Icons.person,
                                  'Manajemen Pekerjaan',
                                  Colors.white,
                                  () {
                                    // Tambahkan fungsi navigasi ke halaman Manajemen Pekerjaan
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PekerjaanPage(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                _buildButton(
                                  context,
                                  Icons.location_city,
                                  'Manajemen Koordinator',
                                  Colors.white,
                                  () {
                                    // Navigator ke halaman posisi.dart
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => KoordinatorPage(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                _buildButton(
                                  context,
                                  Icons.list_alt,
                                  'Rincian Pekerjaan',
                                  Colors.white,
                                  () {
                                    // Navigator ke halaman posisi.dart
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const RincianPage(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                _buildButton(
                                  context,
                                  Icons.list_alt,
                                  'Manajemen Satuan',
                                  Colors.white,
                                  () {
                                    // Navigator ke halaman posisi.dart
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SatuanPage(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                _buildButton(
                                  context,
                                  Icons.list_alt,
                                  'Manajemen Informasi',
                                  Colors.white,
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const InformasiPage(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        // Tambahkan logika logout di sini jika diperlukan
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        );
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    void Function() onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15),
          textStyle: const TextStyle(fontSize: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
