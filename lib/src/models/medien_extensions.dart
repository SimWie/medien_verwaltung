import 'genre.dart';
import 'medium.dart';

/// Extension Methods: Erweitern jede `Iterable<Medium>` (z.B. List) um
/// Auswertungs-Funktionen, ohne die Klasse selbst zu verändern.
extension MedienAuswertung on Iterable<Medium> {
  Iterable<Buch> get buecher => whereType<Buch>();
  Iterable<Film> get filme => whereType<Film>();

  double? get durchschnittsBewertung {
    final bewertungen = map((m) => m.bewertung).nonNulls;
    if (bewertungen.isEmpty) return null;
    return bewertungen.reduce((a, b) => a + b) / bewertungen.length;
  }

  Map<Genre, int> get anzahlProGenre => fold(
    <Genre, int>{},
    (map, m) => map..update(m.genre, (n) => n + 1, ifAbsent: () => 1),
  );

  /// Ältestes und neuestes Medium als Record.
  ({Medium aeltestes, Medium neuestes})? get zeitspanne {
    if (isEmpty) return null;
    final sortiert = toList()..sort();
    return (aeltestes: sortiert.first, neuestes: sortiert.last);
  }

  Duration get gesamtFilmdauer =>
      filme.fold(Duration.zero, (summe, f) => summe + f.dauer);

  int get gesamtSeiten => buecher.fold(0, (s, b) => s + (b.seitenzahl ?? 0));
}
