import 'buch.dart';

/// Simulierte Datenbank: Speichert Bücher in einer Liste.
/// Jeder Zugriff ist asynchron und wartet kurz, um I/O zu simulieren.
class BuchDatenbank {
  final List<Buch> _buecher = [];

  Future<void> _warte() => Future.delayed(const Duration(milliseconds: 500));

  Future<void> hinzufuegen(Buch buch) async {
    await _warte();
    _buecher.add(buch);
  }

  Future<List<Buch>> alle() async {
    await _warte();
    return List.unmodifiable(_buecher);
  }

  Future<List<Buch>> suche({String? autor, String? genre, int? jahr}) async {
    await _warte();
    return _buecher
        .where((b) => autor == null || b.autor == autor)
        .where((b) => genre == null || b.genre == genre)
        .where((b) => jahr == null || b.jahr == jahr)
        .toList();
  }

  Future<bool> loeschen(int id) async {
    await _warte();
    final vorher = _buecher.length;
    _buecher.removeWhere((b) => b.id == id);
    return _buecher.length < vorher;
  }
}
