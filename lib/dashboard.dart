import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login.dart'; // Sesuaikan dengan lokasi file login.dart
import 'login_controller.dart'; // Sesuaikan dengan lokasi file login_controller.dart
import 'overtime.dart'; // Sesuaikan dengan lokasi file overtime.dart

class DashboardPage extends StatelessWidget {
  final LoginController loginController = Get.find();

  DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!loginController.loggedIn.value) {
      return LoginPage();
    }

    var userData = loginController.userData;
    var nama = userData['Nama'];
    var nrp = userData['NRP'];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Tambahkan aksi untuk notifikasi di sini
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              // Tambahkan widget Center di sekitar teks
              child: Text(
                'Selamat Datang, $nama!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'NRP: $nrp',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'User: $nrp',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Nama: $nama',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.today),
              title: const Text('Daily Activity'),
              onTap: () {
                // Navigasi ke halaman Daily Activity
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Overtime'),
              onTap: () {
                // Navigasi ke halaman Overtime
                Get.to(() => OvertimePage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                loginController.logout();
                // Navigasi kembali ke halaman login
                Get.offAll(() => LoginPage());
              },
            ),
          ],
        ),
      ),
    );
  }
}
