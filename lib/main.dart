import 'package:auth_2024/firebase_options.dart';
import 'package:auth_2024/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase dependiendo de si es web o no
  // if (GetPlatform.isWeb) {
  //   await Firebase.initializeApp(
  //     options: const FirebaseOptions(
  //         apiKey: "AIzaSyCiX67MfBCHQSclhS84z61oS9GGB84l4GY",
  //         authDomain: "movil-2024-c121b.firebaseapp.com",
  //         projectId: "movil-2024-c121b",
  //         storageBucket: "movil-2024-c121b.appspot.com",
  //         messagingSenderId: "205478674110",
  //         appId: "1:205478674110:web:f1d7582c7c1b34056668ef"),
  //   );
  // } else {
  //   await Firebase.initializeApp();
  // }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Authenticaion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: LoginPage(),
    );
  }
}
