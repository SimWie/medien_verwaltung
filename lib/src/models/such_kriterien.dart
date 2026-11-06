import 'genre.dart';
import 'medium.dart';

/// Unveränderliches Suchobjekt. Alle Kriterien sind optional und werden
/// UND-verknüpft. Dank `const`-Konstruktoren können Suchen als
/// Compile-Zeit-Konstanten definiert werden.
class SuchKriterien {
  const SuchKriterien({
    this.titelEnthaelt,
    this.autor,
    this.regisseur,
    this.genre,
    this.jahr,
    this.vonJahr,
    this.bisJahr,
    this.mindestBewertung,
  });

  // Benannte, umleitende const-Konstruktoren als Abkürzungen.
  const SuchKriterien.autor(String autor) : this(autor: autor);
  const SuchKriterien.regisseur(String regisseur) : this(regisseur: regisseur);
  const SuchKriterien.genre(Genre genre) : this(genre: genre);
  const SuchKriterien.jahr(int jahr) : this(jahr: jahr);
  const SuchKriterien.zeitraum(int von, int bis)
    : this(vonJahr: von, bisJahr: bis);

  final String? titelEnthaelt;
  final String? autor;
  final String? regisseur;
  final Genre? genre;
  final int? jahr;
  final int? vonJahr;
  final int? bisJahr;
  final double? mindestBewertung;

  bool trifftZu(Medium m) =>
      _enthaelt(m.titel, titelEnthaelt) &&
      (genre == null || m.genre == genre) &&
      (jahr == null || m.erscheinungsjahr == jahr) &&
      (vonJahr == null || m.erscheinungsjahr >= vonJahr!) &&
      (bisJahr == null || m.erscheinungsjahr <= bisJahr!) &&
      (mindestBewertung == null || (m.bewertung ?? -1) >= mindestBewertung!) &&
      _personPasst(m);

  /// Exhaustiver `switch` über die sealed-Klasse [Medium] mit
  /// Objekt-Patterns (`Buch(:final autor)`).
  bool _personPasst(Medium m) => switch (m) {
    Buch(:final autor) => regisseur == null && _enthaelt(autor, this.autor),
    Film(:final regisseur) =>
      autor == null && _enthaelt(regisseur, this.regisseur),
  };

  static bool _enthaelt(String wert, String? suche) =>
      suche == null || wert.toLowerCase().contains(suche.toLowerCase());

  @override
  String toString() {
    final teile = [
      if (titelEnthaelt != null) 'Titel enthält "$titelEnthaelt"',
      if (autor != null) 'Autor "$autor"',
      if (regisseur != null) 'Regisseur "$regisseur"',
      if (genre != null) 'Genre ${genre!.bezeichnung}',
      if (jahr != null) 'Jahr $jahr',
      if (vonJahr != null || bisJahr != null)
        'Zeitraum ${vonJahr ?? '…'}–${bisJahr ?? '…'}',
      if (mindestBewertung != null) 'Bewertung ≥ $mindestBewertung',
    ];
    return teile.isEmpty ? 'alle Medien' : teile.join(', ');
  }
}
