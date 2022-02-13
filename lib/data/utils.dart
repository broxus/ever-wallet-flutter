extension VersionConvert on String {
  int toInt() {
    final parts = split('.');

    if (parts.length != 3) {
      throw Exception();
    }

    for (final part in parts) {
      if (int.parse(part) > 999) {
        throw Exception();
      }
    }

    int multiplier = 1000000;
    int numericVersion = 0;

    for (var i = 0; i < 3; i++) {
      numericVersion += int.parse(parts[i]) * multiplier;
      multiplier = multiplier ~/ 1000;
    }

    return numericVersion;
  }
}
