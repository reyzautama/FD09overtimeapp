import 'package:fd9otj/approval.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fd9otj/login_controller_koordinator.dart';

class ApprovalKoordinatorPage extends StatefulWidget {
  final LoginControllerKoordinator loginControllerKoordinator =
      Get.put(LoginControllerKoordinator());
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  ApprovalKoordinatorPage({super.key}) {
    loginControllerKoordinator.getUserInfo('nrp');
  }

  @override
  ApprovalKoordinatorPageState createState() => ApprovalKoordinatorPageState();
}

class ApprovalKoordinatorPageState extends State<ApprovalKoordinatorPage> {
  late String selectedApprovalStatus = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ApprovalPage(), // Ganti 'HalamanTujuan' dengan halaman yang ingin Anda navigasikan
              ),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Koordinator:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                      'NRP: ${widget.loginControllerKoordinator.username.value}'),
                  Text(
                    'Nama Koordinator: ${widget.loginControllerKoordinator.namaKoordinator.value}',
                  ),
                ],
              );
            }),
            const SizedBox(height: 20),
            const Text(
              'Filter Status Persetujuan:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildFilterDropDown(),
            const SizedBox(height: 20),
            const Text(
              'Daftar Overtime:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: _buildOvertimeList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropDown() {
    return DropdownButtonFormField(
      value: selectedApprovalStatus,
      items: ['All', 'Pending', 'Approved', 'Rejected']
          .map((String value) => DropdownMenuItem(
                value: value,
                child: Text(value),
              ))
          .toList(),
      onChanged: (String? value) {
        if (value != null) {
          setState(() {
            selectedApprovalStatus = value;
          });
        }
      },
      decoration: const InputDecoration(
        labelText: 'Status Persetujuan',
      ),
    );
  }

  Widget _buildOvertimeList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tb_overtime')
          .where('nrpKoordinator',
              isEqualTo: widget.loginControllerKoordinator.username.value)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          var filteredDocs = snapshot.data!.docs.where((doc) {
            if (selectedApprovalStatus == 'All') {
              return true;
            } else {
              return doc['approvalKoordinator'] == selectedApprovalStatus;
            }
          }).toList();

          return ListView.builder(
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              var overtime = filteredDocs[index].data() as Map<String, dynamic>;
              var documentID = filteredDocs[index].id;
              return OvertimeTile(
                overtime: overtime,
                documentID: documentID,
                scaffoldKey: widget._scaffoldKey,
              );
            },
          );
        } else {
          return const Center(child: Text('Tidak ada data overtime.'));
        }
      },
    );
  }
}

class OvertimeTile extends StatelessWidget {
  final Map<String, dynamic> overtime;
  final String documentID;
  final Set<String> approvalStatusOptions = {'Approved', 'Rejected', 'Pending'};
  final GlobalKey<ScaffoldMessengerState> scaffoldKey;

  final TextEditingController _jamMulaiController;

  OvertimeTile({
    super.key,
    required this.overtime,
    required this.documentID,
    required this.scaffoldKey,
  }) : _jamMulaiController = TextEditingController(text: overtime['jamMulai']);

  // Fungsi untuk mengonversi totalJam menjadi format HH:MM
  String formatTotalJam(double totalJam) {
    int jam = totalJam.toInt();
    int menit = ((totalJam - jam) * 60).round();

    String jamString = jam.toString().padLeft(2, '0');
    String menitString = menit.toString().padLeft(2, '0');

    return '$jamString:$menitString';
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController jamSelesaiController =
        TextEditingController(text: overtime['jamSelesai']);

    String approvalStatus = overtime['approvalKoordinator'];

    return Card(
      child: ExpansionTile(
        title: Text(overtime['nrp'].toString()),
        children: [
          for (var field in fieldOrder)
            ListTile(
              title: Text(field),
              subtitle: Text(overtime[field].toString()),
            ),
          const SizedBox(height: 20),
          TextField(
            controller: _jamMulaiController,
            decoration: const InputDecoration(labelText: 'Jam Mulai'),
          ),
          TextField(
            controller: jamSelesaiController,
            decoration: const InputDecoration(labelText: 'Jam Selesai'),
          ),
          DropdownButtonFormField(
            value: approvalStatus,
            items: approvalStatusOptions.map((String value) {
              return DropdownMenuItem(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? value) {
              if (value != null) {
                approvalStatus = value;
              }
            },
            decoration: const InputDecoration(
              labelText: 'Approval Koordinator',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              List<String> jamMulaiParts = _jamMulaiController.text.split(':');
              List<String> jamSelesaiParts =
                  jamSelesaiController.text.split(':');

              int jamMulai = int.tryParse(jamMulaiParts[0]) ?? 0;
              int menitMulai = int.tryParse(jamMulaiParts[1]) ?? 0;

              int jamSelesai = int.tryParse(jamSelesaiParts[0]) ?? 0;
              int menitSelesai = int.tryParse(jamSelesaiParts[1]) ?? 0;

              DateTime dateTimeMulai =
                  DateTime(2000, 1, 1, jamMulai, menitMulai);
              DateTime dateTimeSelesai =
                  DateTime(2000, 1, 1, jamSelesai, menitSelesai);

              Duration durasi = dateTimeSelesai.difference(dateTimeMulai);
              double totalJam = durasi.inMinutes / 60;

              // Menggunakan fungsi formatTotalJam untuk mengubah totalJam menjadi format HH:MM
              String totalJamFormatted = formatTotalJam(totalJam);

              FirebaseFirestore.instance
                  .collection('tb_overtime')
                  .doc(documentID)
                  .update({
                'jamMulai': _jamMulaiController.text,
                'jamSelesai': jamSelesaiController.text,
                'totalJam': totalJamFormatted,
                'approvalKoordinator': approvalStatus,
              }).then((value) {
                scaffoldKey.currentState?.showSnackBar(
                  const SnackBar(
                    content: Text('Berhasil memperbarui data'),
                    backgroundColor: Colors.green,
                  ),
                );
              }).catchError((error) {
                debugPrint('Failed to update data: $error');
                scaffoldKey.currentState?.showSnackBar(
                  SnackBar(
                    content: Text('Gagal memperbarui data: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              });
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

List<String> fieldOrder = [
  'nama',
  'requestNumber',
  'nrp',
  'area',
  'jabatan',
  'posisi1',
  'posisi2',
  'posisi3',
  'posisi4',
  'namaPekerjaan',
  'rincianPekerjaan',
  'volume',
  'satuanVolume',
  'kategori',
  'keterangan',
  'nrpKoordinator',
  'namaKoordinator',
  'approvalKoordinator',
  'approvalKadepo',
  'tanggal',
  'jamMulai',
  'jamSelesai',
  'totalJam',
];
