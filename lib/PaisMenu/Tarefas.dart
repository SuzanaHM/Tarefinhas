import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tarefinhas/API.dart';
import 'package:tarefinhas/AppBarPadrao.dart';
import 'package:tarefinhas/Cache.dart';
import 'package:tarefinhas/PaisMenu/EditTarefa.dart';
import 'package:tarefinhas/login.dart';

class TarefasMenu extends StatefulWidget {
  @override
  State<TarefasMenu> createState() => _TarefasMenuState();
}

class _TarefasMenuState extends State<TarefasMenu> {
  List<Map<String, dynamic>> tarefas = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarTarefas();
  }

  Future<void> _carregarTarefas() async {
    Cache cache = await Cache.create();
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Login()),
        );
        return;
      }
      final api = await ApiService.create();

      final resultado = await api.getTarefas(parente: user.uid, filtro: 'a');

      List<Map<String, dynamic>> lista = [];

      print("resultado: $resultado");

      // pega o mapa interno
      final tarefasWrapper = resultado["tarefas"];
      final tarefasMap = tarefasWrapper is Map
          ? tarefasWrapper["tarefas"]
          : null;

      print("tarefasMap: $tarefasMap");

      if (tarefasMap is Map) {
        lista = tarefasMap.entries.map((e) {
          final tarefa = e.value as Map;
          String ft = tarefa["filho"];
          String f = "??";
          for (String fi in cache.getFilhos()) {
            if (fi.contains(ft)) {
              f = fi.split(";")[1];
            }
          }
          print("filho: ${f}");
          return {
            "id": e.key,
            "nome": tarefa["titulo"] ?? "Sem nome",
            "desc": tarefa["desc"] ?? "",
            "funcao": tarefa["funcao"] ?? "",
            "filho": f,
            "imagem": tarefa["imagem"] ?? "",
          };
        }).toList();
      }

      setState(() {
        print("lista: $lista");
        tarefas = lista;
        carregando = false;
      });
    } catch (e) {
      print("Erro ao carregar tarefas: $e");
      setState(() {
        carregando = false;
      });
    }
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
              _carregarTarefas(); // recarrega lista de tarefas
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final cache = await Cache.create();
          final filhos = cache.getFilhos();
          if (filhos.isEmpty) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Atenção"),
                content: const Text(
                  "Você precisa adicionar um filho primeiro.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditTarefa()),
          );
        },
        backgroundColor: AppBarPadrao().getBackground(),
        shape: const CircleBorder(),
        child: const Icon(FontAwesomeIcons.plus, color: Colors.white),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : tarefas.isEmpty
          ? const Center(child: Text("Nenhuma tarefa encontrada"))
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.builder(
                itemCount: tarefas.length,
                itemBuilder: (context, index) {
                  final tarefa = tarefas[index];
                  return TarefaView(
                    filho: tarefa["filho"] ?? "Desconhecido",
                    desc: tarefa["desc"] ?? "",
                    funcao: tarefa["funcao"] ?? "",
                    nome: tarefa["nome"] ?? "Sem nome",
                    id: tarefa["id"],
                    img: tarefa["imagem"],
                  );
                },
              ),
            ),
    );
  }
}

class TarefaView extends StatelessWidget {
  const TarefaView({
    Key? key,
    required this.id,
    required this.nome,
    required this.desc,
    required this.funcao,
    required this.filho,
    required this.img,
  }) : super(key: key);

  final String nome;
  final String desc;
  final String funcao;
  final String filho;
  final String id;
  final String img;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print(filho);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditTarefa(
              uuid: id,
              titulo: nome,
              desc: desc,
              funcao: funcao,
              filho: filho,
              imagem: img,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Text(
              '[${filho[0].toUpperCase()}${filho[1].toUpperCase()}] ',
              style: const TextStyle(fontSize: 20),
            ),
            Text(nome, style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
