class UnauthorizedException implements Exception {
  final String? info;

  UnauthorizedException([this.info]);

  @override
  String toString() => info ?? 'Unauthorized';
}

class PasswordNotFoundException implements Exception {
  final String? info;

  PasswordNotFoundException([this.info]);

  @override
  String toString() => info ?? 'Password not found';
}

class AccountAlreadyAddedException implements Exception {
  final String? info;

  AccountAlreadyAddedException([this.info]);

  @override
  String toString() => info ?? 'Account already added';
}

class InsufficientFundsException implements Exception {
  final String? info;

  InsufficientFundsException([this.info]);

  @override
  String toString() => info ?? 'Insufficient funds';
}
