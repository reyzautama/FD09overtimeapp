import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PosisiPage extends StatelessWidget {
  final CollectionReference posisiCollection =
      FirebaseFirestore.instance.collection('tb_posisi');
  final CollectionReference areaCollection =
      FirebaseFirestore.instance.collection('tb_area');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Posisi'),
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
          stream: posisiCollection.snapshots(),
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
            // Group positions by area
            Map<String, List<DocumentSnapshot>> groupedPositions = {};
            snapshot.data!.docs.forEach((doc) {
              var posisi = doc.data() as Map<String, dynamic>;
              final area = posisi['area'] ?? '';
              if (!groupedPositions.containsKey(area)) {
                groupedPositions[area] = [];
              }
              groupedPositions[area]!.add(doc);
            });

            return ListView.builder(
              itemCount: groupedPositions.length,
              itemBuilder: (context, index) {
                String area = groupedPositions.keys.elementAt(index);
                List<DocumentSnapshot> positions = groupedPositions[area]!;
                return ExpansionTile(
                  title: Text(
                    'Area: $area',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: positions.map((doc) {
                    var posisi = doc.data() as Map<String, dynamic>;
                    final posisiName = posisi['posisi'] ?? '';
                    final posisiId = doc.id;
                    return ListTile(
                      title: Text('Posisi: $posisiName'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _showEditDialog(context, posisiId, posisiName);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _showDeleteDialog(context, posisiId);
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
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
    TextEditingController posisiController = TextEditingController();
    String? selectedArea;

    List<String> areaList = [];
    await areaCollection.get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        String area = doc['Area'];
        if (!areaList.contains(area)) {
          areaList.add(area);
        }
      });
    });

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Posisi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DropdownButtonFormField(
                value: selectedArea,
                items: areaList.map((String area) {
                  return DropdownMenuItem<String>(
                    value: area,
                    child: Text(area),
                  );
                }).toList(),
                onChanged: (String? value) {
                  selectedArea = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Area',
                ),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: posisiController,
                decoration: const InputDecoration(labelText: 'Posisi'),
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
                String newPosisi = posisiController.text.trim();
                if (newPosisi.isNotEmpty && selectedArea != null) {
                  bool isDuplicate =
                      await _checkDuplicatePosition(selectedArea!, newPosisi);
                  if (isDuplicate) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Posisi dengan nama yang sama sudah ada.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    try {
                      await posisiCollection.add({
                        'posisi': newPosisi,
                        'area': selectedArea,
                      });
                      Navigator.of(context).pop();
                    } catch (e) {
                      print('Error: $e');
                    }
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

  Future<bool> _checkDuplicatePosition(
      String selectedArea, String newPosisi) async {
    QuerySnapshot<Object?> querySnapshot = await posisiCollection
        .where('area', isEqualTo: selectedArea)
        .where('posisi', isEqualTo: newPosisi)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> _showEditDialog(
      BuildContext context, String posisiId, String posisiName) async {
    TextEditingController posisiController =
        TextEditingController(text: posisiName);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Posisi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: posisiController,
                decoration: const InputDecoration(labelText: 'Posisi'),
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
                String updatedPosisi = posisiController.text.trim();
                if (updatedPosisi.isNotEmpty) {
                  try {
                    await posisiCollection.doc(posisiId).update({
                      'posisi': updatedPosisi,
                    });
                    Navigator.of(context).pop();
                  } catch (e) {
                    print('Error: $e');
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

  Future<void> _showDeleteDialog(BuildContext context, String posisiId) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Posisi'),
          content: const Text('Apakah Anda yakin ingin menghapus posisi ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await posisiCollection.doc(posisiId).delete();
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error: $e');
                }
              },
              child: const Text(
                'Hapus',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
