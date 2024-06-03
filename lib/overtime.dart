import 'package:fd9otj/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login.dart';
import 'login_controller.dart';
import 'overtime_add.dart';
import 'overtime_show.dart';

class OvertimePage extends StatelessWidget {
  final LoginController loginController = Get.find();

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
        title: Text(
          'Overtime Page',
          style:
              TextStyle(color: Colors.black87), // Ubah warna teks menjadi hitam
        ),
        backgroundColor:
            Colors.white, // Ubah warna latar belakang menjadi putih
        elevation: 0, // Hilangkan bayangan di bawah appbar
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Icon untuk tombol kembali
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      DashboardPage()), // Navigasi ke DashboardPage
            );
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            color: Colors.blue, // Ubah warna latar belakang menjadi biru
            child: Text(
              'Welcome, $nama ($nrp)',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Ubah warna teks menjadi putih
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // Ubah warna latar belakang menjadi putih
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: OvertimeShowPage(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OvertimeAddPage()),
          );
        },
        backgroundColor: Colors.blue, // Ubah warna background FAB menjadi biru
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
