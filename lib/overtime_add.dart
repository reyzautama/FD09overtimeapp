import 'package:fd9otj/overtime.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_controller.dart';

class OvertimeAddPage extends StatefulWidget {
  const OvertimeAddPage({super.key});

  @override
  _OvertimeAddPageState createState() => _OvertimeAddPageState();
}

class _OvertimeAddPageState extends State<OvertimeAddPage> {
  final _namaPekerjaanList = <String>[]; // Define _namaPekerjaanList here
  final List<String> _satuanList = [];
  String? _selectedKategori;
  String? _selectedNamaPekerjaan;
  String? _selectedArea;
  List<String> _areaOptions = [];
  late String _totalJam = '';

  final _loginController = Get.find<LoginController>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _requestNumberController =
      TextEditingController();
  final TextEditingController _nrpController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _jabatanController = TextEditingController();
  final TextEditingController _posisi1Controller = TextEditingController();
  final TextEditingController _posisi2Controller = TextEditingController();
  final TextEditingController _posisi3Controller = TextEditingController();
  final TextEditingController _posisi4Controller = TextEditingController();
  final TextEditingController _namaPekerjaanController =
      TextEditingController();
  final TextEditingController _rincianPekerjaanController = TextEditingController(
      text:
          'Isian Rincian Pekerjaan ini otomatis silahkan pilih Nama Pekerjaan terlebih dahulu');
  final TextEditingController _volumeController = TextEditingController();
  final TextEditingController _satuanVolumeController =
      TextEditingController(text: 'pcs');
  final TextEditingController _kategoriController =
      TextEditingController(text: 'Regular');
  final TextEditingController _keteranganController = TextEditingController();
  final TextEditingController _nrpKoordinatorController =
      TextEditingController();
  final TextEditingController _namaKoordinatorController =
      TextEditingController();
  final TextEditingController _approvalKoordinatorController =
      TextEditingController(text: 'Pending');
  final TextEditingController _approvalKadepoController =
      TextEditingController(text: 'Pending');
  final TextEditingController _selectedDateController = TextEditingController();
  final TextEditingController _selectedStartTimeController =
      TextEditingController();
  final TextEditingController _selectedEndTimeController =
      TextEditingController();
  final TextEditingController _totalJamController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAreaOptions();
// Atau inisialisasi dengan nilai default
    _selectedStartTimeController.text = '00:00';
    _selectedEndTimeController.text = '00:00';
    _generateRequestNumber(); // Generate request number when the widget initializes

    _getSatuanData();
    _totalJamController.text = _totalJam;

    // Set data from userData when available and not empty
    if (_loginController.userData.isNotEmpty) {
      var userData = _loginController.userData;
      _nrpController.text = userData['NRP'] ?? '';
      _namaController.text = userData['Nama'] ?? '';
      _areaController.text = userData['Area'] ?? '';
      _jabatanController.text = userData['Jabatan'] ?? '';
      _posisi1Controller.text = userData['Posisi 1'] ?? '';
      _posisi2Controller.text = userData['Posisi 2'] ?? '';
      _posisi3Controller.text = userData['Posisi 3'] ?? '';
      _posisi4Controller.text = userData['Posisi 4'] ?? '';
    } else {
      // Handle case where user data is not available
      // You can show a message or handle it according to your application logic
      print('User data is not available');
    }
  }

  void _initializeUserData() {
    if (_loginController.userData.isNotEmpty) {
      var userData = _loginController.userData;
      _nrpController.text = userData['NRP'] ?? '';
      _namaController.text = userData['Nama'] ?? '';
      // Initialize other controllers with user data if available
    } else {
      print('User data is not available');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Overtime'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _buildTextFormField('Request Number', _requestNumberController,
                  enabled: false),
              _buildTextFormField('NRP', _nrpController, enabled: false),
              _buildTextFormField('Nama', _namaController, enabled: false),
              _buildTextFormField('Jabatan', _jabatanController,
                  enabled: false),
              _buildTextFormField('Posisi 1', _posisi1Controller,
                  enabled: false),
              _buildTextFormField('Posisi 2', _posisi2Controller,
                  enabled: false),
              _buildTextFormField('Posisi 3', _posisi3Controller,
                  enabled: false),
              _buildTextFormField('Posisi 4', _posisi4Controller,
                  enabled: false),
              DropdownButtonFormField<String>(
                value: _selectedArea,
                items: _areaOptions.map((String area) {
                  return DropdownMenuItem<String>(
                    value: area,
                    child: Text(area),
                  );
                }).toList(),
                onChanged: (String? selectedArea) {
                  setState(() {
                    _selectedArea = selectedArea;
                    _namaPekerjaanList
                        .clear(); // Membersihkan daftar Nama Pekerjaan saat area berubah
                    _selectedNamaPekerjaan =
                        null; // Mengatur kembali nilai Nama Pekerjaan menjadi null
                    _kategoriController
                        .clear(); // Membersihkan nilai Kategori juga jika diperlukan
                  });
                  // Panggil method untuk mengambil data rincian pekerjaan berdasarkan area yang dipilih
                  _getRincianPekerjaan(selectedArea);
                },
                decoration: InputDecoration(
                  labelText: 'Area',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an area';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedNamaPekerjaan,
                items: _buildNamaPekerjaanDropdownItems(),
                onChanged: (selectedNamaPekerjaan) {
                  setState(() {
                    _selectedNamaPekerjaan = selectedNamaPekerjaan!;
                    _updateRincianPekerjaan(selectedNamaPekerjaan);
                    _getKategoriValue();
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Nama Pekerjaan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a job name';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                  'Rincian Pekerjaan', _rincianPekerjaanController,
                  enabled: false),
              _buildTextFormField('Volume', _volumeController),
              const SizedBox(height: 15),
              _buildSatuanVolumeDropdown(
                  'Satuan Volume', _satuanVolumeController),
              _buildTextFormField(
                'Kategori',
                _kategoriController,
                defaultText: _selectedKategori ?? '',
                enabled: false,
              ),
              _buildTextFormField('Keterangan', _keteranganController,
                  defaultText: 'Isilah'),
              _buildKoordinatorDropdown(
                  'NRP Koordinator', _nrpKoordinatorController),
              _buildTextFormField(
                  'Nama Koordinator', _namaKoordinatorController),
              _buildTextFormField(
                  'Approval Koordinator', _approvalKoordinatorController),
              _buildTextFormField('Approval Kadepo', _approvalKadepoController),
              _buildDateTimeFormField('Tanggal', _selectedDateController),
              _buildDateTimeFormField(
                  'Jam Mulai', _selectedStartTimeController),
              _buildDateTimeFormField(
                  'Jam Selesai', _selectedEndTimeController),
              _buildTextFormField('Total Jam', _totalJamController),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _saveDataToFirestore();
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(String labelText, TextEditingController controller,
      {bool enabled = true, String? defaultText}) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(labelText: labelText),
      maxLines: null,
      onTap: () {
        // Hapus teks default hanya jika defaultText tidak null, dan controller.text berisi defaultText
        if (defaultText != null && controller.text == defaultText) {
          setState(() {
            controller.clear();
          });
        }
      },
      validator: (value) {
        if (value!.isEmpty && defaultText != null) {
          return 'Please enter $labelText';
        }
        return null;
      },
      onEditingComplete: () {
        // Jika teks kosong, atur kembali teks default saat pengeditan selesai
        if (defaultText != null && controller.text.isEmpty) {
          controller.text = defaultText;
        }
      },
    );
  }

  Widget _buildKategoriDropdown(
      String labelText, TextEditingController controller) {
    return ListTile(
      title: Text(labelText),
      subtitle: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: 'Kategori'),
        value: _selectedKategori,
        onChanged: (String? newValue) {
          setState(() {
            _selectedKategori = newValue!;
          });
        },
        items: <String>['Regular', 'Non Regular'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a category';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateTimeFormField(
    String labelText,
    TextEditingController controller,
  ) {
    return ListTile(
      title: Text(labelText),
      subtitle: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () async {
          DateTime? pickedDate = DateTime.now();
          TimeOfDay? pickedTime = TimeOfDay.now();
          if (labelText.contains('Tanggal')) {
            pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
          } else {
            pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
          }
          if (pickedDate != null && pickedTime != null) {
            final pickedDateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
            final formattedDateTime = DateFormat(
              labelText.contains('Tanggal') ? 'yyyy-MM-dd' : 'HH:mm',
            ).format(pickedDateTime);
            controller.text = formattedDateTime;

            // Panggil method untuk menghitung total jam
            _hitungTotalJam();

            // Jika memilih tanggal, periksa validasi jam mulai
            if (labelText.contains('Tanggal')) {
              await _validateStartTime(pickedDateTime);
            }
          }
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please select $labelText';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildKoordinatorDropdown(
      String labelText, TextEditingController nrpKoordinatorController) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('tb_koordinator').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Menampilkan indikator loading saat data diambil dari Firestore
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text(
              'No data available'); // Menampilkan pesan jika tidak ada data yang ditemukan di Firestore
        }
        final List<String> nrpKoordinatorList = [];
        snapshot.data!.docs.forEach((document) {
          String nrpKoordinator = document.get('nrp');
          nrpKoordinatorList.add(nrpKoordinator);
        });

        return DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: labelText),
          value: _nrpKoordinatorController.text.isNotEmpty
              ? _nrpKoordinatorController.text
              : null,
          items: nrpKoordinatorList.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? selectedNRP) {
            setState(() {
              _nrpKoordinatorController.text = selectedNRP!;
              // Set nama koordinator berdasarkan NRP yang dipilih
              _setNamaKoordinator(selectedNRP);
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a NRP Koordinator';
            }
            return null;
          },
        );
      },
    );
  }

  void _generateRequestNumber() async {
    // Get current date
    final currentDate = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

    // Get the current user's NRP from LoginController
    final nrp = _loginController.nrp;

    // Query Firestore to find the latest request number for today's date
    final CollectionReference overtimeCollection =
        FirebaseFirestore.instance.collection('tb_overtime');
    final querySnapshot = await overtimeCollection
        .where('tanggal', isEqualTo: formattedDate)
        .orderBy('requestNumber', descending: true)
        .limit(1)
        .get();

    // Jika terdapat dokumen dengan request number untuk tanggal hari ini
    if (querySnapshot.docs.isNotEmpty) {
      final latestRequestNumber = querySnapshot.docs.first['requestNumber'];
      final latestNumber = int.parse(latestRequestNumber.split('-').last);
      final newNumber = (latestNumber + 1).toString().padLeft(2, '0');
      final newRequestNumber =
          'FD09-$nrp-${formattedDate.replaceAll('-', '')}-$newNumber';
      _requestNumberController.text = newRequestNumber;
    } else {
      // Jika tidak ada request number untuk tanggal hari ini, mulai dengan nomor '01'
      final newRequestNumber =
          'FD09-$nrp-${formattedDate.replaceAll('-', '')}-01';
      _requestNumberController.text = newRequestNumber;
    }
  }

  Future<void> _saveDataToFirestore() async {
    final CollectionReference overtimeCollection =
        FirebaseFirestore.instance.collection('tb_overtime');
    try {
      await overtimeCollection.add({
        'requestNumber': _requestNumberController.text,
        'nrp': _nrpController.text,
        'nama': _namaController.text,
        'area': _areaController.text,
        'jabatan': _jabatanController.text,
        'posisi1': _posisi1Controller.text,
        'posisi2': _posisi2Controller.text,
        'posisi3': _posisi3Controller.text,
        'posisi4': _posisi4Controller.text,
        'namaPekerjaan': _selectedNamaPekerjaan ?? '',
        'rincianPekerjaan': _rincianPekerjaanController.text,
        'volume': int.tryParse(_volumeController.text) ?? 0,
        'satuanVolume': _satuanVolumeController.text,
        'kategori': _selectedKategori ?? '',
        'keterangan': _keteranganController.text,
        'nrpKoordinator': _nrpKoordinatorController.text,
        'namaKoordinator': _namaKoordinatorController.text,
        'approvalKoordinator': _approvalKoordinatorController.text,
        'approvalKadepo': _approvalKadepoController.text,
        'tanggal': _selectedDateController.text,
        'jamMulai': _selectedStartTimeController.text,
        'jamSelesai': _selectedEndTimeController.text,
        'totalJam': _totalJamController.text,
      });

      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Data added to Firestore successfully!'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Clear input fields
                  _nrpController.clear();
                  _namaController.clear();
                  _areaController.clear();
                  _jabatanController.clear();
                  _posisi1Controller.clear();
                  _posisi2Controller.clear();
                  _posisi3Controller.clear();
                  _posisi4Controller.clear();
                  _namaPekerjaanController.clear();
                  _rincianPekerjaanController.clear();
                  _volumeController.clear();
                  _satuanVolumeController.clear();
                  _kategoriController.clear();
                  _keteranganController.clear();
                  _nrpKoordinatorController.clear();
                  _namaKoordinatorController.clear();
                  _approvalKoordinatorController.clear();
                  _approvalKadepoController.clear();
                  _selectedDateController.clear();
                  _selectedStartTimeController.clear();
                  _selectedEndTimeController.clear();
                  _totalJamController.clear();
                  // Other actions after successful data addition
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OvertimePage()),
                  );
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );

      // Other actions after successful data addition
      // For example: Navigate to another screen
      // Navigator.push(context, MaterialPageRoute(builder: (context) => NextScreen()));
    } catch (error) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred while adding data to Firestore.'),
            actions: <Widget>[
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
  }

  void _getRincianPekerjaan(String? selectedArea) {
    final CollectionReference rincianPekerjaanCollection =
        FirebaseFirestore.instance.collection('tb_pekerjaan');

    setState(() {
      _namaPekerjaanList
          .clear(); // Membersihkan daftar sebelum menambahkan nilai baru
    });

    rincianPekerjaanCollection
        .where('area', isEqualTo: selectedArea)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        if (document.exists) {
          String namaPekerjaan = document.get('nama') ?? '';
          if (namaPekerjaan.isNotEmpty) {
            setState(() {
              if (!_namaPekerjaanList.contains(namaPekerjaan)) {
                _namaPekerjaanList.add(namaPekerjaan);
              }
            });
          }
        }
      });
    }).catchError((error) {
      print('Error getting job details data: $error');
      // Handle error if necessary
    });
  }

  void _updateRincianPekerjaan(String selectedNamaPekerjaan) {
    setState(() {
      _selectedNamaPekerjaan =
          selectedNamaPekerjaan; // Update selectedNamaPekerjaan
      _namaPekerjaanController.text =
          selectedNamaPekerjaan; // Update _namaPekerjaanController.text
    });

    // Access Firestore collection
    final CollectionReference rincianPekerjaanCollection =
        FirebaseFirestore.instance.collection('tb_rincian');

    // Query Firestore to get rincian pekerjaan data based on selectedNamaPekerjaan
    rincianPekerjaanCollection
        .where('nama_pekerjaan', isEqualTo: selectedNamaPekerjaan)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        for (var document in querySnapshot.docs) {
          // Get rincian pekerjaan data and update the UI
          setState(() {
            _rincianPekerjaanController.text =
                document.get('rincian_pekerjaan') ?? '';
            // You can update other fields similarly if needed
          });
        }
      } else {
        // Jika rincian pekerjaan tidak ditemukan, atur teks default
        setState(() {
          _rincianPekerjaanController.text =
              'Detail Rincian belum di deklarasikan';
        });
      }
    }).catchError((error) {
      print('Error updating rincian pekerjaan: $error');
      // Handle error if necessary
    });
  }

  void _setNamaKoordinator(String selectedNRP) {
    final CollectionReference koordinatorCollection =
        FirebaseFirestore.instance.collection('tb_koordinator');

    koordinatorCollection
        .where('nrp', isEqualTo: selectedNRP)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        String namaKoordinator = document.get('nama') ?? '';
        _namaKoordinatorController.text = namaKoordinator;
      });
    }).catchError((error) {
      print('Error getting nama koordinator: $error');
      // Handle error if necessary
    });
  }

  void _hitungTotalJam() {
    final mulai = _selectedStartTimeController.text.split(':');
    final mulaiJam = int.parse(mulai[0]);
    final mulaiMenit = int.parse(mulai[1]);

    final selesai = _selectedEndTimeController.text.split(':');
    final selesaiJam = int.parse(selesai[0]);
    final selesaiMenit = int.parse(selesai[1]);

    final selisihMenit =
        (selesaiJam * 60 + selesaiMenit) - (mulaiJam * 60 + mulaiMenit);

    final jam = selisihMenit ~/ 60;
    final menit = selisihMenit % 60;

    final formattedTotalJam =
        '${jam.toString().padLeft(2, '0')}:${menit.toString().padLeft(2, '0')}';

    _totalJamController.text = formattedTotalJam;
  }

  void _getSatuanData() {
    FirebaseFirestore.instance
        .collection('tb_satuan')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        String satuan = document.get('satuan');
        setState(() {
          _satuanList.add(satuan);
        });
      });
    }).catchError((error) {
      print('Error getting satuan data: $error');
      // Handle error if necessary
    });
  }

  Widget _buildSatuanVolumeDropdown(
      String labelText, TextEditingController controller) {
    return DropdownButtonFormField<String>(
      value: _satuanList.isNotEmpty ? _satuanList[0] : null,
      items: _satuanList.map((satuan) {
        return DropdownMenuItem(
          value: satuan,
          child: Text(satuan),
        );
      }).toList(),
      onChanged: (selectedSatuan) {
        setState(() {
          controller.text = selectedSatuan!;
        });
      },
      decoration: const InputDecoration(
        labelText: 'Satuan Volume',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a unit';
        }
        return null;
      },
    );
  }

  Future<void> _validateStartTime(DateTime selectedDate) async {
    final selectedDateString = DateFormat('yyyy-MM-dd').format(selectedDate);

    final CollectionReference overtimeCollection =
        FirebaseFirestore.instance.collection('tb_overtime');

    final querySnapshot = await overtimeCollection
        .where('tanggal', isEqualTo: selectedDateString)
        .where('nrp',
            isEqualTo:
                _nrpController.text) // Tambahkan kondisi untuk memeriksa NRP
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final lastOvertimeDoc = querySnapshot.docs.last;
      if (lastOvertimeDoc.exists) {
        final lastOvertimeData = lastOvertimeDoc.data() as Map<String, dynamic>;
        final lastEndTimeString = lastOvertimeData['jamSelesai'] as String;
        final lastEndTime = DateFormat('HH:mm').parse(lastEndTimeString);

        final selectedStartTimeString = _selectedStartTimeController.text;
        final selectedStartTime =
            DateFormat('HH:mm').parse(selectedStartTimeString);

        if (selectedStartTime.isBefore(lastEndTime)) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Invalid Start Time'),
                content: Text(
                    'The selected start time cannot be before the end time of the previous overtime on the same date.'),
                actions: <Widget>[
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
          _selectedStartTimeController.text =
              DateFormat('HH:mm').format(lastEndTime);
        }
      }
    }
    _hitungTotalJam();
  }

  Future<void> _fetchAreaOptions() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('tb_area').get();
      if (querySnapshot.docs.isNotEmpty) {
        final List<String> areas = [];
        querySnapshot.docs.forEach((doc) {
          final area = doc['Area'] as String?;
          if (area != null && !areas.contains(area)) {
            areas.add(area);
          }
        });
        setState(() {
          _areaOptions = areas;
          _selectedArea = _areaOptions.isNotEmpty ? _areaOptions[0] : null;
        });
        // Panggil method untuk mengambil data rincian pekerjaan berdasarkan area yang dipilih
        _getRincianPekerjaan(_selectedArea);
      }
    } catch (error) {
      print('Error fetching area options: $error');
      // Handle error if necessary
    }
  }

  // Fungsi untuk mengambil dan mengatur nilai kategori berdasarkan jenis dari tb_pekerjaan
  void _getKategoriValue() {
    final CollectionReference pekerjaanCollection =
        FirebaseFirestore.instance.collection('tb_pekerjaan');
    pekerjaanCollection
        .where('nama', isEqualTo: _selectedNamaPekerjaan)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        final jenis = querySnapshot.docs.first.get('jenis') as String?;
        setState(() {
          _selectedKategori = jenis;
          _kategoriController.text = jenis ?? '';
        });
      }
    }).catchError((error) {
      print('Error getting kategori value: $error');
      // Handle error if necessary
    });
  }

  List<DropdownMenuItem<String>> _buildNamaPekerjaanDropdownItems() {
    Set<String> uniqueNamaPekerjaan = _namaPekerjaanList.toSet();
    return uniqueNamaPekerjaan.map((namaPekerjaan) {
      return DropdownMenuItem(
        value: namaPekerjaan,
        child: Text(namaPekerjaan),
      );
    }).toList();
  }
}
