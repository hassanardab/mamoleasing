class TransactionModel {
  final String accountId;
  final String accountName;
  final double amount;
  final String type; // "debit" or "credit"

  TransactionModel({
    required this.accountId,
    required this.accountName,
    required this.amount,
    required this.type,
  });

  factory TransactionModel.fromFirestore(Map<String, dynamic> data) {
    return TransactionModel(
      accountId: data['accountId'] ?? '',
      accountName: data['accountName'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      type: data['type'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'accountId': accountId,
      'accountName': accountName,
      'amount': amount,
      'type': type,
    };
  }
}
