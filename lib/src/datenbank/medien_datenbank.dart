import 'dart:async';
import 'dart:math';

import '../models/medium.dart';
import '../models/such_kriterien.dart';
import 'exceptions.dart';

enum EreignisTyp { hinzugefuegt, aktualisiert, geloescht }

/// Record-Typ für Änderungs-Ereignisse der Datenbank.
typedef DatenbankEreignis = ({EreignisTyp typ, Medium medium});

/// Simulierter Datenbank-Service.
///
/// Die Daten liegen in einer [Map] im Speicher. Jeder Zugriff ist
/// asynchron und wird künstlich verzögert, um echte I/O-Operationen
/// (Netzwerk, Festplatte) zu simulieren.
class MedienDatenbank {
  /// Privater benannter Konstruktor – von aussen nicht aufrufbar.
  MedienDatenbank._intern({
    this.latenz = const Duration(milliseconds: 300),
    this.schwankung = const Duration(milliseconds: 200),
    int? seed,
  }) : _zufall = Random(seed);

  static final MedienDatenbank _instanz = MedienDatenbank._intern();

  /// Factory-Konstruktor als Singleton: Liefert immer dieselbe Instanz.
  factory MedienDatenbank() => _instanz;

  /// Factory für eine eigenständige Instanz (z.B. für Tests ohne Latenz).
  factory MedienDatenbank.mitLatenz(
    Duration latenz, {
    Duration schwankung = Duration.zero,
  }) => MedienDatenbank._intern(latenz: latenz, schwankung: schwankung);

  final Duration latenz;
  final Duration schwankung;
  final Random _zufall;

  /// Die "Tabelle": Primärschlüssel → Datensatz.
  final Map<int, Medium> _tabelle = {};
  int _naechsteId = 1;
  bool _geschlossen = false;

  final _ereignisse = StreamController<DatenbankEreignis>.broadcast();

  /// Stream, auf den man sich für Änderungen registrieren kann.
  Stream<DatenbankEreignis> get aenderungen => _ereignisse.stream;

  bool get istGeschlossen => _geschlossen;

  // ---------------------------------------------------------------------------
  // Interne Hilfsfunktion: simuliert I/O-Verzögerung
  // ---------------------------------------------------------------------------

  Future<T> _io<T>(T Function() operation) async {
    if (_geschlossen) throw const DatenbankGeschlossenException();
    final jitter = schwankung.inMilliseconds > 0
        ? _zufall.nextInt(schwankung.inMilliseconds)
        : 0;
    await Future<void>.delayed(latenz + Duration(milliseconds: jitter));
    if (_geschlossen) throw const DatenbankGeschlossenException();
    return operation();
  }

  void _melde(EreignisTyp typ, Medium medium) {
    if (!_ereignisse.isClosed) _ereignisse.add((typ: typ, medium: medium));
  }

  // ---------------------------------------------------------------------------
  // Schreiboperationen (CREATE / UPDATE / DELETE)
  // ---------------------------------------------------------------------------

  /// Fügt ein Medium hinzu und liefert es mit vergebener ID zurück.
  Future<T> hinzufuegen<T extends Medium>(T medium) => _io(() {
    if (medium.istGespeichert) {
      throw UngueltigeOperationException(
        'Medium "${medium.titel}" hat bereits die ID ${medium.id}.',
      );
    }
    final gespeichert = medium.mitId(_naechsteId++) as T;
    _tabelle[gespeichert.id!] = gespeichert;
    _melde(EreignisTyp.hinzugefuegt, gespeichert);
    return gespeichert;
  });

  /// Fügt mehrere Medien nacheinander hinzu (eine "Transaktion").
  Future<List<Medium>> alleHinzufuegen(Iterable<Medium> medien) async => [
    for (final m in medien) await hinzufuegen(m),
  ];

  /// Ersetzt einen bestehenden Datensatz.
  Future<T> aktualisieren<T extends Medium>(T medium) => _io(() {
    final id = medium.id;
    if (id == null || !_tabelle.containsKey(id)) {
      throw MediumNichtGefundenException(id ?? -1);
    }
    _tabelle[id] = medium;
    _melde(EreignisTyp.aktualisiert, medium);
    return medium;
  });

  /// Löscht ein Medium und liefert den gelöschten Datensatz zurück.
  Future<Medium> loeschen(int id) => _io(() {
    final entfernt = _tabelle.remove(id);
    if (entfernt == null) throw MediumNichtGefundenException(id);
    _melde(EreignisTyp.geloescht, entfernt);
    return entfernt;
  });

  /// Löscht alle Medien, die die Kriterien erfüllen. Liefert die Anzahl.
  Future<int> loeschenWo(SuchKriterien kriterien) async {
    final treffer = await suche(kriterien);
    await Future.wait(treffer.map((m) => loeschen(m.id!)));
    return treffer.length;
  }

  // ---------------------------------------------------------------------------
  // Leseoperationen (READ)
  // ---------------------------------------------------------------------------

  Future<int> anzahl() => _io(() => _tabelle.length);

  /// Liefert alle Medien (optional nur eines bestimmten Typs), sortiert.
  Future<List<T>> alle<T extends Medium>() =>
      _io(() => _tabelle.values.whereType<T>().toList()..sort());

  Future<Medium?> findeNachId(int id) => _io(() => _tabelle[id]);

  /// Wie [findeNachId], wirft aber eine Exception, wenn nichts gefunden wird.
  Future<Medium> holeNachId(int id) async =>
      await findeNachId(id) ?? (throw MediumNichtGefundenException(id));

  /// Sucht nach Medien anhand von [SuchKriterien]. Über den Typ-Parameter
  /// kann zusätzlich nach Buch oder Film gefiltert werden.
  Future<List<T>> suche<T extends Medium>(SuchKriterien kriterien) => _io(
    () =>
        _tabelle.values.whereType<T>().where(kriterien.trifftZu).toList()
          ..sort(),
  );

  /// Liest die Datensätze einzeln als Stream ("Cursor") – nützlich bei
  /// grossen Datenmengen. `async*` + `yield` erzeugen einen Stream.
  Stream<Medium> streameAlle() async* {
    if (_geschlossen) throw const DatenbankGeschlossenException();
    final ids = _tabelle.keys.toList()..sort();
    for (final id in ids) {
      await Future<void>.delayed(latenz ~/ 4);
      if (_tabelle[id] case final medium?) yield medium;
    }
  }

  /// Exportiert die gesamte Datenbank als JSON-kompatible Liste.
  Future<List<Map<String, Object?>>> exportieren() =>
      _io(() => [for (final m in _tabelle.values) m.toJson()]);

  /// Schliesst die Verbindung; weitere Zugriffe schlagen fehl.
  Future<void> schliessen() async {
    _geschlossen = true;
    await _ereignisse.close();
  }
}
