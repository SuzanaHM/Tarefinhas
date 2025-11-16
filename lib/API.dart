import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ApiService {
  final String baseUrl =
      "https://us-central1-tarefinhas-8bsfd.cloudfunctions.net";
  final String token;

  ApiService._(this.token);

  /// Cria a instância já com token carregado
  static Future<ApiService> create() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Usuário não autenticado");
    }
    String? tok = await user.getIdToken(true);
    return ApiService._(tok!);
  }

  /// Headers com Bearer token
  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token",
  };

  Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic>? body,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/$endpoint"),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception("Erro na API [$endpoint]: ${response.statusCode}");
    }
  }

  /// setTarefa
  Future<Map<String, dynamic>> setTarefa({
    String? id,
    required String imagem,
    required String titulo,
    required String desc,
    required String filho,
    required String funcao,
  }) => _post("setTarefa", {
    "id": id,
    "imagem": imagem,
    "titulo": titulo,
    "desc": desc,
    "filho": filho,
    "funcao": funcao,
  });

  /// deleteTarefa
  Future<Map<String, dynamic>> deleteTarefa({
    required String id,
    required String filho,
  }) => _post("deleteTarefa", {"id": id, "filho": filho});

  /// gerarCode
  Future<Map<String, dynamic>> gerarCode() => _post("gerarCode", null);

  /// verifyCode
  Future<Map<String, dynamic>> verifyCode({required String code}) =>
      _post("verifyCode", {"code": code});

  /// setFilho (aceita code OU uuid)
  Future<Map<String, dynamic>> setFilho({
    String? code,
    String? uuid,
    required String nome,
    required String foto,
  }) {
    final body = {
      if (code != null) "code": code,
      if (uuid != null) "uuid": uuid,
      "nome": nome,
      "foto": foto,
    };
    return _post("setFilho", body);
  }

  /// getFilhos
  Future<Map<String, dynamic>> getFilhos() => _post("getFilhos", null);

  /// deleteFilho
  Future<Map<String, dynamic>> deleteFilho({required String filhoId}) =>
      _post("deleteFilho", {"filhoId": filhoId});

  /// getTarefas
  Future<Map<String, dynamic>> getTarefas({
    required String parente,
    required String filtro,
  }) async {
    return await _post("getTarefas", {"parente": parente, "filtro": filtro});
  }

  /// sendTarefa
  Future<Map<String, dynamic>> sendTarefa({
    required String id,
    String? imagem,
    required String estado,
    required String filho,
  }) => _post("sendTarefa", {
    "id": id,
    "imagem": imagem,
    "estado": estado,
    "filho": filho,
  });

  /// updateUserDates
  Future<Map<String, dynamic>> updateUserDates() =>
      _post("updateUserDates", null);

  /// getPerfilType
  /// Retorna se o usuário autenticado é parente, filho ou nenhum
  Future<Map<String, dynamic>> getPerfilType() => _post("getPerfilType", null);

  /// Upload de imagem para Firebase Storage
  Future<String?> uploadImage(XFile image) async {
    File file = File(image.path);

    try {
      final storageRef = FirebaseStorage.instance.ref().child(
        "uploads/${DateTime.now().millisecondsSinceEpoch}_${image.name}",
      );

      await storageRef.putFile(file);

      return await storageRef.getDownloadURL();
    } catch (e) {
      print("Erro no upload: $e");
      return null;
    }
  }
}
