const String termsOfUseLink =
    'https://everwallet.net/pdf/ever_wallet_terms_of_use.pdf';
const String privacyPolicyLink =
    'https://everwallet.net/pdf/ever_wallet_privacy_policy.pdf';
const String buyEverLink = 'https://buy.everwallet.net/';

String accountExplorerLink({
  required String explorerBaseUrl,
  required String address,
}) =>
    '$explorerBaseUrl/accounts/$address';

String transactionExplorerLink({
  required String explorerBaseUrl,
  required String id,
}) =>
    '$explorerBaseUrl/transactions/$id';
