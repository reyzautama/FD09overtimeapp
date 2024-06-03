import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PekerjaanPage extends StatefulWidget {
  @override
  _PekerjaanPageState createState() => _PekerjaanPageState();
}

class _PekerjaanPageState extends State<PekerjaanPage> {
  final TextEditingController _namaController = TextEditingController();
  String _selectedJenis = 'Regular'; // Default value for jenis pekerjaan
  String? _selectedArea; // To store selected area
  String? _selectedFilterArea; // To store selected filter area
  List<String> _jenisOptions = [
    'Regular',
    'Non Regular'
  ]; // Dropdown options for jenis pekerjaan
  List<String> _areaOptions = []; // To store options for area

  bool _sortAscending = true;
  int _sortColumnIndex = 0;
  String _sortColumnName = 'area';

  @override
  void initState() {
    super.initState();
    _fetchAreaOptions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pekerjaan Page'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              // Button to reset filter
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedFilterArea =
                        null; // Clear the selected filter area
                  });
                },
                child: Text('Reset Filter'),
              ),
              SizedBox(width: 16), // Spacer
              // Dropdown filter for area
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedFilterArea,
                  items: _areaOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _selectedFilterArea = value;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Filter Area'),
                ),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('tb_pekerjaan')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                List<DocumentSnapshot> sortedDocs =
                    snapshot.data!.docs.where((doc) {
                  if (_selectedFilterArea != null &&
                      _selectedFilterArea!.isNotEmpty) {
                    return doc['area'] == _selectedFilterArea;
                  } else {
                    return true; // Show all data if no filter area selected
                  }
                }).toList();

                sortedDocs.sort((a, b) {
                  // Sort by Area or Nama
                  if (_sortColumnName == 'area') {
                    final comparison = a['area'].compareTo(b['area']);
                    return _sortAscending ? comparison : -comparison;
                  } else if (_sortColumnName == 'nama') {
                    final comparison = a['nama'].compareTo(b['nama']);
                    return _sortAscending ? comparison : -comparison;
                  } else {
                    return 0; // Default case, no sorting
                  }
                });

                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      sortColumnIndex: _sortColumnIndex,
                      sortAscending: _sortAscending,
                      columns: [
                        DataColumn(
                          label: Text('Nama'),
                          onSort: (columnIndex, ascending) {
                            _sort('nama', ascending);
                          },
                        ),
                        DataColumn(
                          label: Text('Jenis'),
                          onSort: (columnIndex, ascending) {
                            _sort('jenis', ascending);
                          },
                        ),
                        DataColumn(
                          label: Text('Area'),
                          onSort: (columnIndex, ascending) {
                            _sort('area', ascending);
                          },
                        ),
                      ],
                      rows: _buildRows(sortedDocs),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Tambah Data'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _namaController,
                      decoration: InputDecoration(labelText: 'Nama Pekerjaan'),
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedJenis,
                      items: _jenisOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedJenis = value!;
                        });
                      },
                      decoration: InputDecoration(labelText: 'Jenis Pekerjaan'),
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedArea,
                      items: _areaOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedArea = value;
                        });
                      },
                      decoration: InputDecoration(labelText: 'Area Pekerjaan'),
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      _tambahData(
                          _namaController.text, _selectedJenis, _selectedArea!);
                      Navigator.of(context).pop();
                    },
                    child: Text('Tambah'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _sort(String columnName, bool ascending) {
    setState(() {
      _sortAscending = ascending;
      _sortColumnName = columnName;
      switch (columnName) {
        case 'nama':
          _sortColumnIndex = 0;
          break;
        case 'jenis':
          _sortColumnIndex = 1;
          break;
        case 'area':
          _sortColumnIndex = 2;
          break;
      }
    });
  }

  List<DataRow> _buildRows(List<DocumentSnapshot> sortedDocs) {
    return sortedDocs.map((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      return DataRow(
        cells: [
          DataCell(
            TextFormField(
              initialValue: data['nama'],
              onChanged: (value) {
                setState(() {
                  data['nama'] = value;
                });
              },
            ),
          ),
          DataCell(
            DropdownButtonFormField<String>(
              value: data['jenis'],
              items: _jenisOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  data['jenis'] = value!;
                });
              },
            ),
          ),
          DataCell(
            DropdownButtonFormField<String>(
              value: data['area'],
              items: _areaOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  data['area'] = value!;
                });
              },
            ),
          ),
        ],
        onSelectChanged: (isSelected) {
          if (isSelected != null && isSelected) {
            // If row selected, call _editData() method
            _editData(
              document.id,
              data['nama'],
              data['jenis'],
              data['area'],
            );
          }
        },
      );
    }).toList();
  }

  void _tambahData(String nama, String jenis, String area) async {
    if (nama.isNotEmpty && jenis.isNotEmpty && area.isNotEmpty) {
      // Check if the job name already exists
      bool namaExists = await _checkNamaExists(nama);
      if (!namaExists) {
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        try {
          await firestore.collection('tb_pekerjaan').add({
            'nama': nama,
            'jenis': jenis,
            'area': area,
          });
          // Call setState to trigger UI update
          setState(() {
            // Set initial values for controller and jenis and area variables
            _namaController.clear();
            _selectedJenis = 'Regular';
            _selectedArea = null;
          });
        } catch (e) {
          print('Error tambah data: $e');
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Nama pekerjaan sudah ada.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      print('Error: Data tidak lengkap');
    }
  }

  void _fetchAreaOptions() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      QuerySnapshot querySnapshot = await firestore.collection('tb_area').get();
      List<String> areas = [];

      // Add "Semua" option
      areas.add('Semua');

      for (var doc in querySnapshot.docs) {
        if (doc.data() is Map<String, dynamic>) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          if (data.containsKey('Area')) {
            String area = data['Area'].toString();
            areas.add(area);
          }
        }
      }

      areas.sort();

      setState(() {
        _areaOptions = areas;
      });
    } catch (e) {
      print('Error fetching area options: $e');
    }
  }

  Future<bool> _checkNamaExists(String nama) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await firestore
        .collection('tb_pekerjaan')
        .where('nama', isEqualTo: nama)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  void _editData(String docId, String nama, String jenis, String area) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _namaController..text = nama,
                decoration: InputDecoration(labelText: 'Nama Pekerjaan'),
              ),
              DropdownButtonFormField<String>(
                value: jenis,
                items: _jenisOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    jenis = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Jenis Pekerjaan'),
              ),
              DropdownButtonFormField<String>(
                value: area,
                items: _areaOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    area = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Area Pekerjaan'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _updateData(docId, _namaController.text, jenis, area);
                Navigator.of(context).pop();
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _updateData(String docId, String nama, String jenis, String area) async {
    if (nama.isNotEmpty && jenis.isNotEmpty && area.isNotEmpty) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      try {
        await firestore.collection('tb_pekerjaan').doc(docId).update({
          'nama': nama,
          'jenis': jenis,
          'area': area,
        });
        // Call setState to trigger UI update
        setState(() {
          // Set initial values for controller and jenis and area variables
          _namaController.clear();
          _selectedJenis = 'Regular';
          _selectedArea = null;
        });
      } catch (e) {
        print('Error update data: $e');
      }
    } else {
      print('Error: Data tidak lengkap');
    }
  }
}
