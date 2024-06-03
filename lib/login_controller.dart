import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  var loggedIn = false.obs; // Properti untuk menandai status login
  var userData = {}.obs;
  var nrp = ''.obs; // Inisialisasi properti nrp dengan string kosong

  get isAdmin => null;

  // Metode untuk proses login
  void login(String nrp, String password,
      {required Function(bool) onSuccess,
      required Function(String) onError}) async {
    try {
      // Lakukan proses autentikasi
      if (nrp == 'admin' && password == 'admin123') {
        // Jika login sebagai admin, tandai sebagai sudah login dan admin
        loggedIn.value = true;
        onSuccess(true);
      } else {
        // Jika bukan admin, cek di Firestore
        var querySnapshot = await FirebaseFirestore.instance
            .collection('tb_pengguna')
            .where('NRP', isEqualTo: nrp)
            .where('Password', isEqualTo: password)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Jika pengguna ditemukan, tandai sebagai sudah login dan bukan admin
          loggedIn.value = true;

          // Simpan data pengguna
          userData.value = querySnapshot.docs.first.data();

          // Set properti nrp
          this.nrp.value = nrp;

          onSuccess(false);
        } else {
          onError('NRP atau password salah. Silakan coba lagi.');
        }
      }
    } catch (error) {
      print('Error during login: $error');
      onError('Terjadi kesalahan. Silakan coba lagi.');
    }
  }

  // Metode untuk proses logout
  void logout() {
    // Reset properti loggedIn, userData, dan nrp
    loggedIn.value = false;
    userData.value = {};
    nrp.value = '';
  }
}
