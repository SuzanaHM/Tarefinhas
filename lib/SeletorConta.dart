import 'package:flutter/material.dart';
import 'package:tarefinhas/AppBarPadrao.dart';
import 'package:tarefinhas/Cache.dart';
import 'package:tarefinhas/Filho.dart';
import 'package:tarefinhas/Pais.dart';
import 'package:tarefinhas/API.dart';

class SeletorConta extends StatefulWidget {
  @override
  State<SeletorConta> createState() => _SeletorContaState();
}

class _SeletorContaState extends State<SeletorConta> {
  Cache? cache;
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _initCache();
  }

  Future<void> _initCache() async {
    cache = await Cache.create();

    try {
      final api = await ApiService.create();
      final perfil = await api.getPerfilType();

      if (perfil["rescode"] == 1) {
        if (perfil["tipo"] == "parente") {
          await cache!.setContaTipo("pais");
          await cache!.setPais("");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => PaisMenu()),
          );
          return;
        } else if (perfil["tipo"] == "filho") {
          await cache!.setContaTipo("filho");
          await cache!.setPais(perfil["parente"]);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => FilhoMenu()),
          );
          return;
        }
      }
    } catch (e) {
      print("Erro ao verificar perfil: $e");
    }

    setState(() {
      carregando = false; // se não for nenhum, mostra a tela
    });
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: AppBarPadrao().getTitle(),
        backgroundColor: AppBarPadrao().getBackground(),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'O que você é?',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex: 1,
                child: GestureDetector(
                  onTap: () async {
                    await cache!.setContaTipo("pais");
                    await cache!.setPais("");
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => PaisMenu()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: const [
                        CircleAvatar(
                          minRadius: 80,
                          backgroundImage: AssetImage('imagens/mae.png'),
                        ),
                        Text(
                          'Mãe/Pai',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 25),
              Flexible(
                flex: 1,
                child: GestureDetector(
                  onTap: () async {
                    await cache!.setContaTipo("filho");
                    // aqui não sabemos o parente ainda, só depois do vínculo
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => FilhoMenu()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: const [
                        CircleAvatar(
                          minRadius: 80,
                          backgroundImage: AssetImage('imagens/filhos.png'),
                        ),
                        Text(
                          'Filho(a)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
