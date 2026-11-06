import 'package:medien_verwaltung/medien_verwaltung.dart';
import 'package:test/test.dart';

Buch _buch({
  String titel = 'Testbuch',
  String autor = 'Autor',
  int jahr = 2000,
  Genre genre = Genre.roman,
}) => Buch(titel: titel, autor: autor, erscheinungsjahr: jahr, genre: genre);

void main() {
  late MedienDatenbank db;

  setUp(() => db = MedienDatenbank.mitLatenz(Duration.zero));
  tearDown(() => db.schliessen());

  group('Modell', () {
    test('Titel wird getrimmt und validiert', () {
      final b = _buch(titel: '  Hallo  ');
      expect(b.titel, 'Hallo');
      expect(() => b.titel = '', throwsArgumentError);
    });

    test('Bewertung ausserhalb 0..5 wirft RangeError', () {
      expect(() => _buch().bewertung = 6, throwsRangeError);
    });

    test('JSON Roundtrip', () {
      final film = Film.inMinuten(
        titel: 'F',
        regisseur: 'R',
        erscheinungsjahr: 1999,
        genre: Genre.drama,
        minuten: 95,
      );
      final kopie = Medium.fromJson(film.toJson()) as Film;
      expect(kopie.dauer, const Duration(minutes: 95));
      expect(kopie.regisseur, 'R');
    });

    test('Ausleihen und Zurückgeben', () {
      final b = _buch()..ausleihen('Ben');
      expect(b.istVerfuegbar, isFalse);
      expect(() => b.ausleihen('Simon'), throwsStateError);
      b.zurueckgeben();
      expect(b.istVerfuegbar, isTrue);
    });

    test('ISBN-Validierung', () {
      expect(const Isbn('978-3-608-93800-5').istGueltig, isTrue);
      expect(const Isbn('123').istGueltig, isFalse);
    });
  });

  group('Datenbank', () {
    test('Hinzufügen vergibt fortlaufende IDs', () async {
      final a = await db.hinzufuegen(_buch(titel: 'A'));
      final b = await db.hinzufuegen(_buch(titel: 'B'));
      expect([a.id, b.id], [1, 2]);
      expect(await db.anzahl(), 2);
    });

    test('Suche nach Autor, Genre und Jahr', () async {
      await db.alleHinzufuegen([
        _buch(titel: 'A', autor: 'Tolkien', jahr: 1937, genre: Genre.fantasy),
        _buch(titel: 'B', autor: 'Tolkien', jahr: 1954, genre: Genre.fantasy),
        _buch(titel: 'C', autor: 'Dürrenmatt', jahr: 1952, genre: Genre.krimi),
      ]);
      expect(
        await db.suche(const SuchKriterien.autor('tolkien')),
        hasLength(2),
      );
      expect(
        await db.suche(const SuchKriterien.genre(Genre.krimi)),
        hasLength(1),
      );
      expect(
        (await db.suche(const SuchKriterien.zeitraum(1950, 1960)))
            .map((m) => m.titel),
        ['C', 'B'],
      );
    });

    test('Löschen entfernt Datensatz, unbekannte ID wirft', () async {
      final a = await db.hinzufuegen(_buch());
      await db.loeschen(a.id!);
      expect(await db.findeNachId(a.id!), isNull);
      expect(
        () => db.loeschen(42),
        throwsA(isA<MediumNichtGefundenException>()),
      );
    });

    test('Änderungen werden als Stream gemeldet', () async {
      final ereignisse = db.aenderungen.map((e) => e.typ).take(2).toList();
      final a = await db.hinzufuegen(_buch());
      await db.loeschen(a.id!);
      expect(await ereignisse, [
        EreignisTyp.hinzugefuegt,
        EreignisTyp.geloescht,
      ]);
    });

    test('Zugriff nach Schliessen schlägt fehl', () async {
      await db.schliessen();
      expect(db.alle, throwsA(isA<DatenbankGeschlossenException>()));
    });
  });
}
