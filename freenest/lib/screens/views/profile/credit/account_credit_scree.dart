import 'package:flutter/material.dart';

class Transaction {
  final String id;
  final String description;
  final DateTime date;
  final double amount;
  final bool isCredit; // true for credit, false for debit

  Transaction({
    required this.id,
    required this.description,
    required this.date,
    required this.amount,
    required this.isCredit,
  });

  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  String get formattedTime {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class AccountCreditScreen extends StatefulWidget {
  static String routeName = '/account-credit';
  const AccountCreditScreen({super.key});

  @override
  State<AccountCreditScreen> createState() => _AccountCreditScreenState();
}

class _AccountCreditScreenState extends State<AccountCreditScreen> {
  final double availableCredit = 500.0;

  // Mock transaction data
  final List<Transaction> transactions = [
    Transaction(
      id: '1',
      description: 'Grocery Store Purchase',
      date: DateTime.now().subtract(const Duration(days: 2)),
      amount: 45.75,
      isCredit: false,
    ),
    Transaction(
      id: '2',
      description: 'Restaurant Payment',
      date: DateTime.now().subtract(const Duration(days: 3)),
      amount: 32.50,
      isCredit: false,
    ),
    Transaction(
      id: '3',
      description: 'Credit Top-up',
      date: DateTime.now().subtract(const Duration(days: 5)),
      amount: 200.00,
      isCredit: true,
    ),
    Transaction(
      id: '4',
      description: 'Online Shopping',
      date: DateTime.now().subtract(const Duration(days: 7)),
      amount: 89.99,
      isCredit: false,
    ),
    Transaction(
      id: '5',
      description: 'Coffee Shop',
      date: DateTime.now().subtract(const Duration(days: 8)),
      amount: 5.75,
      isCredit: false,
    ),
    Transaction(
      id: '6',
      description: 'Monthly Credit Reset',
      date: DateTime.now().subtract(const Duration(days: 10)),
      amount: 500.00,
      isCredit: true,
    ),
    Transaction(
      id: '7',
      description: 'Gas Station',
      date: DateTime.now().subtract(const Duration(days: 12)),
      amount: 60.25,
      isCredit: false,
    ),
    Transaction(
      id: '8',
      description: 'Credit Bonus',
      date: DateTime.now().subtract(const Duration(days: 15)),
      amount: 50.00,
      isCredit: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Credit',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Available Credit Card
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.0),
              border:
                  Border.all(color: Colors.black.withOpacity(0.1), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Available Credit',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '\$${availableCredit.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 10, vertical: 4),
                    //   decoration: BoxDecoration(
                    //     color: Colors.green.shade50,
                    //     borderRadius: BorderRadius.circular(20),
                    //     border: Border.all(color: Colors.green.shade100),
                    //   ),
                    //   child: const Row(
                    //     children: [
                    //       Icon(Icons.check_circle,
                    //           size: 14, color: Colors.green),
                    //       SizedBox(width: 4),
                    //       Text(
                    //         'Active',
                    //         style: TextStyle(
                    //           fontSize: 12,
                    //           color: Colors.green,
                    //           fontWeight: FontWeight.w500,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Transaction History Header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: const Text(
              'Transaction History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          // Transaction List
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: transactions.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 60,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No transactions yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: transactions.length,
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.grey.shade300,
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: transaction.isCredit
                                  ? Colors.green.shade50
                                  : Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              transaction.isCredit
                                  ? Icons.add_circle_outline
                                  : Icons.remove_circle_outline,
                              color: transaction.isCredit
                                  ? Colors.green
                                  : Colors.blue,
                              size: 28,
                            ),
                          ),
                          title: Text(
                            transaction.description,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            '${transaction.formattedDate} at ${transaction.formattedTime}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                transaction.isCredit
                                    ? '+\$${transaction.amount.toStringAsFixed(2)}'
                                    : '-\$${transaction.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: transaction.isCredit
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: transaction.isCredit
                                      ? Colors.green.shade50
                                      : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  transaction.isCredit ? 'Credit' : 'Debit',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: transaction.isCredit
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
