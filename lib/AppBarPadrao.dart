import 'package:flutter/material.dart';

class AppBarPadrao {
  Text getTitle() {
    return Text(
      'Tarefinhas',
      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  Color? getBackground() {
    return Colors.lightBlueAccent[100];
  }
}
