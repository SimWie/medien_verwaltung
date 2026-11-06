part of 'medium.dart';

final class Film extends Medium with Ausleihbar {
  static const erlaubteFreigaben = [0, 6, 12, 16, 18];

  Film({
    super.id,
    required super.titel,
    required this.regisseur,
    required super.erscheinungsjahr,
    required super.genre,
    required this.dauer,
    this.altersfreigabe = 0,
    super.bewertung,
  }) : assert(
         erlaubteFreigaben.contains(altersfreigabe),
         'Ungültige Altersfreigabe: $altersfreigabe',
       );

  /// Benannter Konstruktor mit eigener Initialisierungsliste:
  /// Die Dauer wird bequem in Minuten angegeben.
  Film.inMinuten({
    super.id,
    required super.titel,
    required this.regisseur,
    required super.erscheinungsjahr,
    required super.genre,
    required int minuten,
    this.altersfreigabe = 0,
    super.bewertung,
  }) : assert(minuten > 0, 'Dauer muss positiv sein'),
       dauer = Duration(minutes: minuten);

  factory Film.fromJson(Map<String, Object?> json) {
    if (json case {
      'titel': final String titel,
      'regisseur': final String regisseur,
      'erscheinungsjahr': final int jahr,
      'genre': final String genre,
      'minuten': final int minuten,
    }) {
      return Film.inMinuten(
        id: json['id'] as int?,
        titel: titel,
        regisseur: regisseur,
        erscheinungsjahr: jahr,
        genre: Genre.parse(genre),
        minuten: minuten,
        altersfreigabe: json['altersfreigabe'] as int? ?? 0,
        bewertung: (json['bewertung'] as num?)?.toDouble(),
      );
    }
    throw FormatException('Ungültiges Film-JSON: $json');
  }

  final String regisseur;
  final Duration dauer;
  final int altersfreigabe;

  @override
  String get typBezeichnung => 'Film';

  String get dauerFormatiert =>
      '${dauer.inHours} h ${dauer.inMinutes.remainder(60).toString().padLeft(2, '0')} min';

  bool istFreigegebenFuer(int alter) => alter >= altersfreigabe;

  Film copyWith({
    int? id,
    String? titel,
    String? regisseur,
    int? erscheinungsjahr,
    Genre? genre,
    Duration? dauer,
    int? altersfreigabe,
    double? bewertung,
  }) => Film(
    id: id ?? this.id,
    titel: titel ?? this.titel,
    regisseur: regisseur ?? this.regisseur,
    erscheinungsjahr: erscheinungsjahr ?? this.erscheinungsjahr,
    genre: genre ?? this.genre,
    dauer: dauer ?? this.dauer,
    altersfreigabe: altersfreigabe ?? this.altersfreigabe,
    bewertung: bewertung ?? this.bewertung,
  );

  @override
  Film mitId(int id) => copyWith(id: id);

  @override
  Map<String, Object?> toJson() => {
    'typ': 'film',
    ...super.toJson(),
    'regisseur': regisseur,
    'minuten': dauer.inMinutes,
    'altersfreigabe': altersfreigabe,
  };

  @override
  String toString() =>
      '🎬 #${id ?? '-'} "$titel" von $regisseur '
      '($erscheinungsjahr, ${genre.bezeichnung}, $dauerFormatiert, FSK $altersfreigabe)';
}
