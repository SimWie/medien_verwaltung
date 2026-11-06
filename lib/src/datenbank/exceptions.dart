/// Basis aller Datenbank-Fehler.
sealed class DatenbankException implements Exception {
  const DatenbankException(this.nachricht);
  final String nachricht;

  @override
  String toString() => '$runtimeType: $nachricht';
}

final class MediumNichtGefundenException extends DatenbankException {
  const MediumNichtGefundenException(this.id)
    : super('Kein Medium mit ID $id gefunden.');
  final int id;
}

final class UngueltigeOperationException extends DatenbankException {
  const UngueltigeOperationException(super.nachricht);
}

final class DatenbankGeschlossenException extends DatenbankException {
  const DatenbankGeschlossenException()
    : super('Die Datenbank-Verbindung ist geschlossen.');
}
