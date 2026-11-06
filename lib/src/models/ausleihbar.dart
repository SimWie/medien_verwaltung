/// Mixin: Fügt einer Klasse Ausleih-Funktionalität hinzu.
/// Die Klasse muss lediglich einen `titel` bereitstellen (abstrakter Getter).
mixin Ausleihbar {
  String get titel;

  String? _ausgeliehenAn;
  DateTime? _rueckgabeBis;

  bool get istVerfuegbar => _ausgeliehenAn == null;
  String? get ausgeliehenAn => _ausgeliehenAn;
  DateTime? get rueckgabeBis => _rueckgabeBis;

  bool get istUeberfaellig => _rueckgabeBis?.isBefore(DateTime.now()) ?? false;

  void ausleihen(String person, {Duration dauer = const Duration(days: 28)}) {
    if (!istVerfuegbar) {
      throw StateError('"$titel" ist bereits an $_ausgeliehenAn ausgeliehen.');
    }
    _ausgeliehenAn = person;
    _rueckgabeBis = DateTime.now().add(dauer);
  }

  void zurueckgeben() {
    if (istVerfuegbar) {
      throw StateError('"$titel" ist gar nicht ausgeliehen.');
    }
    _ausgeliehenAn = null;
    _rueckgabeBis = null;
  }

  String get ausleihStatus => istVerfuegbar
      ? 'verfügbar'
      : 'ausgeliehen an $_ausgeliehenAn bis '
            '${_rueckgabeBis!.toIso8601String().substring(0, 10)}';
}
