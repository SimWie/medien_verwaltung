part of 'medium.dart';

final class Buch extends Medium with Ausleihbar {
  /// Standard-Konstruktor mit Super-Parametern (`super.titel` etc.).
  Buch({
    super.id,
    required super.titel,
    required this.autor,
    required super.erscheinungsjahr,
    required super.genre,
    this.isbn,
    this.seitenzahl,
    super.bewertung,
  }) : assert(
         seitenzahl == null || seitenzahl > 0,
         'Seitenzahl muss positiv sein',
       );

  /// Benannter, umleitender Konstruktor (redirecting constructor).
  Buch.anonym({
    required String titel,
    required int erscheinungsjahr,
    Genre genre = Genre.sonstiges,
  }) : this(
         titel: titel,
         autor: 'Unbekannt',
         erscheinungsjahr: erscheinungsjahr,
         genre: genre,
       );

  /// Factory-Konstruktor mit Pattern Matching auf eine Map.
  factory Buch.fromJson(Map<String, Object?> json) {
    if (json case {
      'titel': final String titel,
      'autor': final String autor,
      'erscheinungsjahr': final int jahr,
      'genre': final String genre,
    }) {
      return Buch(
        id: json['id'] as int?,
        titel: titel,
        autor: autor,
        erscheinungsjahr: jahr,
        genre: Genre.parse(genre),
        isbn: switch (json['isbn']) {
          final String s => Isbn(s),
          _ => null,
        },
        seitenzahl: json['seitenzahl'] as int?,
        bewertung: (json['bewertung'] as num?)?.toDouble(),
      );
    }
    throw FormatException('Ungültiges Buch-JSON: $json');
  }

  final String autor;
  final Isbn? isbn;
  final int? seitenzahl;

  @override
  String get typBezeichnung => 'Buch';

  /// Geschätzte Lesedauer (ca. 40 Seiten pro Stunde).
  String get lesedauer => switch (seitenzahl) {
    null => 'unbekannt',
    final s => 'ca. ${(s / 40).ceil()} h',
  };

  Buch copyWith({
    int? id,
    String? titel,
    String? autor,
    int? erscheinungsjahr,
    Genre? genre,
    Isbn? isbn,
    int? seitenzahl,
    double? bewertung,
  }) => Buch(
    id: id ?? this.id,
    titel: titel ?? this.titel,
    autor: autor ?? this.autor,
    erscheinungsjahr: erscheinungsjahr ?? this.erscheinungsjahr,
    genre: genre ?? this.genre,
    isbn: isbn ?? this.isbn,
    seitenzahl: seitenzahl ?? this.seitenzahl,
    bewertung: bewertung ?? this.bewertung,
  );

  @override
  Buch mitId(int id) => copyWith(id: id);

  @override
  Map<String, Object?> toJson() => {
    'typ': 'buch',
    ...super.toJson(),
    'autor': autor,
    if (isbn case final isbn?) 'isbn': isbn.wert,
    'seitenzahl': ?seitenzahl,
  };

  @override
  String toString() =>
      '📘 #${id ?? '-'} "$titel" von $autor '
      '($erscheinungsjahr, ${genre.bezeichnung})';
}
