import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginControllerKoordinator extends GetxController {
  var userType = ''.obs;
  var username = ''.obs;
  var namaKoordinator = ''.obs;

  Future<void> getUserInfo(String nrp) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('tb_koordinator')
          .where('nrp', isEqualTo: nrp)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data() as Map<String, dynamic>?;

        if (data != null) {
          userType.value = data['userType'] as String? ?? '';
          username.value = data['nrp'] as String? ?? '';
          namaKoordinator.value = data['nama'] as String? ?? '';
        } else {
          // Handle null data case
          print('Data is null for NRP: $nrp');
        }
      } else {
        // Dokumen tidak ditemukan
        // Lakukan sesuai kebutuhan Anda, misalnya menampilkan pesan kesalahan
        print('Dokumen tidak ditemukan untuk NRP: $nrp');
      }
    } catch (error) {
      // Tangani error jika terjadi
      print('Error saat mengambil informasi pengguna: $error');
    }
  }

  void setUserType(String s) {
    userType.value = s;
  }

  void setUsername(String enteredUser) {
    username.value = enteredUser;
  }

  void setNamaKoordinator(String namaKoordinator) {}
}
