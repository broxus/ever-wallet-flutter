class UnauthorizedException implements Exception {
  final String? info;

  UnauthorizedException([this.info]);

  @override
  String toString() => info ?? super.toString();
}

class PasswordNotFoundException implements Exception {
  final String? info;

  PasswordNotFoundException([this.info]);

  @override
  String toString() => info ?? super.toString();
}

class AccountAlreadyAddedException implements Exception {
  final String? info;

  AccountAlreadyAddedException([this.info]);

  @override
  String toString() => info ?? super.toString();
}

class InsufficientFundsException implements Exception {
  final String? info;

  InsufficientFundsException([this.info]);

  @override
  String toString() => info ?? super.toString();
}
