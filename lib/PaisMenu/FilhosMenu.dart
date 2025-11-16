import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tarefinhas/API.dart';
import 'package:tarefinhas/AppBarPadrao.dart';
import 'package:tarefinhas/Cache.dart';
import 'package:tarefinhas/PaisMenu/EditFilho.dart';

class FilhosMenu extends StatefulWidget {
  @override
  State<FilhosMenu> createState() => _FilhosMenuState();
}

class _FilhosMenuState extends State<FilhosMenu> {
  List<String> filhosRaw = [];
  List<Map<String, String>> filhos = [];

  String statusConect = "aguardando";
  int sec = 120;
  Timer? _timer; // referência para cancelar depois

  @override
  void initState() {
    super.initState();
    _carregarFilhos();
  }

  Future<void> _carregarFilhos() async {
    final cache = await Cache.create();

    try {
      final api = await ApiService.create();
      final response = await api.getFilhos();

      if (response["rescode"] == 1 && response["filhos"] is Map) {
        final filhosMap = response["filhos"] as Map;

        filhos = filhosMap.entries.map((e) {
          return {
            "uuid": e.key.toString(),
            "nome": (e.value["nome"] ?? "Sem nome").toString(),
            "imagem": (e.value["foto"] ?? "").toString(),
          };
        }).toList();

        final filhosRaw = filhos.map((f) {
          return "${f['uuid']};${f['nome']};${f['imagem']}";
        }).toList();
        await cache.setFilhos(filhosRaw);
      } else {
        final filhosRaw = cache.getFilhos();
        filhos = filhosRaw.map((f) {
          final partes = f.split(';');
          return {
            "uuid": partes[0],
            "nome": partes.length > 1 ? partes[1] : "Sem nome",
            "imagem": partes.length > 2 ? partes[2] : "",
          };
        }).toList();
      }
    } catch (e) {
      print("Erro ao carregar filhos: $e");
      final filhosRaw = cache.getFilhos();
      filhos = filhosRaw.map((f) {
        final partes = f.split(';');
        return {
          "uuid": partes[0],
          "nome": partes.length > 1 ? partes[1] : "Sem nome",
          "imagem": partes.length > 2 ? partes[2] : "",
        };
      }).toList();
    }

    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel(); // cancela timer ao sair da tela
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarPadrao().getTitle(),
        backgroundColor: AppBarPadrao().getBackground(),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _carregarFilhos();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final api = await ApiService.create();
          final result = await api.gerarCode();
          final code = result["code"] ?? "-----";

          setState(() {
            statusConect = "aguardando ( ${sec}s )";
          });

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (context, setStateDialog) {
                  // inicia timer periódico
                  _timer?.cancel();
                  _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
                    if (!mounted) {
                      timer.cancel();
                      return;
                    }
                    if (sec > 0) {
                      setStateDialog(() {
                        sec--;
                        statusConect = "aguardando ( ${sec}s )";
                      });
                      if (sec % 4 == 0) {
                        final verify = await api.verifyCode(code: code);
                        final status = verify["status"];
                        if (status != "Valido") {
                          sec = 0;
                        }
                      }
                    } else {
                      final verify = await api.verifyCode(code: code);
                      final status = verify["status"];

                      setStateDialog(() {
                        if (status == "Valido") {
                          statusConect = "aguardando ( ${sec}s )";
                        } else if (status == "Usado" &&
                            statusConect != "vencido") {
                          statusConect = "conectado";
                          timer.cancel();
                        } else if (status == "Vencido") {
                          statusConect = "vencido";
                          timer.cancel();
                        }
                      });
                    }
                  });

                  return AlertDialog(
                    title: Text(
                      "Conectar Filho",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "No aparelho da criança, baixe o app, faça login, selecione o perfil de filho e insira o código abaixo:",
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Text(
                          code.split("").join(" "),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 8,
                            color: Colors.blue,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Text(
                          statusConect,
                          style: TextStyle(
                            fontSize: 18,
                            color: statusConect == "conectado"
                                ? Colors.green
                                : statusConect == "vencido"
                                ? Colors.red
                                : Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    actionsAlignment: MainAxisAlignment.center,
                    actions: [
                      TextButton(
                        child: Text("OK", style: TextStyle(fontSize: 20)),
                        onPressed: () {
                          _timer?.cancel();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        backgroundColor: AppBarPadrao().getBackground(),
        shape: const CircleBorder(),
        child: const Icon(FontAwesomeIcons.plus, color: Colors.white),
      ),
      body: filhos.isEmpty
          ? const Center(child: Text("Nenhum filho encontrado"))
          : ListView.builder(
              itemCount: filhos.length,
              itemBuilder: (context, index) {
                final filho = filhos[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: filho["imagem"]!.isNotEmpty
                        ? NetworkImage(filho["imagem"]!)
                        : null,
                    child: filho["imagem"]!.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(filho["nome"] ?? "Sem nome"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return EditFilho(
                            uid: filho["uuid"]!,
                            nome: filho["nome"] ?? "Sem nome",
                            foto: filho["imagem"]!,
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
