import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tarefinhas/AppBarPadrao.dart';
import 'package:tarefinhas/API.dart';
import 'package:tarefinhas/Cache.dart';

class FilhoMenu extends StatefulWidget {
  @override
  State<FilhoMenu> createState() => _FilhoMenuState();
}

class _FilhoMenuState extends State<FilhoMenu> {
  String? fotoUrl;

  TextButton Botao(Function() function, String texto) {
    return TextButton(
      onPressed: function,
      style: TextButton.styleFrom(backgroundColor: Colors.blueAccent),
      child: Text(
        texto.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 25,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _verificarPais();
  }

  Future<void> _verificarPais() async {
    final cache = await Cache.create();
    if (cache.getPais() == null) {
      _abrirPopupCadastro();
    }
  }

  void _abrirPopupCadastro() {
    final codeController = TextEditingController();
    final nomeController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // não deixa fechar sem cadastrar
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text(
                "Conectar ao Pai/Mãe",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: codeController,
                      decoration: const InputDecoration(labelText: "Código"),
                    ),
                    TextField(
                      controller: nomeController,
                      decoration: const InputDecoration(labelText: "Nome"),
                    ),
                    const SizedBox(height: 12),
                    fotoUrl == null
                        ? ElevatedButton(
                            child: const Text("Selecionar Foto"),
                            onPressed: () async {
                              final picker = ImagePicker();
                              final img = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (img != null) {
                                final api = await ApiService.create();
                                final url = await api.uploadImage(img);
                                setStateDialog(() {
                                  fotoUrl = url;
                                });
                              }
                            },
                          )
                        : CircleAvatar(
                            radius: 100,
                            backgroundImage: NetworkImage(fotoUrl!),
                          ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("OK"),
                  onPressed: () async {
                    final code = codeController.text.trim();
                    final nome = nomeController.text.trim();

                    if (code.isEmpty || nome.isEmpty || fotoUrl == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Preencha todos os campos"),
                        ),
                      );
                      return;
                    }

                    final api = await ApiService.create();
                    final result = await api.setFilho(
                      code: code,
                      nome: nome,
                      foto: fotoUrl!,
                    );

                    if (result["rescode"] == 1) {
                      final parenteUid = result["parente"];
                      final cache = await Cache.create();
                      await cache.setPais(parenteUid);
                      await cache.setNome(nome);
                      Navigator.of(context).pop(); // fecha popup
                    } else if (result["rescode"] == 4) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Código inválido ou vencido"),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Erro ao conectar")),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Botao(() {}, 'Tarefas'),
            const SizedBox(height: 12),
            Botao(() {}, 'Concluídas'),
            const SizedBox(height: 12),
            Botao(() async {}, 'Desconectar'),
          ],
        ),
      ),
    );
  }
}
