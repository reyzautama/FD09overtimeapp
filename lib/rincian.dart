import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RincianPage extends StatefulWidget {
  const RincianPage({Key? key}) : super(key: key);

  @override
  _RincianPageState createState() => _RincianPageState();
}

class _RincianPageState extends State<RincianPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _rincianPekerjaanController =
      TextEditingController();
  final TextEditingController _areaPekerjaanController =
      TextEditingController();
  String? _selectedPekerjaan;
  String? _selectedArea;
  List<String> _areas = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rincian'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('tb_rincian').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                  'Tidak ada data. Silakan tambahkan data terlebih dahulu.'),
            );
          }

          // Ambil semua area yang tersedia dari snapshot
          _areas.clear();
          snapshot.data!.docs.forEach((document) {
            final data = document.data() as Map<String, dynamic>;
            final area = data['area_pekerjaan'] as String;
            if (!_areas.contains(area)) {
              _areas.add(area);
            }
          });

          return Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedArea,
                items: _areas.map((area) {
                  return DropdownMenuItem<String>(
                    value: area,
                    child: Text(area),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedArea = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Filter berdasarkan Area',
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Nama Pekerjaan')),
                      DataColumn(label: Text('Area')),
                      DataColumn(label: Text('Rincian')),
                      DataColumn(label: Text('Aksi')),
                    ],
                    rows: _buildRows(context, snapshot.data!.docs),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTambahDialog(context);
        },
        tooltip: 'Tambah Data Rincian Pekerjaan',
        child: const Icon(Icons.add),
      ),
    );
  }

  List<DataRow> _buildRows(
      BuildContext context, List<DocumentSnapshot> documents) {
    // List untuk menyimpan baris yang akan ditampilkan
    List<DataRow> rows = [];

    documents.forEach((document) {
      final data = document.data() as Map<String, dynamic>;
      final namaPekerjaan =
          data['nama_pekerjaan'] != null ? data['nama_pekerjaan'] : '';
      final areaPekerjaan =
          data['area_pekerjaan'] != null ? data['area_pekerjaan'] : '';
      final rincianPekerjaan =
          data['rincian_pekerjaan'] != null ? data['rincian_pekerjaan'] : '';

      // Filter baris berdasarkan area yang dipilih
      if (_selectedArea == null || areaPekerjaan == _selectedArea) {
        rows.add(DataRow(cells: [
          DataCell(Text(namaPekerjaan.toString())),
          DataCell(Text(areaPekerjaan.toString())),
          DataCell(
            SizedBox(
              width: 200,
              child: Text(
                rincianPekerjaan.toString(),
                overflow: TextOverflow.visible,
              ),
            ),
          ),
          DataCell(Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showTambahDialog(context, document);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  await _hapusData(context, document.id);
                },
              ),
            ],
          )),
        ]));
      }
    });

    return rows;
  }

  Future<void> _showTambahDialog(BuildContext context,
      [DocumentSnapshot? document]) async {
    if (document != null) {
      final data = document.data() as Map<String, dynamic>;
      _rincianPekerjaanController.text =
          data['rincian_pekerjaan'] != null ? data['rincian_pekerjaan'] : '';
      _selectedPekerjaan =
          data['nama_pekerjaan'] != null ? data['nama_pekerjaan'] : '';
      // Memperbarui area pekerjaan saat pekerjaan dipilih
      if (_selectedPekerjaan != null) {
        final area = await _getAreaPekerjaan(_selectedPekerjaan!);
        setState(() {
          _selectedArea = area;
          _areaPekerjaanController.text = _selectedArea!;
        });
      }
    } else {
      _rincianPekerjaanController.clear();
      _selectedPekerjaan = null;
      _selectedArea = null;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tambah Data Rincian Pekerjaan'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('tb_pekerjaan').snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Terjadi kesalahan: ${snapshot.error}');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      final List<DropdownMenuItem<String>> namaPekerjaanItems =
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        final Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        return DropdownMenuItem<String>(
                          value: data['nama'] as String,
                          child: Text(data['nama'] as String),
                        );
                      }).toList();

                      return Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedPekerjaan,
                            items: namaPekerjaanItems,
                            onChanged: (String? value) async {
                              setState(() {
                                _selectedPekerjaan = value;
                              });
                              if (_selectedPekerjaan != null) {
                                // Update area_pekerjaan saat nama_pekerjaan dipilih
                                final area = await _getAreaPekerjaan(
                                    _selectedPekerjaan!);
                                setState(() {
                                  _selectedArea = area;
                                  _areaPekerjaanController.text =
                                      _selectedArea!;
                                });
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: 'Nama Pekerjaan',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama pekerjaan tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _areaPekerjaanController,
                            decoration: const InputDecoration(
                              labelText: 'Area Pekerjaan',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  TextFormField(
                    controller: _rincianPekerjaanController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      labelText: 'Rincian Pekerjaan',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Rincian pekerjaan tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _clearControllers();
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (document != null) {
                    await _ubahData(context, document.id);
                  } else {
                    await _tambahData(context);
                  }
                  _clearControllers();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _clearControllers() {
    _rincianPekerjaanController.clear();
    _selectedPekerjaan = null;
    _selectedArea = null;
  }

  Future<String> _getAreaPekerjaan(String pekerjaanNama) async {
    final querySnapshot = await _firestore
        .collection('tb_pekerjaan')
        .where('nama', isEqualTo: pekerjaanNama)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final firstDoc = querySnapshot.docs.first;
      final data = firstDoc.data();
      return data['area'] ??
          ''; // Jika data['area'] null, kembalikan string kosong
    }
    return ''; // Jika querySnapshot kosong
  }

  Future<void> _tambahData(BuildContext context) async {
    try {
      final bool duplikatPekerjaan =
          await _cekDuplikatPekerjaan(_selectedPekerjaan!);
      if (duplikatPekerjaan) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Nama pekerjaan sudah ada. Silakan masukkan nama pekerjaan yang berbeda.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      await _firestore.collection('tb_rincian').add({
        'nama_pekerjaan': _selectedPekerjaan,
        'area_pekerjaan': _selectedArea,
        'rincian_pekerjaan': _rincianPekerjaanController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil ditambahkan'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<bool> _cekDuplikatPekerjaan(String namaPekerjaan) async {
    final querySnapshot = await _firestore
        .collection('tb_pekerjaan')
        .where('nama', isEqualTo: namaPekerjaan)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> _ubahData(BuildContext context, String documentId) async {
    try {
      await _firestore.collection('tb_rincian').doc(documentId).update({
        'rincian_pekerjaan': _rincianPekerjaanController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil diubah'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _hapusData(BuildContext context, String documentId) async {
    try {
      await _firestore.collection('tb_rincian').doc(documentId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil dihapus'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _rincianPekerjaanController.dispose();
    _areaPekerjaanController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkAndCreateInitialDocument();
  }

  Future<void> _checkAndCreateInitialDocument() async {
    final querySnapshot = await _firestore.collection('tb_rincian').get();
    if (querySnapshot.docs.isEmpty) {
      await _firestore.collection('tb_rincian').add({
        'nama_pekerjaan': 'Contoh Pekerjaan',
        'area_pekerjaan': 'Contoh Area',
        'rincian_pekerjaan': 'Contoh Rincian Pekerjaan',
      });
    }
  }
}
