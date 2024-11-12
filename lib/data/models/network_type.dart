enum NetworkType {
  everscale,
  venom,
  tycho;

  T when<T>({
    required T Function() everscale,
    required T Function() venom,
    required T Function() tycho,
  }) {
    switch (this) {
      case NetworkType.everscale:
        return everscale();
      case NetworkType.venom:
        return venom();
      case NetworkType.tycho:
        return tycho();
    }
  }
}
