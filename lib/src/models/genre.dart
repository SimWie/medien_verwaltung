/// Enhanced Enum: Jedes Genre trägt eine lesbare Bezeichnung und ein Symbol.
enum Genre {
  roman('Roman', '📖'),
  fantasy('Fantasy', '🐉'),
  scienceFiction('Science-Fiction', '🚀'),
  krimi('Krimi', '🔍'),
  sachbuch('Sachbuch', '📚'),
  drama('Drama', '🎭'),
  komoedie('Komödie', '😂'),
  animation('Animation', '🎨'),
  sonstiges('Sonstiges', '❔');

  const Genre(this.bezeichnung, this.symbol);

  final String bezeichnung;
  final String symbol;

  /// Sucht ein Genre tolerant nach Name oder Bezeichnung (z.B. aus JSON).
  static Genre parse(String wert) => values.firstWhere(
    (g) =>
        g.name.toLowerCase() == wert.toLowerCase() ||
        g.bezeichnung.toLowerCase() == wert.toLowerCase(),
    orElse: () => Genre.sonstiges,
  );

  @override
  String toString() => '$symbol $bezeichnung';
}
