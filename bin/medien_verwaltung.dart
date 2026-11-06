import 'dart:async';

import 'package:medien_verwaltung/medien_verwaltung.dart';

Future<void> main() async {
  final db = MedienDatenbank();

  // Auf Änderungen der Datenbank reagieren (Stream-Abo).
  final protokoll = <String>[];
  final abo = db.aenderungen.listen(
    (e) => protokoll.add(
      '${e.typ.name.padRight(13)} #${e.medium.id} ${e.medium.titel}',
    ),
  );

  _titel('MEDIEN-VERWALTUNG');

  // ---------------------------------------------------------------------------
  _abschnitt('1. Medien hinzufügen');
  // ---------------------------------------------------------------------------

  // a) Einzeln, mit verschiedenen Konstruktoren
  final hobbit = await _mitLadeanzeige(
    'Speichere "Der Hobbit"',
    db.hinzufuegen(
      Buch(
        titel: 'Der Hobbit',
        autor: 'J. R. R. Tolkien',
        erscheinungsjahr: 1937,
        genre: Genre.fantasy,
        isbn: const Isbn('978-3-608-93800-5'),
        seitenzahl: 384,
        bewertung: 4.5,
      ),
    ),
  );
  print('   → $hobbit');

  final anonym = await _mitLadeanzeige(
    'Speichere anonymes Buch (umleitender Konstruktor)',
    db.hinzufuegen(
      Buch.anonym(titel: 'Tausendundeine Nacht', erscheinungsjahr: 1704),
    ),
  );
  print('   → $anonym');

  // b) Mehrere parallel mit Future.wait
  final stoppuhr = Stopwatch()..start();
  final parallel = await Future.wait<Medium>([
    db.hinzufuegen(
      Buch(
        titel: 'Der Herr der Ringe',
        autor: 'J. R. R. Tolkien',
        erscheinungsjahr: 1954,
        genre: Genre.fantasy,
        seitenzahl: 1200,
        bewertung: 5,
      ),
    ),
    db.hinzufuegen(
      Buch(
        titel: 'Der Schwarm',
        autor: 'Frank Schätzing',
        erscheinungsjahr: 2004,
        genre: Genre.scienceFiction,
        seitenzahl: 1000,
        bewertung: 3.5,
      ),
    ),
    db.hinzufuegen(
      Buch(
        titel: 'Der Richter und sein Henker',
        autor: 'Friedrich Dürrenmatt',
        erscheinungsjahr: 1952,
        genre: Genre.krimi,
        seitenzahl: 128,
        bewertung: 4,
      ),
    ),
    db.hinzufuegen(
      Film.inMinuten(
        titel: 'Interstellar',
        regisseur: 'Christopher Nolan',
        erscheinungsjahr: 2014,
        genre: Genre.scienceFiction,
        minuten: 169,
        altersfreigabe: 12,
        bewertung: 4.8,
      ),
    ),
    db.hinzufuegen(
      Film(
        titel: 'Chihiros Reise ins Zauberland',
        regisseur: 'Hayao Miyazaki',
        erscheinungsjahr: 2001,
        genre: Genre.animation,
        dauer: const Duration(hours: 2, minutes: 5),
        bewertung: 4.9,
      ),
    ),
  ]);
  stoppuhr.stop();
  print(
    '   ${parallel.length} Medien parallel gespeichert in '
    '${stoppuhr.elapsedMilliseconds} ms (statt ~${parallel.length * 400} ms sequentiell)',
  );

  // c) Aus JSON über den Factory-Konstruktor der sealed-Klasse
  const jsonDaten = [
    {
      'typ': 'film',
      'titel': 'Der Herr der Ringe: Die Gefährten',
      'regisseur': 'Peter Jackson',
      'erscheinungsjahr': 2001,
      'genre': 'fantasy',
      'minuten': 178,
      'altersfreigabe': 12,
      'bewertung': 4.7,
    },
    {
      'typ': 'buch',
      'titel': 'Sapiens',
      'autor': 'Yuval Noah Harari',
      'erscheinungsjahr': 2011,
      'genre': 'Sachbuch',
      'seitenzahl': 528,
    },
  ];
  final ausJson = await db.alleHinzufuegen(jsonDaten.map(Medium.fromJson));
  print('   ${ausJson.length} Medien aus JSON importiert');

  // d) Fehlerfälle
  await _erwarteFehler(
    'Bereits gespeichertes Medium erneut speichern',
    () => db.hinzufuegen(hobbit),
  );
  await _erwarteFehler(
    'Unbekannter Typ im JSON',
    () async => Medium.fromJson({'typ': 'hörspiel'}),
  );
  await _erwarteFehler(
    'Leerer Titel',
    () async => Buch(
      titel: '  ',
      autor: 'X',
      erscheinungsjahr: 2000,
      genre: Genre.roman,
    ),
  );

  // ---------------------------------------------------------------------------
  _abschnitt('2. Alle Medien anzeigen');
  // ---------------------------------------------------------------------------

  final alle = await _mitLadeanzeige('Lade alle Medien', db.alle());
  _tabelle(alle);

  print('\n   Nur Filme (generischer Typ-Parameter alle<Film>()):');
  for (final film in await db.alle<Film>()) {
    print('   • ${film.titel.padRight(36)} ${film.dauerFormatiert}');
  }

  print('\n   Datensätze als Stream lesen (async* / await for):');
  await for (final m in db.streameAlle().take(3)) {
    print('   ⇢ #${m.id} ${m.titel}');
  }
  print('   … (nach 3 Datensätzen abgebrochen)');

  // ---------------------------------------------------------------------------
  _abschnitt('3. Suchen');
  // ---------------------------------------------------------------------------

  const suchen = <SuchKriterien>[
    SuchKriterien.autor('tolkien'),
    SuchKriterien.genre(Genre.scienceFiction),
    SuchKriterien.jahr(2001),
    SuchKriterien.zeitraum(1900, 1960),
    SuchKriterien(titelEnthaelt: 'ring', mindestBewertung: 4.6),
    SuchKriterien.regisseur('nolan'),
    SuchKriterien(autor: 'Rowling'),
  ];

  // Alle Suchen gleichzeitig starten, Ergebnisse als Records zurück.
  final ergebnisse = await Future.wait(
    suchen.map((k) async => (kriterien: k, treffer: await db.suche(k))),
  );
  for (final (:kriterien, :treffer) in ergebnisse) {
    print('   🔎 $kriterien → ${treffer.length} Treffer');
    for (final m in treffer) {
      print('      - ${m.titel} (${m.erscheinungsjahr})');
    }
  }

  final fantasyBuecher = await db.suche<Buch>(
    const SuchKriterien.genre(Genre.fantasy),
  );
  print(
    '   🔎 Nur Bücher im Genre Fantasy (suche<Buch>) → '
    '${fantasyBuecher.map((b) => b.titel).join(', ')}',
  );

  // ---------------------------------------------------------------------------
  _abschnitt('4. Getter, Setter & Mixin');
  // ---------------------------------------------------------------------------

  final schwarm = (await db.suche<Buch>(
    const SuchKriterien(titelEnthaelt: 'Schwarm'),
  )).single;
  print(
    '   ${schwarm.titel}: ${schwarm.sterne}, Lesedauer ${schwarm.lesedauer}, '
    'Klassiker: ${schwarm.istKlassiker ? 'ja' : 'nein'} (${schwarm.alterInJahren} Jahre)',
  );

  schwarm
    ..bewertung =
        4.0 // Setter mit Validierung
    ..titel = '  Der Schwarm (Taschenbuch)  '; // Setter trimmt
  await db.aktualisieren(schwarm);
  print('   Nach Update: "${schwarm.titel}", ${schwarm.sterne}');
  await _erwarteFehler('Bewertung 7 setzen', () async => schwarm.bewertung = 7);

  print(
    '   ISBN von "${hobbit.titel}": ${hobbit.isbn?.normalisiert} '
    '(gültig: ${hobbit.isbn?.istGueltig})',
  );

  hobbit.ausleihen('Ben', dauer: const Duration(days: 14));
  print('   ${hobbit.titel}: ${hobbit.ausleihStatus}');
  await _erwarteFehler(
    'Bereits ausgeliehenes Buch ausleihen',
    () async => hobbit.ausleihen('Simon'),
  );
  hobbit.zurueckgeben();
  print('   ${hobbit.titel}: ${hobbit.ausleihStatus}');

  final interstellar = parallel.whereType<Film>().first;
  print(
    '   Darf ein 10-Jähriger "${interstellar.titel}" schauen? '
    '${interstellar.istFreigegebenFuer(10) ? 'Ja' : 'Nein'} (FSK ${interstellar.altersfreigabe})',
  );

  // ---------------------------------------------------------------------------
  _abschnitt('5. Löschen');
  // ---------------------------------------------------------------------------

  final geloescht = await _mitLadeanzeige(
    'Lösche #${anonym.id}',
    db.loeschen(anonym.id!),
  );
  print('   ✗ Gelöscht: $geloescht');

  final anzahlKrimis = await db.loeschenWo(
    const SuchKriterien.genre(Genre.krimi),
  );
  print('   ✗ $anzahlKrimis Krimi(s) per Suchkriterium gelöscht');

  await _erwarteFehler(
    'Nicht existierendes Medium #999 löschen',
    () => db.loeschen(999),
  );
  print('   Verbleibende Medien: ${await db.anzahl()}');

  // ---------------------------------------------------------------------------
  _abschnitt('6. Statistik (Extension Methods)');
  // ---------------------------------------------------------------------------

  final bestand = await db.alle();
  final spanne = bestand.zeitspanne!;
  print('   Bücher: ${bestand.buecher.length}, Filme: ${bestand.filme.length}');
  print(
    '   Ø Bewertung: ${bestand.durchschnittsBewertung?.toStringAsFixed(2)}',
  );
  print(
    '   Gesamte Filmdauer: ${bestand.gesamtFilmdauer.inMinutes} min, '
    'gesamte Seiten: ${bestand.gesamtSeiten}',
  );
  print(
    '   Ältestes: ${spanne.aeltestes.titel} (${spanne.aeltestes.erscheinungsjahr}), '
    'neuestes: ${spanne.neuestes.titel} (${spanne.neuestes.erscheinungsjahr})',
  );
  print('   Pro Genre:');
  bestand.anzahlProGenre.forEach((genre, n) => print('     $genre: $n'));

  final export = await db.exportieren();
  print('   Export: ${export.length} Datensätze, z.B. ${export.first}');

  // ---------------------------------------------------------------------------
  _abschnitt('7. Änderungsprotokoll (Stream-Ereignisse)');
  // ---------------------------------------------------------------------------

  await db.schliessen();
  await abo.cancel();
  for (final zeile in protokoll) {
    print('   $zeile');
  }

  await _erwarteFehler('Zugriff nach dem Schliessen', db.alle);
  print('\nFertig. 👋');
}

// -----------------------------------------------------------------------------
// Hilfsfunktionen für die Konsolenausgabe
// -----------------------------------------------------------------------------

void _titel(String text) {
  final linie = '═' * (text.length + 4);
  print('╔$linie╗\n║  $text  ║\n╚$linie╝');
}

void _abschnitt(String text) => print('\n── $text ${'─' * (60 - text.length)}');

/// Zeigt während eines asynchronen Vorgangs eine Meldung mit Dauer an.
Future<T> _mitLadeanzeige<T>(String text, Future<T> future) async {
  final uhr = Stopwatch()..start();
  final ergebnis = await future;
  print('   ⏳ $text … fertig (${uhr.elapsedMilliseconds} ms)');
  return ergebnis;
}

/// Führt eine Aktion aus, die einen Fehler werfen soll, und gibt ihn aus.
Future<void> _erwarteFehler(
  String beschreibung,
  FutureOr<Object?> Function() aktion,
) async {
  try {
    await aktion();
    print('   ⚠ $beschreibung: KEIN Fehler aufgetreten!');
  } on DatenbankException catch (e) {
    print('   ✓ $beschreibung → ${e.nachricht}');
  } on Error catch (e) {
    // ArgumentError, RangeError, StateError
    print('   ✓ $beschreibung → ${e.runtimeType}: ${_nachricht(e)}');
  } on FormatException catch (e) {
    print('   ✓ $beschreibung → FormatException: ${e.message}');
  }
}

String _nachricht(Error e) => switch (e) {
  ArgumentError(:final message) => '$message',
  StateError(:final message) => message,
  _ => '$e',
};

void _tabelle(List<Medium> medien) {
  print(
    '   ${'ID'.padRight(4)}${'Typ'.padRight(6)}${'Titel'.padRight(36)}'
    '${'Urheber'.padRight(22)}${'Jahr'.padRight(6)}${'Genre'.padRight(16)}Bewertung',
  );
  print('   ${'-' * 100}');
  for (final m in medien) {
    final urheber = switch (m) {
      Buch(:final autor) => autor,
      Film(:final regisseur) => regisseur,
    };
    print(
      '   ${'#${m.id}'.padRight(4)}${m.typBezeichnung.padRight(6)}'
      '${_kuerze(m.titel, 34).padRight(36)}${_kuerze(urheber, 20).padRight(22)}'
      '${'${m.erscheinungsjahr}'.padRight(6)}${m.genre.bezeichnung.padRight(16)}'
      '${m.bewertung?.toStringAsFixed(1) ?? '–'}',
    );
  }
}

String _kuerze(String s, int max) =>
    s.length <= max ? s : '${s.substring(0, max - 1)}…';
