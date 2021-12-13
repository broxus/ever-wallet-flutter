extension ToDateTime on int {
  DateTime toDateTime() => DateTime.fromMillisecondsSinceEpoch(this * Duration.millisecondsPerSecond);
}
