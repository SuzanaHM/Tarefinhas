import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: Principal()));
}

class Principal extends StatefulWidget {
  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tarefinhas')),
      body: Text('Teste'),
    );
  }
}
