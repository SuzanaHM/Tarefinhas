import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tarefinhas/API.dart';
import 'package:tarefinhas/AppBarPadrao.dart';
import 'package:tarefinhas/Cache.dart';
import 'package:tarefinhas/PaisMenu/FilhosMenu.dart';
import 'package:tarefinhas/PaisMenu/Tarefas.dart';

class PaisMenu extends StatefulWidget {
  @override
  State<PaisMenu> createState() => _PaisMenuState();
}

class _PaisMenuState extends State<PaisMenu> {
  @override
  void initState() {
    super.initState();
    _initCache();
  }

  Future<void> _initCache() async {
    Cache cache = await Cache.create();
    if (cache.getContaTipo() == 'pais') {
      ApiService api = await ApiService.create();
      api.updateUserDates();
    }
  }

  TextButton Botao(Function() function, String texto) {
    return TextButton(
      onPressed: function,
      style: TextButton.styleFrom(backgroundColor: Colors.blueAccent),
      child: Text(
        texto.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 25,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarPadrao().getTitle(),
        backgroundColor: AppBarPadrao().getBackground(),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Botao(() {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return TarefasMenu();
                  },
                ),
              );
            }, 'Tarefas'),
            SizedBox(height: 12),
            Botao(() {}, 'Hoje'),
            SizedBox(height: 12),
            Botao(() {}, 'Grafico'),
            SizedBox(height: 12),
            Botao(() {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return FilhosMenu();
                  },
                ),
              );
            }, 'Filhos'),
            SizedBox(height: 12),
            Botao(() {}, 'Desconectar'),
          ],
        ),
      ),
    );
  }
}
