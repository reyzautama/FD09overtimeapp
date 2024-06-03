import 'package:fd9otj/approvalkadepo.dart';
import 'package:fd9otj/approvalkoordinator.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:fd9otj/login_controller_koordinator.dart';
import 'package:fd9otj/login.dart';

class ApprovalPage extends StatelessWidget {
  final LoginControllerKoordinator loginControllerKoordinator =
      Get.put(LoginControllerKoordinator());

  ApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approval'),
        backgroundColor: Colors.blue[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigasi kembali ke halaman login dan hapus LoginController
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
            Get.delete<LoginControllerKoordinator>();
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[200]!, Colors.blue[900]!],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showLoginDialog(
                        context, "Approval Head", "kadepo", "kadepo01");
                  },
                  icon: const Icon(Icons.person),
                  label: const Text('Approval Head'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blue[900],
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showKoordinatorLoginDialog(context);
                  },
                  icon: const Icon(Icons.group),
                  label: const Text('Approval Koordinator'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blue[900],
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoginDialog(BuildContext context, String type, String expectedUser,
      String expectedPassword) {
    String enteredUser = "";
    String enteredPassword = "";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Username'),
                onChanged: (value) {
                  enteredUser = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (value) {
                  enteredPassword = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (enteredUser == expectedUser &&
                    enteredPassword == expectedPassword) {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ApprovalKadepoPage()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Login Gagal. Silakan coba lagi.'),
                  ));
                }
              },
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }

  void _showKoordinatorLoginDialog(BuildContext context) {
    String enteredUser = "";
    String enteredPassword = "";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Koordinator'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'NRP'),
                onChanged: (value) {
                  enteredUser = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (value) {
                  enteredPassword = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('tb_koordinator')
                    .where('nrp', isEqualTo: enteredUser)
                    .get()
                    .then((QuerySnapshot querySnapshot) {
                  if (querySnapshot.docs.isNotEmpty) {
                    var data =
                        querySnapshot.docs.first.data() as Map<String, dynamic>;
                    var password = data['password'] as String?;
                    if (password == enteredPassword) {
                      Navigator.of(context).pop();
                      loginControllerKoordinator
                          .setUserType('Approval Koordinator');
                      loginControllerKoordinator.setUsername(enteredUser);
                      loginControllerKoordinator.getUserInfo(enteredUser);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ApprovalKoordinatorPage(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Password Salah. Silakan coba lagi.'),
                      ));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('NRP tidak ditemukan.'),
                    ));
                  }
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Terjadi kesalahan. Silakan coba lagi.'),
                  ));
                });
              },
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }
}
