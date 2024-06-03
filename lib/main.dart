import 'package:fd9otj/login.dart';
import 'package:fd9otj/login_controller.dart';
import 'package:fd9otj/login_controller_koordinator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import file firebase_options.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Inisialisasi Firebase dengan opsi konfigurasi yang tepat
  Get.put(LoginController());
  Get.put(LoginControllerKoordinator());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Get.off(() => LoginPage());
    });

    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.android,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 24.0),
            CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
