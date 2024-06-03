// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class PenggunaPage extends StatefulWidget {
  const PenggunaPage({super.key});

  @override
  PenggunaPageState createState() => PenggunaPageState();
}

class PenggunaPageState extends State<PenggunaPage> {
  final CollectionReference penggunaCollection =
      FirebaseFirestore.instance.collection('tb_pengguna');
  final CollectionReference jabatanCollection =
      FirebaseFirestore.instance.collection('tb_jabatan');
  final CollectionReference areaCollection =
      FirebaseFirestore.instance.collection('tb_area');
  final CollectionReference posisiCollection =
      FirebaseFirestore.instance.collection('tb_posisi');

  TextEditingController nrpController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController tanggalMasukKerjaController = TextEditingController();
  TextEditingController tanggalLahirController = TextEditingController();
  String? selectedJabatan;
  String? selectedArea;
  String? selectedPosisi1;
  String? selectedPosisi2;
  String? selectedPosisi3;
  String? selectedPosisi4;
  bool _updateMode = false;
  DateTime? selectedTanggalMasukKerja;
  DateTime? selectedTanggalLahir;
  String? _selectedId;

  List<String> jabatanList = [];
  List<String> areaList = [];
  List<String> posisiList = [];

  @override
  void initState() {
    super.initState();
    _updateJabatanList();
    _updateAreaList();
    _updatePosisiList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengguna Page'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Data Pengguna',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              StreamBuilder<QuerySnapshot>(
                stream: penggunaCollection.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: snapshot.data!.docs.map((doc) {
                        return ListTile(
                          title: Text(doc['Nama']),
                          subtitle: Text(doc['Jabatan'] ?? ''),
                          onTap: () {
                            _showUpdateDialog(doc.id, doc);
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _deleteData(doc.id);
                            },
                          ),
                        );
                      }).toList(),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _updateJabatanList() async {
    final snapshot = await jabatanCollection.get();
    setState(() {
      jabatanList =
          snapshot.docs.map((doc) => doc['jabatan'] as String).toSet().toList();
      jabatanList.sort();
    });
  }

  Future<void> _updateAreaList() async {
    final snapshot = await areaCollection.get();
    setState(() {
      areaList =
          snapshot.docs.map((doc) => doc['Area'] as String).toSet().toList();
      areaList.sort();
    });
  }

  Future<void> _updatePosisiList() async {
    final snapshot = await posisiCollection.get();
    setState(() {
      posisiList =
          snapshot.docs.map((doc) => doc['posisi'] as String).toSet().toList();
      posisiList.sort();
    });
  }

  Future<void> _selectDate(
      BuildContext context, bool isTanggalMasukKerja) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isTanggalMasukKerja) {
          selectedTanggalMasukKerja = picked;
          tanggalMasukKerjaController.text =
              DateFormat('yyyy-MM-dd').format(picked);
        } else {
          selectedTanggalLahir = picked;
          tanggalLahirController.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
    }
  }

  Future<bool> _saveData() async {
    if (_validateInput()) {
      try {
        bool nrpExists = await _checkNrpExists(nrpController.text);
        if (_updateMode) {
          if (nrpExists && nrpController.text != nrpController.text) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('NRP sudah digunakan'),
              ),
            );
            return false;
          }
          await penggunaCollection.doc(_selectedId).update({
            'NRP': nrpController.text,
            'Password': passwordController.text,
            'Nama': namaController.text,
            'Jabatan': selectedJabatan,
            'Area': selectedArea,
            'Posisi 1': selectedPosisi1,
            'Posisi 2': selectedPosisi2,
            'Posisi 3': selectedPosisi3,
            'Posisi 4': selectedPosisi4,
            'Tanggal Masuk Kerja':
                DateFormat('yyyy-MM-dd').format(selectedTanggalMasukKerja!),
            'Tanggal Lahir':
                DateFormat('yyyy-MM-dd').format(selectedTanggalLahir!),
          });
        } else {
          if (nrpExists) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('NRP sudah digunakan'),
              ),
            );
            return false;
          }
          await penggunaCollection.add({
            'NRP': nrpController.text,
            'Password': passwordController.text,
            'Nama': namaController.text,
            'Jabatan': selectedJabatan,
            'Area': selectedArea,
            'Posisi 1': selectedPosisi1,
            'Posisi 2': selectedPosisi2,
            'Posisi 3': selectedPosisi3,
            'Posisi 4': selectedPosisi4,
            'Tanggal Masuk Kerja':
                DateFormat('yyyy-MM-dd').format(selectedTanggalMasukKerja!),
            'Tanggal Lahir':
                DateFormat('yyyy-MM-dd').format(selectedTanggalLahir!),
          });
        }
        _clearInputFields();
        return true;
      } catch (e) {
        print('Error saving data: $e');
        return false;
      }
    } else {
      return false;
    }
  }

  bool _validateInput() {
    if (nrpController.text.isEmpty ||
        passwordController.text.isEmpty ||
        namaController.text.isEmpty ||
        selectedJabatan == null ||
        selectedArea == null ||
        selectedPosisi1 == null ||
        selectedPosisi2 == null ||
        selectedPosisi3 == null ||
        selectedPosisi4 == null ||
        selectedTanggalMasukKerja == null ||
        selectedTanggalLahir == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua data'),
        ),
      );
      return false;
    } else if (nrpController.text.length != 4 ||
        int.tryParse(nrpController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NRP harus terdiri dari tepat 4 angka'),
        ),
      );
      return false;
    } else if (selectedTanggalLahir!.isAfter(selectedTanggalMasukKerja!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal masuk kerja harus setelah tanggal lahir'),
        ),
      );
      return false;
    } else if (selectedPosisi1 == selectedPosisi2 ||
        selectedPosisi1 == selectedPosisi3 ||
        selectedPosisi1 == selectedPosisi4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Posisi tidak boleh sama'),
        ),
      );
      return false;
    }
    return true;
  }

  Future<bool> _checkNrpExists(String nrp) async {
    final QuerySnapshot result =
        await penggunaCollection.where('NRP', isEqualTo: nrp).limit(1).get();
    final List<DocumentSnapshot> documents = result.docs;
    return documents.isNotEmpty;
  }

  Future<void> _deleteData(String id) async {
    await penggunaCollection.doc(id).delete();
  }

  Future<void> _showAddDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(_updateMode
                  ? 'Perbarui Data Pengguna'
                  : 'Tambah Data Pengguna'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nrpController,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(4),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'NRP',
                        errorText: nrpController.text.isNotEmpty &&
                                nrpController.text.length != 4
                            ? 'NRP harus terdiri dari tepat 4 angka'
                            : null,
                        errorStyle: const TextStyle(color: Colors.red),
                      ),
                    ),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                    ),
                    TextField(
                      controller: namaController,
                      decoration: const InputDecoration(labelText: 'Nama'),
                    ),
                    DropdownButtonFormField(
                      value: selectedJabatan,
                      items: jabatanList.map((String jabatan) {
                        return DropdownMenuItem<String>(
                          value: jabatan,
                          child: Text(jabatan),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedJabatan = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Jabatan',
                      ),
                    ),
                    DropdownButtonFormField(
                      value: selectedArea,
                      items: areaList.map((String area) {
                        return DropdownMenuItem<String>(
                          value: area,
                          child: Text(area),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedArea = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Area',
                      ),
                    ),
                    DropdownButtonFormField(
                      value: selectedPosisi1,
                      items: posisiList.map((String posisi) {
                        return DropdownMenuItem<String>(
                          value: posisi,
                          child: Text(posisi),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedPosisi1 = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Posisi 1',
                      ),
                    ),
                    DropdownButtonFormField(
                      value: selectedPosisi2,
                      items: posisiList.map((String posisi) {
                        return DropdownMenuItem<String>(
                          value: posisi,
                          child: Text(posisi),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedPosisi2 = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Posisi 2',
                      ),
                    ),
                    DropdownButtonFormField(
                      value: selectedPosisi3,
                      items: posisiList.map((String posisi) {
                        return DropdownMenuItem<String>(
                          value: posisi,
                          child: Text(posisi),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedPosisi3 = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Posisi 3',
                      ),
                    ),
                    DropdownButtonFormField(
                      value: selectedPosisi4,
                      items: posisiList.map((String posisi) {
                        return DropdownMenuItem<String>(
                          value: posisi,
                          child: Text(posisi),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedPosisi4 = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Posisi 4',
                      ),
                    ),
                    TextField(
                      controller: tanggalMasukKerjaController,
                      readOnly: true,
                      onTap: () {
                        _selectDate(context, true);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Masuk Kerja',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                    TextField(
                      controller: tanggalLahirController,
                      readOnly: true,
                      onTap: () {
                        _selectDate(context, false);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Lahir',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _clearInputFields();
                  },
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    bool success = await _saveData();
                    if (success) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Data berhasil disimpan'),
                        ),
                      );
                    } else {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Gagal menyimpan data'),
                        ),
                      );
                    }
                  },
                  child: Text(_updateMode ? 'Perbarui' : 'Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showUpdateDialog(String id, DocumentSnapshot doc) async {
    setState(() {
      _updateMode = true;
      _selectedId = id;
      nrpController.text = doc['NRP'];
      passwordController.text = doc['Password'];
      namaController.text = doc['Nama'];
      selectedJabatan = doc['Jabatan'];
      selectedArea = doc['Area'];
      selectedPosisi1 = doc['Posisi 1'];
      selectedPosisi2 = doc['Posisi 2'];
      selectedPosisi3 = doc['Posisi 3'];
      selectedPosisi4 = doc['Posisi 4'];
      tanggalMasukKerjaController.text = doc['Tanggal Masuk Kerja'];
      tanggalLahirController.text = doc['Tanggal Lahir'];
      selectedTanggalMasukKerja =
          DateFormat('yyyy-MM-dd').parse(doc['Tanggal Masuk Kerja']);
      selectedTanggalLahir =
          DateFormat('yyyy-MM-dd').parse(doc['Tanggal Lahir']);
    });
    await _showAddDialog();
  }

  void _clearInputFields() {
    nrpController.clear();
    passwordController.clear();
    namaController.clear();
    tanggalMasukKerjaController.clear();
    tanggalLahirController.clear();
    selectedJabatan = null;
    selectedArea = null;
    selectedPosisi1 = null;
    selectedPosisi2 = null;
    selectedPosisi3 = null;
    selectedPosisi4 = null;
    selectedTanggalMasukKerja = null;
    selectedTanggalLahir = null;
    _selectedId = null;
    _updateMode = false;
  }
}
