extension ListWidgetExtension<T> on Iterable<T> {
  List<T> separated(T separator) {
    if (isEmpty) return toList();

    final children = <T>[];
    for (int i = 0; i < length; i++) {
      children.add(elementAt(i));

      if (length - i != 1) {
        children.add(separator);
      }
    }

    return children;
  }

  Iterable<R> mapIndex<R>(R Function(T item, int index) mapBy) sync* {
    for (var i = 0; i < length; i++) {
      yield mapBy(elementAt(i), i);
    }
  }

  void forEachIndexed<R>(R Function(T item, int index) each) {
    for (var i = 0; i < length; i++) {
      each(elementAt(i), i);
    }
  }
}
