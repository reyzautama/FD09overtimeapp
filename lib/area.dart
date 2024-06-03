// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AreaPage extends StatelessWidget {
  const AreaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Area Page'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _resetFilter(context);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.lightBlueAccent.shade200,
              Colors.lightBlueAccent.shade700
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const AreaList(),
              ElevatedButton(
                onPressed: () {
                  _resetFilter(context);
                },
                child: const Text('Reset Filter'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAreaDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _resetFilter(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reset Filter'),
      ),
    );
    // Tambahkan logika untuk mereset filter di sini
    // Anda dapat mengatur kembali nilai filter atau mengosongkan state filter
  }

  Future<void> _showAddAreaDialog(BuildContext context) async {
    String? areaName;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          key: const Key('add_area_dialog'),
          title: const Text('Tambah Area'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: const InputDecoration(labelText: 'Nama Area'),
                  onChanged: (value) => areaName = value,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tambah'),
              onPressed: () async {
                if (areaName != null && areaName!.isNotEmpty) {
                  // Validasi nama area tidak boleh sama
                  final isAreaExist = await _checkAreaExist(areaName!);
                  if (!isAreaExist) {
                    await _addAreaToFirestore(areaName!);
                    // ignore: duplicate_ignore
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nama area sudah ada'),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nama area tidak boleh kosong'),
                    ),
                  );
                }
              },
            ),
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _checkAreaExist(String areaName) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('tb_area')
        .where('Area', isEqualTo: areaName)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> _addAreaToFirestore(String areaName) async {
    try {
      final collectionRef = FirebaseFirestore.instance.collection('tb_area');
      await collectionRef.add({
        'Area': areaName,
      });
    } catch (e) {
      debugPrint('Error adding area to Firestore: $e');
    }
  }
}

class AreaList extends StatefulWidget {
  const AreaList({super.key});

  @override
  createState() => AreaListState();
}

class AreaListState extends State<AreaList> {
  final Map<String, bool> _expandStatus = {};

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tb_area').snapshots(),
      builder: (BuildContext? context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        List<DocumentSnapshot> documents = snapshot.data!.docs;

        documents.sort(
            (a, b) => (a['Area'] as String).compareTo(b['Area'] as String));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: documents.length,
          itemBuilder: (BuildContext context, int index) {
            final data = documents[index].data() as Map<String, dynamic>;
            final id = documents[index].id;
            final areaName = data['Area'] ?? '';

            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ExpansionTile(
                initiallyExpanded: _expandStatus[id] ?? false,
                onExpansionChanged: (bool expanded) {
                  setState(() {
                    _expandStatus[id] = expanded;
                  });
                },
                title: Text('$areaName'),
                children: <Widget>[
                  Text('ID: $id'),
                  ButtonBar(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showEditAreaDialog(context, id, areaName);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteAreaFromFirestore(id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showEditAreaDialog(
      BuildContext context, String id, String currentAreaName) async {
    String? newAreaName = currentAreaName;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          key: const Key('edit_area_dialog'),
          title: const Text('Edit Area'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: const InputDecoration(labelText: 'Nama Area'),
                  onChanged: (value) => newAreaName = value,
                  controller: TextEditingController(text: currentAreaName),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Simpan'),
              onPressed: () async {
                if (newAreaName != null && newAreaName!.isNotEmpty) {
                  // Validasi nama area tidak boleh sama
                  final isAreaExist = await _checkAreaExist(newAreaName!);
                  if (!isAreaExist) {
                    await _updateAreaInFirestore(id, newAreaName!);
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nama area sudah ada'),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nama area tidak boleh kosong'),
                    ),
                  );
                }
              },
            ),
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateAreaInFirestore(String id, String newAreaName) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('tb_area').doc(id);
      await docRef.update({'Area': newAreaName});
    } catch (e) {
      debugPrint('Error updating area in Firestore: $e');
    }
  }

  Future<void> _deleteAreaFromFirestore(String id) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('tb_area').doc(id);
      await docRef.delete();
    } catch (e) {
      debugPrint('Error deleting area from Firestore: $e');
    }
  }

  Future<bool> _checkAreaExist(String areaName) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('tb_area')
        .where('Area', isEqualTo: areaName)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }
}

void main() {
  runApp(const AreaPage());
}
