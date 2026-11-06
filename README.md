# Medien-Verwaltung (Dart)

Kleine Konsolenanwendung: Modell-Klasse `Buch` + simulierte, asynchrone Datenbank.

```bash
dart run bin/main.dart
```

- `lib/buch.dart` – Modell-Klasse (Standard-, benannter und Factory-Konstruktor, Getter/Setter)
- `lib/buch_datenbank.dart` – Datenbank auf Basis einer `List`, alle Methoden `async` mit `Future.delayed`
- `bin/main.dart` – testet Hinzufügen, Anzeigen, Suchen (Autor, Genre, Jahr) und Löschen
