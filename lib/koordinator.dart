import 'package:fd9otj/login.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class KoordinatorPage extends StatelessWidget {
  final CollectionReference koordinatorCollection =
      FirebaseFirestore.instance.collection('tb_koordinator');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Koordinator'),
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
        child: StreamBuilder<QuerySnapshot>(
          stream: koordinatorCollection.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'Tidak ada data.',
                  style: TextStyle(fontSize: 18.0),
                ),
              );
            }
            // Menampilkan daftar koordinator
            List<DocumentSnapshot> koordinators = snapshot.data!.docs;
            return ListView.builder(
              itemCount: koordinators.length,
              itemBuilder: (context, index) {
                var koordinatorData =
                    koordinators[index].data() as Map<String, dynamic>;
                final nrp = koordinatorData['nrp'] ?? '';
                final nama = koordinatorData['nama'] ?? '';
                return Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      '$nrp - $nama',
                      style: const TextStyle(fontSize: 18.0),
                    ),
                    trailing: Wrap(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditDialog(
                              context,
                              koordinators[index].id,
                              nrp,
                              nama,
                              koordinatorData['password'] ?? '',
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _showDeleteDialog(context, koordinators[index].id);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTambahDialog(context);
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> _showTambahDialog(BuildContext context) async {
    TextEditingController nrpController = TextEditingController();
    TextEditingController namaController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Koordinator'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  controller: nrpController,
                  decoration: const InputDecoration(labelText: 'NRP'),
                ),
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(labelText: 'Nama'),
                ),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                String nrp = nrpController.text.trim();
                String nama = namaController.text.trim();
                String password = passwordController.text.trim();
                if (nrp.isNotEmpty && nama.isNotEmpty && password.isNotEmpty) {
                  try {
                    await koordinatorCollection.add({
                      'nrp': nrp,
                      'nama': nama,
                      'password': password,
                    });
                    Navigator.of(context).pop();
                  } catch (e) {
                    print('Error: $e');
                    // Handle error here
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Terjadi kesalahan: $e'),
                      backgroundColor: Colors.red,
                    ));
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(BuildContext context, String koordinatorID,
      String nrp, String nama, String password) async {
    TextEditingController nrpController = TextEditingController(text: nrp);
    TextEditingController namaController = TextEditingController(text: nama);
    TextEditingController passwordController =
        TextEditingController(text: password);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Koordinator'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  controller: nrpController,
                  decoration: const InputDecoration(labelText: 'NRP'),
                ),
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(labelText: 'Nama'),
                ),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                String editedNRP = nrpController.text.trim();
                String editedNama = namaController.text.trim();
                String editedPassword = passwordController.text.trim();
                if (editedNRP.isNotEmpty &&
                    editedNama.isNotEmpty &&
                    editedPassword.isNotEmpty) {
                  try {
                    await koordinatorCollection.doc(koordinatorID).update({
                      'nrp': editedNRP,
                      'nama': editedNama,
                      'password': editedPassword,
                    });
                    Navigator.of(context).pop();
                  } catch (e) {
                    print('Error: $e');
                    // Handle error here
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Terjadi kesalahan: $e'),
                      backgroundColor: Colors.red,
                    ));
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteDialog(
      BuildContext context, String koordinatorID) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Koordinator'),
          content: const Text('Anda yakin ingin menghapus koordinator ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                try {
                  await koordinatorCollection.doc(koordinatorID).delete();
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error: $e');
                  // Handle error here
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Terjadi kesalahan: $e'),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              child: const Text('Ya'),
            ),
            TextButton(
              onPressed: () {
                // Navigasi kembali ke halaman login
                Get.offAll(() => LoginPage());
              },
              child: const Text('Tidak'),
            ),
          ],
        );
      },
    );
  }
}
