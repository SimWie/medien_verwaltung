/// Modell-Klasse für ein Buch.
class Buch {
  final int id;
  final String titel;
  final String autor;
  final String genre;
  final int jahr;
  double _bewertung = 0; // privates Feld

  // Standard-Konstruktor mit benannten Parametern
  Buch({
    required this.id,
    required this.titel,
    required this.autor,
    required this.genre,
    required this.jahr,
  });

  // Benannter Konstruktor, der an den Standard-Konstruktor weiterleitet
  Buch.unbekannt(int id, String titel)
    : this(
        id: id,
        titel: titel,
        autor: 'Unbekannt',
        genre: 'Sonstiges',
        jahr: 0,
      );

  // Factory-Konstruktor, z.B. für Daten aus JSON
  factory Buch.fromMap(Map<String, dynamic> map) => Buch(
    id: map['id'],
    titel: map['titel'],
    autor: map['autor'],
    genre: map['genre'],
    jahr: map['jahr'],
  );

  // Getter und Setter mit Prüfung
  double get bewertung => _bewertung;
  set bewertung(double wert) {
    if (wert < 0 || wert > 5) throw ArgumentError('Bewertung muss 0–5 sein');
    _bewertung = wert;
  }

  // Berechneter Getter
  bool get istKlassiker => DateTime.now().year - jahr > 50;

  @override
  String toString() => '#$id "$titel" von $autor ($jahr, $genre)';
}
