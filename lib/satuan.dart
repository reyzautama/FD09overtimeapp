import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SatuanPage extends StatefulWidget {
  @override
  _SatuanPageState createState() => _SatuanPageState();
}

class _SatuanPageState extends State<SatuanPage> {
  final TextEditingController _satuanController = TextEditingController();
  late CollectionReference _satuanCollection;

  @override
  void initState() {
    super.initState();
    _satuanCollection = FirebaseFirestore.instance.collection('tb_satuan');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Satuan'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _satuanController,
              decoration: InputDecoration(labelText: 'Satuan'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _tambahSatuan,
              child: Text('Tambah'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _satuanCollection.snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return Text('Tidak ada satuan.');
                  }
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic>? data =
                            document.data() as Map<String, dynamic>?;

                        return ListTile(
                          title: Text(data?['satuan'] ?? 'N/A'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _updateSatuan(document),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _hapusSatuan(document),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _tambahSatuan() async {
    String satuan = _satuanController.text.trim();

    if (satuan.isNotEmpty) {
      // Cek apakah sudah ada satuan dengan nama yang sama
      var existingSatuan =
          await _satuanCollection.where('satuan', isEqualTo: satuan).get();

      if (existingSatuan.docs.isEmpty) {
        // Jika tidak ada, tambahkan ke koleksi
        _satuanCollection.add({'satuan': satuan});
        _satuanController.clear();
      } else {
        // Jika ada, tampilkan pesan kesalahan
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Satuan dengan nama yang sama sudah ada.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void _updateSatuan(DocumentSnapshot document) {
    String satuan = _satuanController.text.trim();

    if (satuan.isNotEmpty) {
      document.reference.update({'satuan': satuan});
      _satuanController.clear();
    }
  }

  void _hapusSatuan(DocumentSnapshot document) {
    document.reference.delete();
  }
}
