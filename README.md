# Medien-Verwaltung (Dart)

Konsolenanwendung, die eine Medien-Verwaltung für **Bücher** und **Filme** simuliert –
mit Modell-Klassen und einem asynchronen, simulierten Datenbank-Service.

## Starten

```bash
dart pub get
dart run        # Demo in bin/medien_verwaltung.dart
dart test       # Unit-Tests
```

## Struktur

```
bin/medien_verwaltung.dart          main(): testet alle Operationen, Ausgabe auf der Konsole
lib/medien_verwaltung.dart          Barrel-Datei (exportiert alles)
lib/src/models/
  medium.dart                       sealed class Medium (+ part buch.dart, film.dart)
  buch.dart / film.dart             konkrete Modell-Klassen
  ausleihbar.dart                   Mixin zum Ausleihen/Zurückgeben
  genre.dart                        Enhanced Enum
  isbn.dart                         Extension Type
  such_kriterien.dart               const-Suchobjekt mit Pattern Matching
  medien_extensions.dart            Extension Methods für Auswertungen
lib/src/datenbank/
  medien_datenbank.dart             simulierte asynchrone Datenbank
  exceptions.dart                   sealed Exception-Hierarchie
test/medien_verwaltung_test.dart    Unit-Tests
```

## Erfüllte Anforderungen

### 1. Modell-Klassen
| Dart-Feature | Wo |
|---|---|
| Generativer Konstruktor mit Initialisierungsliste & `assert` | `Medium(...)` |
| Super-Parameter (`super.titel`) | `Buch(...)`, `Film(...)` |
| Benannter Konstruktor | `Film.inMinuten(...)` |
| Umleitender Konstruktor | `Buch.anonym(...)`, `SuchKriterien.autor(...)` |
| Factory-Konstruktor | `Medium.fromJson`, `Buch.fromJson`, `MedienDatenbank()` (Singleton) |
| Privater Konstruktor | `MedienDatenbank._intern` |
| `const`-Konstruktor | `SuchKriterien`, `Genre`, `Isbn` |
| Getter / Setter mit Validierung | `titel`, `bewertung` |
| Berechnete Getter | `alterInJahren`, `istKlassiker`, `sterne`, `dauerFormatiert`, `lesedauer` |
| Abstrakte Member | `typBezeichnung`, `mitId()` |
| `sealed` / `final class` | `Medium`, `Buch`, `Film`, `DatenbankException` |
| Mixin | `Ausleihbar` |
| Enhanced Enum | `Genre` |
| Extension Type | `Isbn` |
| Extension Methods | `MedienAuswertung` |
| Records | `DatenbankEreignis`, `zeitspanne`, Suchergebnisse in `main` |
| Pattern Matching / exhaustive `switch` | `fromJson`, `SuchKriterien._personPasst`, Tabellen-Ausgabe |
| Collection-`if`, Spread, Null-aware Elemente | `toJson()` |
| `copyWith`, `==`/`hashCode`, `Comparable`, `toString` | `Buch`, `Film`, `Medium` |
| Kaskaden-Operator `..` | `main` (Setter), Sortierungen |

### 2. Datenbank-Simulation
`MedienDatenbank` speichert die Medien in einer `Map<int, Medium>` und vergibt
fortlaufende IDs (Auto-Increment).

### 3. Konsolenapplikation
`main()` zeigt: Hinzufügen (einzeln, parallel, aus JSON), Anzeigen aller Medien
(Tabelle, nach Typ, als Stream), Suchen (Autor, Regisseur, Genre, Jahr, Zeitraum,
Titel, Mindestbewertung), Löschen (per ID und per Kriterium), Fehlerbehandlung
und Statistik.

### 4. Asynchrone Programmierung
- Jeder Datenbankzugriff liefert ein `Future` und wird per `Future.delayed`
  (300 ms + zufällige Schwankung) verzögert, um I/O zu simulieren.
- `Future.wait` für parallele Schreib- und Suchvorgänge (Zeitvergleich in der Ausgabe).
- `Stream` mit `async*`/`yield` (`streameAlle`) und `await for`.
- Broadcast-`StreamController` für Änderungs-Ereignisse.
- Asynchrone Fehlerbehandlung mit `try`/`on`/`catch`.
