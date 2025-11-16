import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tarefinhas/API.dart';
import 'package:tarefinhas/AppBarPadrao.dart';
import 'package:tarefinhas/login.dart';

class EditFilho extends StatefulWidget {
  final String uid;
  final String nome;
  final String foto;

  EditFilho({required this.uid, required this.nome, required this.foto});

  @override
  State<EditFilho> createState() => _EditFilhoState();
}

class _EditFilhoState extends State<EditFilho> {
  late TextEditingController _nomeController;
  File? _imagemSelecionada;
  String? _fotoAtual;
  bool _alterado = false;
  late final ApiService api;

  @override
  void initState() {
    super.initState();
    _carregar();
    _nomeController = TextEditingController(text: widget.nome);
    _fotoAtual = widget.foto;
    _nomeController.addListener(() {
      if (_nomeController.text != widget.nome) {
        setState(() => _alterado = true);
      } else {
        setState(() => _alterado = false);
      }
    });
  }

  Future<void> _carregar() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Login()),
        );
        return;
      }

      api = await ApiService.create();
    } catch (e) {
      print("Erro ao carregar editfilho: $e");
    }
  }

  Future<void> selecionarFoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? foto = await picker.pickImage(source: ImageSource.gallery);

    if (foto != null) {
      setState(() {
        _imagemSelecionada = File(foto.path);
        _alterado = true;
      });
    }
  }

  Future<void> _acaoFinal() async {
    if (_alterado) {
      // Salvar alterações
      String fotoUrl = _fotoAtual ?? "";
      if (_imagemSelecionada != null) {
        final uploaded = await api.uploadImage(XFile(_imagemSelecionada!.path));
        if (uploaded != null) fotoUrl = uploaded;
      }

      final result = await api.setFilho(
        uuid: widget.uid,
        nome: _nomeController.text,
        foto: fotoUrl,
      );

      print(result);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Filho atualizado!")));
    } else {
      // Deletar filho
      final result = await api.deleteFilho(filhoId: widget.uid);

      print(result);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Filho deletado!")));
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarPadrao().getTitle(),
        backgroundColor: AppBarPadrao().getBackground(),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Nome do Filho',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            TextField(
              controller: _nomeController,
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
            SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 1,
              child: _imagemSelecionada != null
                  ? Image.file(_imagemSelecionada!)
                  : (_fotoAtual != null && _fotoAtual!.isNotEmpty
                        ? Image.network(_fotoAtual!)
                        : Image.asset('imagens/404.png')),
            ),
            TextButton(
              onPressed: selecionarFoto,
              child: Text("Selecionar Foto", style: TextStyle(fontSize: 20)),
            ),
            SizedBox(height: 24),
            TextButton(
              onPressed: _acaoFinal,
              style: TextButton.styleFrom(
                backgroundColor: _alterado ? Colors.green : Colors.red,
              ),
              child: Text(
                _alterado ? "Salvar" : "Deletar",
                style: TextStyle(fontSize: 25, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
