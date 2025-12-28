import 'package:flutter/material.dart';
import 'package:freenest/model/user_trasaction_model.dart';
import 'package:freenest/service/account_service.dart';
import 'package:freenest/service/shared_service.dart';

class AccountCreditScreen extends StatefulWidget {
  static String routeName = '/account-credit';
  const AccountCreditScreen({super.key});

  @override
  State<AccountCreditScreen> createState() => _AccountCreditScreenState();
}

class _AccountCreditScreenState extends State<AccountCreditScreen> {
  final AccountService _accountService = AccountService();
  final ScrollController _scrollController = ScrollController();

  double _availableBalance = 0.0;
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  int _totalPages = 1;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore &&
        _hasMore &&
        _currentPage < _totalPages) {
      _loadMoreTransactions();
    }
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadUser(),
      _loadTransactions(),
    ]);
  }

  Future<void> _loadUser() async {
    try {
      final user = await SharedService.getUser();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error loading user: $e');
    }
  }

  Future<void> _loadTransactions({bool refresh = false}) async {
    try {
      if (refresh) {
        setState(() {
          _currentPage = 1;
          _hasMore = true;
          _transactions.clear();
        });
      }

      if (!refresh) {
        setState(() {
          _isLoading = true;
        });
      }

      final response = await _accountService.getTransactions(
        _currentPage,
        _limit,
      );

      if (response.status == 200) {
        final List<dynamic> transactionList = response.data ?? [];

        // Calculate total balance from all transactions on first load
        double balance = 0.0;
        final List<TransactionModel> loadedTransactions = [];

        for (var item in transactionList) {
          try {
            final transaction = TransactionModel.fromJson(item);
            loadedTransactions.add(transaction);

            // Update balance based on transaction type and status
            if (transaction.status == '1' && transaction.isCredit) {
              balance += transaction.amount;
            } else if (transaction.status == '1' && !transaction.isCredit) {
              balance -= transaction.amount;
            }
          } catch (e) {
            debugPrint('Error parsing transaction item: $e');
          }
        }

        // Update pagination info
        final pagination = response.pagination;
        if (pagination != null) {
          _totalPages = pagination['totalPages'] ?? 1;
          _hasMore = _currentPage < _totalPages;
        }

        if (mounted) {
          setState(() {
            if (refresh) {
              _transactions = loadedTransactions;
              _availableBalance = balance;
            } else {
              _transactions.addAll(loadedTransactions);
              // Only update balance on initial load
              if (_currentPage == 1) {
                _availableBalance = balance;
              }
            }
            _isLoading = false;
            _isLoadingMore = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isLoadingMore = false;
          });
        }
      }
    } catch (e) {
      print('Error loading transactions: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _loadMoreTransactions() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    _currentPage++;
    await _loadTransactions();
  }

  Future<void> _refreshTransactions() async {
    await _loadTransactions(refresh: true);
  }

  // Helper method to get status color
  Color _getStatusColor(String status, bool isDarkMode) {
    if (status == '1') {
      return isDarkMode ? Colors.green[300]! : Colors.green;
    } else if (status == '0') {
      return isDarkMode ? Colors.orange[300]! : Colors.orange;
    }
    return isDarkMode ? Colors.grey[400]! : Colors.grey;
  }

  // Helper method to get status text
  String _getStatusText(String status) {
    if (status == '1') {
      return 'Credited';
    } else if (status == '0') {
      return 'Pending';
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.grey[800]! : Colors.grey[100]!;
    final borderColor =
        isDarkMode ? Colors.grey[700]! : Colors.black.withOpacity(0.1);
    final shadowColor = isDarkMode
        ? Colors.black.withOpacity(0.3)
        : Colors.grey.withOpacity(0.2);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.grey[400]! : Colors.grey;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Account Credit',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Available Credit Card
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: borderColor,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Credit',
                  style: TextStyle(
                    fontSize: 16,
                    color: subtitleColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '\$${_availableBalance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.green[300]! : Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Transaction History Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Text(
              'Transaction History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),

          // Transaction List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshTransactions,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.grey[700]!
                              : Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: _transactions.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    size: 60,
                                    color: subtitleColor,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No transactions yet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: subtitleColor,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              controller: _scrollController,
                              itemCount:
                                  _transactions.length + (_hasMore ? 1 : 0),
                              separatorBuilder: (context, index) => Divider(
                                color: isDarkMode
                                    ? Colors.grey[700]!
                                    : Colors.grey.shade300,
                                height: 1,
                              ),
                              itemBuilder: (context, index) {
                                if (index == _transactions.length) {
                                  return _buildLoadMoreIndicator();
                                }

                                final transaction = _transactions[index];
                                final creditColor = isDarkMode
                                    ? Colors.green[300]!
                                    : Colors.green;
                                final debitColor =
                                    isDarkMode ? Colors.red[300]! : Colors.red;
                                final creditBgColor = isDarkMode
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.green.shade50;
                                final debitBgColor = isDarkMode
                                    ? Colors.red.withOpacity(0.2)
                                    : Colors.red.shade50;
                                final statusColor = _getStatusColor(
                                    transaction.status, isDarkMode);
                                final statusText =
                                    _getStatusText(transaction.status);

                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 12.0,
                                  ),
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: transaction.isCredit
                                          ? creditBgColor
                                          : debitBgColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      transaction.isCredit
                                          ? Icons.add_circle_outline
                                          : Icons.remove_circle_outline,
                                      color: transaction.isCredit
                                          ? creditColor
                                          : debitColor,
                                      size: 28,
                                    ),
                                  ),
                                  title: Text(
                                    transaction.description,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: textColor,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${transaction.formattedDate} at ${transaction.formattedTime}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: subtitleColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          statusText,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: statusColor,
                                          ),
                                        ),
                                      ),
                                    ],
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
                                              ? creditColor
                                              : debitColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: transaction.isCredit
                                              ? creditBgColor
                                              : debitBgColor,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          transaction.isCredit
                                              ? 'Credit'
                                              : 'Debit',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: transaction.isCredit
                                                ? creditColor
                                                : debitColor,
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
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: _isLoadingMore
            ? const CircularProgressIndicator()
            : _hasMore
                ? IconButton(
                    icon: const Icon(Icons.arrow_downward),
                    onPressed: _loadMoreTransactions,
                  )
                : const Text(
                    'No more transactions',
                    style: TextStyle(color: Colors.grey),
                  ),
      ),
    );
  }
}
