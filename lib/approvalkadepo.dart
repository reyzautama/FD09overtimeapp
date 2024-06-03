import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Approval Kadepo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ApprovalKadepoPage(),
    );
  }
}

class ApprovalKadepoPage extends StatefulWidget {
  const ApprovalKadepoPage({super.key});

  @override
  ApprovalKadepoPageState createState() => ApprovalKadepoPageState();
}

class ApprovalKadepoPageState extends State<ApprovalKadepoPage> {
  bool showPending = true;
  bool showApproved = true;
  bool showRejected = true;
  String? selectedNRP; // Changed to nullable type
  String? selectedNama; // Changed to nullable type
  late Future<List<DropdownMenuItem<String>>> nrpDropdownItems;
  late Future<List<DropdownMenuItem<String>>> namaDropdownItems;

  @override
  void initState() {
    super.initState();
    nrpDropdownItems = _buildNRPDropdownItems();
    namaDropdownItems = _buildNamaDropdownItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approval Kadepo'),
        backgroundColor: Colors.blue[900],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tombol reset filter
                  ElevatedButton(
                    onPressed: () {
                      // Reset nilai-nilai filter ke nilai default
                      setState(() {
                        selectedNRP = null;
                        selectedNama = null;
                        showPending = true;
                        showApproved = true;
                        showRejected = true;
                      });
                    },
                    child: const Text('Reset Filter'),
                  ),
                  const SizedBox(height: 16),
                  FilterDropdown(
                    label: 'NRP',
                    value: selectedNRP ?? '', // Set default value
                    items: nrpDropdownItems,
                    onChanged: (value) {
                      setState(() {
                        selectedNRP = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  FilterDropdown(
                    label: 'Nama',
                    value: selectedNama ?? '', // Set default value
                    items: namaDropdownItems,
                    onChanged: (value) {
                      setState(() {
                        selectedNama = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      FilterCheckbox(
                        label: 'Pending',
                        value: showPending,
                        onChanged: (value) {
                          setState(() {
                            showPending = value!;
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      FilterCheckbox(
                        label: 'Approved',
                        value: showApproved,
                        onChanged: (value) {
                          setState(() {
                            showApproved = value!;
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      FilterCheckbox(
                        label: 'Rejected',
                        value: showRejected,
                        onChanged: (value) {
                          setState(() {
                            showRejected = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('tb_overtime')
                    .where('approvalKoordinator', isEqualTo: 'Approved')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.data == null ||
                      snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada data dengan status disetujui.'),
                    );
                  } else {
                    return DataTable(
                      columns: const [
                        DataColumn(label: Text('Nama')),
                        DataColumn(label: Text('Request Number')),
                        DataColumn(label: Text('NRP')),
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
                        DataColumn(label: Text('Approval Koordinator')),
                        DataColumn(label: Text('Approval Kadepo')),
                        DataColumn(label: Text('Tanggal')),
                        DataColumn(label: Text('Jam Mulai')),
                        DataColumn(label: Text('Jam Selesai')),
                        DataColumn(label: Text('Total Jam')),
                        DataColumn(label: Text('Update Status')),
                      ],
                      rows: snapshot.data!.docs.where((document) {
                        Map<String, dynamic> overtimeData =
                            document.data() as Map<String, dynamic>;
                        String currentStatus = overtimeData['approvalKadepo'];

                        return ((selectedNRP == null ||
                                    overtimeData['nrp'] == selectedNRP) &&
                                (selectedNama == null ||
                                    overtimeData['nama'] == selectedNama)) &&
                            ((showPending && currentStatus == 'Pending') ||
                                (showApproved && currentStatus == 'Approved') ||
                                (showRejected && currentStatus == 'Rejected'));
                      }).map<DataRow>((document) {
                        Map<String, dynamic> overtimeData =
                            document.data() as Map<String, dynamic>;
                        String documentID = document.id;
                        String currentStatus = overtimeData['approvalKadepo'];

                        return DataRow(
                          cells: [
                            DataCell(Text(overtimeData['nama'] ?? '')),
                            DataCell(Text(overtimeData['requestNumber'] ?? '')),
                            DataCell(Text(overtimeData['nrp'] ?? '')),
                            DataCell(Text(overtimeData['area'] ?? '')),
                            DataCell(Text(overtimeData['jabatan'] ?? '')),
                            DataCell(Text(overtimeData['posisi1'] ?? '')),
                            DataCell(Text(overtimeData['posisi2'] ?? '')),
                            DataCell(Text(overtimeData['posisi3'] ?? '')),
                            DataCell(Text(overtimeData['posisi4'] ?? '')),
                            DataCell(Text(overtimeData['namaPekerjaan'] ?? '')),
                            DataCell(
                                Text(overtimeData['rincianPekerjaan'] ?? '')),
                            DataCell(Text(
                                (overtimeData['volume'] ?? '').toString())),
                            DataCell(Text(overtimeData['satuanVolume'] ?? '')),
                            DataCell(Text(overtimeData['kategori'] ?? '')),
                            DataCell(Text(overtimeData['keterangan'] ?? '')),
                            DataCell(
                                Text(overtimeData['nrpKoordinator'] ?? '')),
                            DataCell(
                                Text(overtimeData['namaKoordinator'] ?? '')),
                            DataCell(Text(
                                overtimeData['approvalKoordinator'] ?? '')),
                            DataCell(Text(currentStatus)),
                            DataCell(Text(overtimeData['tanggal'] ?? '')),
                            DataCell(Text(overtimeData['jamMulai'] ?? '')),
                            DataCell(Text(overtimeData['jamSelesai'] ?? '')),
                            DataCell(Text(
                                (overtimeData['totalJam'] ?? '').toString())),
                            DataCell(
                              DropdownButtonFormField<String>(
                                value: currentStatus,
                                items: ['Pending', 'Approved', 'Rejected']
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  if (value != null) {
                                    FirebaseFirestore.instance
                                        .collection('tb_overtime')
                                        .doc(documentID)
                                        .update({'approvalKadepo': value}).then(
                                            (_) {
                                      // Handle update success
                                    }).catchError((error) {
                                      // Handle error
                                      debugPrint(
                                          'Failed to update status: $error');
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<DropdownMenuItem<String>>> _buildNRPDropdownItems() async {
    List<DropdownMenuItem<String>> items = [];

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('tb_pengguna').get();
      for (var doc in querySnapshot.docs) {
        String nrp = doc['NRP'] ?? '';
        if (nrp.isNotEmpty) {
          items.add(
            DropdownMenuItem(
              value: nrp,
              child: Text(nrp),
            ),
          );
        }
      }
    } catch (error) {
      debugPrint('Error fetching data: $error');
    }

    return items;
  }

  Future<List<DropdownMenuItem<String>>> _buildNamaDropdownItems() async {
    List<DropdownMenuItem<String>> items = [];

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('tb_pengguna').get();
      for (var doc in querySnapshot.docs) {
        String nama = doc['Nama'] ?? '';
        if (nama.isNotEmpty) {
          items.add(
            DropdownMenuItem(
              value: nama,
              child: Text(nama),
            ),
          );
        }
      }
    } catch (error) {
      debugPrint('Error fetching data: $error');
    }

    return items;
  }
}

class FilterCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const FilterCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}

class FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final Future<List<DropdownMenuItem<String>>> items;
  final ValueChanged<String?> onChanged;

  const FilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        FutureBuilder<List<DropdownMenuItem<String>>>(
          future: items,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return DropdownButtonFormField<String>(
                value: value,
                items: [
                  DropdownMenuItem(
                    value: '',
                    child: Text('Select $label'),
                  ),
                  ...snapshot.data!,
                ],
                onChanged: onChanged,
              );
            }
          },
        ),
      ],
    );
  }
}
