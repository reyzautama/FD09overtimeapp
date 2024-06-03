import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin.dart'; // Import AdminPage from admin.dart

class JabatanPage extends StatelessWidget {
  final CollectionReference jabatanCollection =
      FirebaseFirestore.instance.collection('tb_jabatan');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Jabatan'),
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
          stream: jabatanCollection.snapshots(),
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
            // Menyusun daftar jabatan berdasarkan urutan abjad
            List<DocumentSnapshot> sortedJabatan = snapshot.data!.docs;
            sortedJabatan.sort((a, b) =>
                a['jabatan'].toString().compareTo(b['jabatan'].toString()));
            return ListView.builder(
              itemCount: sortedJabatan.length,
              itemBuilder: (context, index) {
                var jabatan =
                    sortedJabatan[index].data() as Map<String, dynamic>;
                final jabatanName = jabatan['jabatan'] ?? '';
                final jabatanID = sortedJabatan[index].id;
                return Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      jabatanName,
                      style: const TextStyle(fontSize: 18.0),
                    ),
                    subtitle: Text(
                      'ID: $jabatanID',
                      style: const TextStyle(fontSize: 14.0),
                    ),
                    trailing: Wrap(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditDialog(context, jabatanID, jabatanName);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _showDeleteDialog(context, jabatanID);
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
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminPage()),
            );
          },
          icon: const Icon(Icons.arrow_back),
          label: const Text('Kembali ke Admin'),
        ),
      ),
    );
  }

  Future<void> _showTambahDialog(BuildContext context) async {
    TextEditingController jabatanController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Jabatan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: jabatanController,
                decoration: const InputDecoration(labelText: 'Jabatan'),
              ),
            ],
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
                String newJabatan = jabatanController.text.trim();
                if (newJabatan.isNotEmpty) {
                  // Check if the jabatan already exists
                  QuerySnapshot querySnapshot = await jabatanCollection
                      .where('jabatan', isEqualTo: newJabatan)
                      .get();
                  if (querySnapshot.docs.isEmpty) {
                    // Jabatan doesn't exist, add it
                    try {
                      await jabatanCollection.add({'jabatan': newJabatan});
                      Navigator.of(context).pop();
                    } catch (e) {
                      print('Error: $e');
                    }
                  } else {
                    // Jabatan already exists
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Jabatan Sudah Ada'),
                        content: Text('Jabatan "$newJabatan" sudah ada.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
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

  Future<void> _showEditDialog(
      BuildContext context, String jabatanID, String jabatanName) async {
    TextEditingController jabatanController =
        TextEditingController(text: jabatanName);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Jabatan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: jabatanController,
                decoration: const InputDecoration(labelText: 'Jabatan'),
              ),
            ],
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
                String editedJabatan = jabatanController.text.trim();
                if (editedJabatan.isNotEmpty) {
                  // Check if the edited jabatan already exists
                  QuerySnapshot querySnapshot = await jabatanCollection
                      .where('jabatan', isEqualTo: editedJabatan)
                      .get();
                  if (querySnapshot.docs.isEmpty ||
                      (querySnapshot.docs.length == 1 &&
                          querySnapshot.docs.first.id == jabatanID)) {
                    // Jabatan doesn't exist or edited jabatan is the same
                    try {
                      await jabatanCollection.doc(jabatanID).update({
                        'jabatan': editedJabatan,
                      });
                      Navigator.of(context).pop();
                    } catch (e) {
                      print('Error: $e');
                    }
                  } else {
                    // Edited jabatan already exists
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Jabatan Sudah Ada'),
                        content: Text('Jabatan "$editedJabatan" sudah ada.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
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

  Future<void> _showDeleteDialog(BuildContext context, String jabatanID) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Jabatan'),
          content: const Text('Anda yakin ingin menghapus jabatan ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                try {
                  await jabatanCollection.doc(jabatanID).delete();
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error: $e');
                }
              },
              child: const Text('Ya'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tidak'),
            ),
          ],
        );
      },
    );
  }
}
