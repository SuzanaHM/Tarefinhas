import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tarefinhas/AppBarPadrao.dart';
import 'package:tarefinhas/Cache.dart';
import 'package:tarefinhas/API.dart';

class EditTarefa extends StatefulWidget {
  final String? uuid; // id da tarefa (null = nova)
  final String? titulo;
  final String? desc;
  final String? funcao;
  final String? filho; // uid do filho
  final String? imagem; // url da imagem

  const EditTarefa({
    Key? key,
    this.uuid,
    this.titulo,
    this.desc,
    this.funcao,
    this.filho,
    this.imagem,
  }) : super(key: key);

  @override
  State<EditTarefa> createState() => _EditTarefaState();
}

class _EditTarefaState extends State<EditTarefa> {
  List<String> filhos = ["Carregando"];
  String filhoSelect = "Carregando";

  late TextEditingController nomeController;
  late TextEditingController descController;
  late TextEditingController funcaoController;

  File? imagemSelecionada;

  @override
  void initState() {
    super.initState();

    nomeController = TextEditingController(text: widget.titulo ?? "");
    descController = TextEditingController(text: widget.desc ?? "");
    funcaoController = TextEditingController(text: widget.funcao ?? "1N-5S-1N");

    _loadFilhos();
  }

  Future<void> _loadFilhos() async {
    final cache = await Cache.create();
    setState(() {
      filhos.clear();
      filhos = cache.getFilhos();
      if (widget.filho != null) {
        for (String f in filhos) {
          if (f.contains(widget.filho!)) {
            filhoSelect = f;
            break;
          }
        }
      } else {
        filhoSelect = filhos.isNotEmpty ? filhos[0] : "Nenhum filho";
      }
    });
  }

  Future<void> selecionarFoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? foto = await picker.pickImage(source: ImageSource.gallery);

    if (foto != null) {
      setState(() {
        imagemSelecionada = File(foto.path);
      });
    }
  }

  Future<void> concluir() async {
    Future<void> _alertar(String mensagem) async {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Atenção"),
          content: Text(mensagem),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      );
    }

    if (nomeController.text.trim().isEmpty) {
      await _alertar("Defina o nome da tarefa.");
      return;
    }
    if (descController.text.trim().isEmpty) {
      await _alertar("Defina a descrição da tarefa.");
      return;
    }
    if (filhoSelect == "Carregando" ||
        filhoSelect == "Nenhum filho" ||
        filhoSelect.trim().isEmpty) {
      await _alertar("Selecione um filho válido.");
      return;
    }
    if (funcaoController.text.trim().isEmpty) {
      await _alertar("Defina a função de tempo.");
      return;
    }

    try {
      final api = await ApiService.create();

      String? fotoUrl;
      if (imagemSelecionada != null) {
        fotoUrl = await api.uploadImage(XFile(imagemSelecionada!.path));
      } else {
        fotoUrl = widget.imagem; // mantém imagem antiga se não trocar
      }

      final result = await api.setTarefa(
        id: widget.uuid ?? "", // se vier uuid, edita; senão cria nova
        imagem: fotoUrl ?? "",
        titulo: nomeController.text.trim(),
        desc: descController.text.trim(),
        filho: filhoSelect.split(";")[0],
        funcao: funcaoController.text.trim(),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Tarefa salva!")));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagemUrl = widget.imagem;

    return Scaffold(
      appBar: AppBar(
        title: AppBarPadrao().getTitle(),
        backgroundColor: AppBarPadrao().getBackground(),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Nome da Tarefa',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              TextField(
                controller: nomeController,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              const Text(
                'Descrição',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              TextField(
                controller: descController,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              const Text(
                'Filho(a)',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              DropdownButton<String>(
                alignment: Alignment.center,
                isExpanded: true,
                value: filhoSelect,
                items: filhos.map((String valor) {
                  return DropdownMenuItem<String>(
                    value: valor,
                    child: Center(
                      child: (valor.contains(";"))
                          ? Text(
                              valor.split(";")[1],
                              style: const TextStyle(fontSize: 18),
                            )
                          : Text(valor, style: const TextStyle(fontSize: 18)),
                    ),
                  );
                }).toList(),
                onChanged: (String? novoValor) {
                  setState(() {
                    filhoSelect = novoValor!;
                  });
                },
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Função de Tempo', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Instrucoes().popup(context),
                    child: const Icon(
                      FontAwesomeIcons.circleQuestion,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              TextField(
                controller: funcaoController,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              AspectRatio(
                aspectRatio: 1,
                child: imagemSelecionada != null
                    ? Image.file(imagemSelecionada!)
                    : (imagemUrl != null && imagemUrl.isNotEmpty
                          ? Image.network(imagemUrl)
                          : const Image(image: AssetImage('imagens/404.png'))),
              ),
              TextButton(
                onPressed: selecionarFoto,
                child: const Text(
                  "Selecionar Foto",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(height: 24),

              TextButton(
                onPressed: concluir,
                style: TextButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text(
                  "Concluir",
                  style: TextStyle(fontSize: 25, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Instrucoes {
  Future popup(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Instruções", style: TextStyle(fontSize: 25)),
          content: const Text(
            "A função de tempo é composta por número de dias e letra, separados por '-'.\n\n"
            "A letra deve ser S (sim) ou N (não).\n\n"
            "Exemplo:\n"
            "-> 1S significa que deve aparecer 1 dia consecutivo\n"
            "-> 1S-1N significa 1 dia sim, 1 dia não\n\n"
            "Sempre inicia no domingo. Exemplo: '1N-5S-1N' significa domingo não, segunda a sexta sim, sábado não.",
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
