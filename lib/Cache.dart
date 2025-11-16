import 'package:shared_preferences/shared_preferences.dart';

enum CacheDado { Filhos, ContaTipo, Pais, Nome }

class Cache {
  late SharedPreferences prefs;

  // Inicialização assíncrona
  static Future<Cache> create() async {
    var cache = Cache._();
    cache.prefs = await SharedPreferences.getInstance();
    return cache;
  }

  Cache._();

  // Função genérica para pegar dado baseado no enum
  String? get(CacheDado dado) {
    return prefs.getString(dado.name);
  }

  Future<void> set(CacheDado dado, String valor) async {
    await prefs.setString(dado.name, valor);
  }

  // ----- Funções específicas -----

  // ContaTipo
  String? getContaTipo() => get(CacheDado.ContaTipo);
  Future<void> setContaTipo(String tipo) => set(CacheDado.ContaTipo, tipo);

  // Pais
  String? getPais() => get(CacheDado.Pais);
  Future<void> setPais(String uid) => set(CacheDado.Pais, uid);

  // Nome
  String? getNome() => get(CacheDado.Nome);
  Future<void> setNome(String nome) => set(CacheDado.Nome, nome);

  // Filhos
  List<String> getFilhos() {
    final str = get(CacheDado.Filhos);
    return str == null || str.isEmpty ? [] : str.split(',');
  }

  Future<void> setFilhos(List<String> filhos) async {
    await set(CacheDado.Filhos, filhos.join(','));
  }

  Future<void> addFilho(String filho) async {
    final filhos = getFilhos();
    filhos.add(filho);
    await setFilhos(filhos);
  }

  Future<void> removeFilho(String filho) async {
    final filhos = getFilhos();
    filhos.remove(filho);
    await setFilhos(filhos);
  }

  /// 🔹 Limpa todos os dados salvos no cache
  Future<void> clear() async {
    await prefs.clear();
  }
}
