import 'package:medien_verwaltung/buch.dart';
import 'package:medien_verwaltung/buch_datenbank.dart';

Future<void> main() async {
  final db = BuchDatenbank();

  print('--- Bücher hinzufügen ---');
  await db.hinzufuegen(
    Buch(
      id: 1,
      titel: 'Der Hobbit',
      autor: 'Tolkien',
      genre: 'Fantasy',
      jahr: 1937,
    ),
  );
  await db.hinzufuegen(
    Buch(
      id: 2,
      titel: 'Der Herr der Ringe',
      autor: 'Tolkien',
      genre: 'Fantasy',
      jahr: 1954,
    ),
  );
  await db.hinzufuegen(
    Buch.fromMap({
      'id': 3,
      'titel': 'Der Schwarm',
      'autor': 'Schätzing',
      'genre': 'Science-Fiction',
      'jahr': 2004,
    }),
  );
  await db.hinzufuegen(Buch.unbekannt(4, 'Tausendundeine Nacht'));
  print('4 Bücher hinzugefügt.');

  print('\n--- Alle Bücher ---');
  for (final buch in await db.alle()) {
    print(buch);
  }

  print('\n--- Suche nach Autor "Tolkien" ---');
  (await db.suche(autor: 'Tolkien')).forEach(print);

  print('\n--- Suche nach Genre "Science-Fiction" ---');
  (await db.suche(genre: 'Science-Fiction')).forEach(print);

  print('\n--- Suche nach Jahr 1937 ---');
  (await db.suche(jahr: 1937)).forEach(print);

  print('\n--- Getter und Setter ---');
  final hobbit = (await db.suche(jahr: 1937)).first;
  hobbit.bewertung = 4.5;
  print(
    '${hobbit.titel}: Bewertung ${hobbit.bewertung}, '
    'Klassiker: ${hobbit.istKlassiker}',
  );

  print('\n--- Buch #4 löschen ---');
  final geloescht = await db.loeschen(4);
  print(geloescht ? 'Gelöscht.' : 'Nicht gefunden.');
  for (final buch in await db.alle()) {
    print(buch);
  }
}
