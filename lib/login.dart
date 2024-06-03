import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart'; // Sesuaikan dengan lokasi file login_controller.dart
import 'approval.dart';
import 'admin.dart';
import 'dashboard.dart'; // Import halaman Dashboard

class LoginPage extends StatelessWidget {
  final LoginController loginController = Get.put(LoginController());
  final TextEditingController nrpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: nrpController,
              decoration: const InputDecoration(
                labelText: 'NRP',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _login(context),
                    icon: const Icon(Icons.login),
                    label: const Text('Login'),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Get.to(() => ApprovalPage()),
                    icon: const Icon(Icons.thumb_up),
                    label: const Text('Approval'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            _buildUserInfoWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoWidget() {
    return Obx(() {
      if (loginController.loggedIn.value) {
        var userData = loginController.userData;
        var nama = userData['Nama'];
        var nrp = userData['NRP'];
        return Column(
          children: [
            Text('Nama: $nama'),
            Text('NRP: $nrp'),
          ],
        );
      } else {
        return const Text('Tidak ada pengguna yang login');
      }
    });
  }

  void _login(BuildContext context) {
    String nrp = nrpController.text;
    String password = passwordController.text;
    if (nrp.isNotEmpty && password.isNotEmpty) {
      loginController.login(nrp, password, onSuccess: (isAdmin) {
        if (isAdmin) {
          Get.offAll(() => AdminPage());
        } else {
          Get.offAll(() => DashboardPage());
        }
      }, onError: (String error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NRP dan password harus diisi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
