/// Extension Type: Zur Laufzeit nur ein [String], zur Compile-Zeit aber ein
/// eigener Typ mit eigenen Methoden – kein Overhead, aber Typsicherheit.
extension type const Isbn(String wert) {
  /// Entfernt Bindestriche und Leerzeichen.
  String get normalisiert => wert.replaceAll(RegExp(r'[-\s]'), '');

  /// Prüft, ob es sich formal um eine ISBN-10 oder ISBN-13 handelt.
  bool get istGueltig =>
      RegExp(r'^(\d{9}[\dX]|\d{13})$').hasMatch(normalisiert);
}
