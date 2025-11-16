import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:tarefinhas/AppBarPadrao.dart';
import 'package:tarefinhas/Cache.dart';
import 'package:tarefinhas/PaisMenu/EditTarefa.dart';
import 'package:tarefinhas/Pais.dart';
import 'package:tarefinhas/SeletorConta.dart';
import 'package:tarefinhas/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final cache = await Cache.create();
  User? usuario = FirebaseAuth.instance.currentUser;
  bool usuarioLogado = usuario != null;
  Widget home = Login();

  if (usuarioLogado) {
    String? ct = await cache.getContaTipo();

    if (ct == null) {
      home = SeletorConta();
    } else if (ct == "filho") {
      //home = FilhoMenu();
    } else if (ct == "pais") {
      home = PaisMenu();
    } else {
      home = EditTarefa(); // fallback
    }
  }

  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: home));
}
