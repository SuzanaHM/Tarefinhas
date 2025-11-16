import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tarefinhas/AppBarPadrao.dart';
import 'package:tarefinhas/Cache.dart';
import 'package:tarefinhas/SeletorConta.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    _verificarLogin();
  }

  void _verificarLogin() {
    final user = _auth.currentUser;
    if (user != null) {
      _clearCache();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SeletorConta()),
      );
    }
  }

  Future<void> _clearCache() async {
    final cache = await Cache.create();
    cache.clear();
  }

  Future<void> _loginComGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logado como ${user.displayName}')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return SeletorConta();
            },
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao logar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarPadrao().getTitle(),
        backgroundColor: AppBarPadrao().getBackground(),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: Icon(FontAwesomeIcons.google),
          label: Padding(
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 8),
            child: Text('Logar com o Google'),
          ),
          onPressed: _loginComGoogle,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red[100]),
        ),
      ),
    );
  }
}
