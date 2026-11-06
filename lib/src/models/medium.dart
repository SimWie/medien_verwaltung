import 'ausleihbar.dart';
import 'genre.dart';
import 'isbn.dart';

part 'buch.dart';
part 'film.dart';

/// Basisklasse aller Medien.
///
/// `sealed` bedeutet: Alle Unterklassen ([Buch], [Film]) sind in dieser
/// Library bekannt. Dadurch kann der Compiler bei `switch`-Ausdrücken prüfen,
/// ob alle Fälle abgedeckt sind (Exhaustiveness Checking).
sealed class Medium implements Comparable<Medium> {
  /// Generativer Konstruktor mit Initialisierungsliste und `assert`.
  Medium({
    this.id,
    required String titel,
    required this.erscheinungsjahr,
    required this.genre,
    double? bewertung,
  }) : assert(erscheinungsjahr > 0, 'Erscheinungsjahr muss positiv sein'),
       _titel = _validiereTitel(titel),
       _bewertung = _validiereBewertung(bewertung);

  /// Factory-Konstruktor: Entscheidet anhand des Feldes `typ`, welche
  /// konkrete Unterklasse erzeugt wird.
  factory Medium.fromJson(Map<String, Object?> json) => switch (json['typ']) {
    'buch' => Buch.fromJson(json),
    'film' => Film.fromJson(json),
    final typ => throw FormatException('Unbekannter Medientyp: $typ'),
  };

  /// Wird von der Datenbank vergeben – `null`, solange nicht gespeichert.
  final int? id;
  final int erscheinungsjahr;
  final Genre genre;

  // Private Felder mit Getter/Setter-Paar für Validierung.
  String _titel;
  double? _bewertung;

  String get titel => _titel;
  set titel(String wert) => _titel = _validiereTitel(wert);

  /// Bewertung von 0 bis 5 Sternen (oder `null` = unbewertet).
  double? get bewertung => _bewertung;
  set bewertung(double? wert) => _bewertung = _validiereBewertung(wert);

  // Berechnete Getter (Arrow-Syntax).
  bool get istGespeichert => id != null;
  bool get istBewertet => _bewertung != null;
  int get alterInJahren => DateTime.now().year - erscheinungsjahr;
  bool get istKlassiker => alterInJahren >= 25;

  String get sterne => switch (_bewertung) {
    null => 'unbewertet',
    final b => '${'★' * b.round()}${'☆' * (5 - b.round())} ($b)',
  };

  /// Abstrakter Getter – jede Unterklasse liefert ihren Typnamen.
  String get typBezeichnung;

  /// Liefert eine Kopie mit gesetzter ID (wird von der Datenbank verwendet).
  Medium mitId(int id);

  Map<String, Object?> toJson() => {
    'id': id,
    'titel': titel,
    'erscheinungsjahr': erscheinungsjahr,
    'genre': genre.name,
    if (bewertung != null) 'bewertung': bewertung,
  };

  /// Sortierung: zuerst nach Jahr, dann alphabetisch nach Titel.
  @override
  int compareTo(Medium other) {
    final nachJahr = erscheinungsjahr.compareTo(other.erscheinungsjahr);
    return nachJahr != 0 ? nachJahr : titel.compareTo(other.titel);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Medium &&
          other.runtimeType == runtimeType &&
          other.id == id &&
          other.titel == titel &&
          other.erscheinungsjahr == erscheinungsjahr;

  @override
  int get hashCode => Object.hash(runtimeType, id, titel, erscheinungsjahr);

  static String _validiereTitel(String titel) {
    final bereinigt = titel.trim();
    if (bereinigt.isEmpty) {
      throw ArgumentError.value(titel, 'titel', 'darf nicht leer sein');
    }
    return bereinigt;
  }

  static double? _validiereBewertung(double? bewertung) {
    if (bewertung != null && (bewertung < 0 || bewertung > 5)) {
      throw RangeError.value(
        bewertung,
        'bewertung',
        'muss zwischen 0 und 5 liegen',
      );
    }
    return bewertung;
  }
}
