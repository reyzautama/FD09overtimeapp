import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'login_controller.dart'; // Import file login_controller.dart

class OvertimeShowPage extends StatefulWidget {
  @override
  _OvertimeShowPageState createState() => _OvertimeShowPageState();
}

class _OvertimeShowPageState extends State<OvertimeShowPage> {
  final LoginController loginController = Get.find();
  DateTime? _selectedDate = DateTime.now(); // Mengubah menjadi DateTime?
  late String _selectedCategory = ''; // Menyimpan kategori yang dipilih

  @override
  Widget build(BuildContext context) {
    var userData = loginController.userData;
    var nrp = userData['NRP'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Overtime Records'),
        automaticallyImplyLeading: false, // Menonaktifkan tombol kembali
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10),
            _buildFilterDateTime(),
            SizedBox(height: 10),
            _buildFilterCategory(), // Menambahkan filter kategori
            SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: _buildQueryStream(nrp),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No overtime records found.'));
                }
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Request Number')),
                      DataColumn(label: Text('Nama')),
                      DataColumn(label: Text('Area')),
                      DataColumn(label: Text('Jabatan')),
                      DataColumn(label: Text('Posisi 1')),
                      DataColumn(label: Text('Posisi 2')),
                      DataColumn(label: Text('Posisi 3')),
                      DataColumn(label: Text('Posisi 4')),
                      DataColumn(label: Text('Nama Pekerjaan')),
                      DataColumn(label: Text('Rincian Pekerjaan')),
                      DataColumn(label: Text('Volume')),
                      DataColumn(label: Text('Satuan Volume')),
                      DataColumn(label: Text('Kategori')),
                      DataColumn(label: Text('Keterangan')),
                      DataColumn(label: Text('NRP Koordinator')),
                      DataColumn(label: Text('Nama Koordinator')),
                      DataColumn(label: Text('Tanggal')),
                      DataColumn(label: Text('Jam Mulai')),
                      DataColumn(label: Text('Jam Selesai')),
                      DataColumn(label: Text('Total Jam')),
                      DataColumn(label: Text('Approval Koordinator')),
                      DataColumn(label: Text('Approval Kadepo')),
                    ],
                    rows: snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic>? data =
                          document.data() as Map<String, dynamic>?;
                      if (data == null) {
                        return DataRow(
                            cells: [DataCell(Text('Data Not Available'))]);
                      }
                      return DataRow(
                        cells: [
                          DataCell(Text(data['requestNumber'] ?? 'N/A')),
                          DataCell(Text(data['nama'] ?? 'N/A')),
                          DataCell(Text(data['area'] ?? 'N/A')),
                          DataCell(Text(data['jabatan'] ?? 'N/A')),
                          DataCell(Text(data['posisi1'] ?? 'N/A')),
                          DataCell(Text(data['posisi2'] ?? 'N/A')),
                          DataCell(Text(data['posisi3'] ?? 'N/A')),
                          DataCell(Text(data['posisi4'] ?? 'N/A')),
                          DataCell(Text(data['namaPekerjaan'] ?? 'N/A')),
                          DataCell(Text(data['rincianPekerjaan'] ?? 'N/A')),
                          DataCell(Text(data['volume'].toString())),
                          DataCell(Text(data['satuanVolume'] ?? 'N/A')),
                          DataCell(Text(data['kategori'] ?? 'N/A')),
                          DataCell(Text(data['keterangan'] ?? 'N/A')),
                          DataCell(Text(data['nrpKoordinator'] ?? 'N/A')),
                          DataCell(Text(data['namaKoordinator'] ?? 'N/A')),
                          DataCell(Text(data['tanggal'] ?? 'N/A')),
                          DataCell(Text(data['jamMulai'] ?? 'N/A')),
                          DataCell(Text(data['jamSelesai'] ?? 'N/A')),
                          DataCell(Text(data['totalJam'] ?? 'N/A')),
                          DataCell(
                            // Menampilkan ikon persetujuan koordinator
                            showCheckIcon(data['approvalKoordinator']),
                          ),
                          DataCell(
                            // Menampilkan ikon persetujuan kadepo
                            showCheckIcon(data['approvalKadepo']),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _buildQueryStream(String nrp) {
    CollectionReference overtimeCollection =
        FirebaseFirestore.instance.collection('tb_overtime');
    Query query = overtimeCollection.where('nrp', isEqualTo: nrp);

    if (_selectedCategory.isNotEmpty) {
      query = query.where('kategori', isEqualTo: _selectedCategory);
    }

    // Menghapus kondisi filter tanggal
    if (_selectedDate != null) {
      query = query.where('tanggal', isEqualTo: _formatDate(_selectedDate!));
    }

    return query.snapshots();
  }

  Widget _buildFilterDateTime() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
              'Tanggal: ${_selectedDate != null ? _formatDate(_selectedDate!) : ''}'),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  _selectDate(context);
                },
                child: Text('Pilih Tanggal'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: _resetFilter, // Panggil fungsi reset filter di sini
                child: Text('Reset Filter'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCategory() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Kategori:'),
          DropdownButton<String>(
            value: _selectedCategory,
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue!;
              });
            },
            items: <String>['', 'Regular', 'Non Regular']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _resetFilter() {
    setState(() {
      _selectedDate = null; // Menghapus filter tanggal
      _selectedCategory = ''; // Reset kategori menjadi kosong
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';
  }

  String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  Widget showCheckIcon(String? approvalStatus) {
    IconData icon;
    Color color;
    String text;

    // Menentukan ikon, warna, dan teks berdasarkan status persetujuan
    if (approvalStatus == 'Pending') {
      icon = Icons.timer;
      color = Colors.yellow;
      text = 'Pending';
    } else if (approvalStatus == 'Approved') {
      icon = Icons.check_circle;
      color = Colors.green;
      text = 'Approved';
    } else if (approvalStatus == 'Rejected') {
      icon = Icons.cancel;
      color = Colors.red;
      text = 'Rejected';
    } else {
      icon = Icons.error;
      color = Colors.grey;
      text = 'I Dont Know';
    }

    return Row(
      children: [
        Icon(icon, color: color),
        SizedBox(width: 4), // Spasi antara ikon dan teks
        Text(text),
      ],
    );
  }
}
