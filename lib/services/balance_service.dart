import '../models/expense_model.dart';
import '../models/user_model.dart';
import 'package:flutter/material.dart';

class BalanceService {
  /// Net borç matrisini hesapla
  /// Tüm harcamalardan kişilerin birbirlerine borçlu olduğu miktarları bulur
  static BalanceResult calculateBalance(
    List<Expense> expenses,
    List<String> participantIds,
  ) {
    // Her kişinin toplam harcaması ve borcunu tutuşturması
    final Map<String, double> totalSpent = {};
    final Map<String, double> totalOwed = {};

    // Başlangıçta herkesi 0 ile init et
    for (final id in participantIds) {
      totalSpent[id] = 0;
      totalOwed[id] = 0;
    }

    // Harcamaları işle
    for (final expense in expenses) {
      // Ödeyen kişi
      totalSpent[expense.paidBy] = (totalSpent[expense.paidBy] ?? 0) + expense.amount;

      // Harcamaya katılanlar
      final perPerson = expense.amount / expense.splitBetween.length;
      for (final userId in expense.splitBetween) {
        totalOwed[userId] = (totalOwed[userId] ?? 0) + perPerson;
      }
    }

    // Net hesapla (kim ne kadar alacaklandırılacak veya borçlandırılacak)
    final Map<String, double> netBalance = {};
    for (final id in participantIds) {
      netBalance[id] = (totalSpent[id] ?? 0) - (totalOwed[id] ?? 0);
    }

    // Dengeleme işlemi - kimin kime ne kadar ödeyeceğini hesapla
    final List<Transaction> transactions = _calculateTransactions(
      netBalance,
      participantIds,
    );

    return BalanceResult(
      totalSpent: totalSpent,
      totalOwed: totalOwed,
      netBalance: netBalance,
      transactions: transactions,
    );
  }

  /// Minimum işlem sayısıyla dengelemeyi hesapla
  static List<Transaction> _calculateTransactions(
    Map<String, double> netBalance,
    List<String> participantIds,
  ) {
    final List<Transaction> transactions = [];
    
    // Borçlular ve alacaklıları ayır
    final List<_Person> creditors = [];
    final List<_Person> debtors = [];

    for (final id in participantIds) {
      final balance = netBalance[id] ?? 0;
      
      if (balance > 0.01) { // Pozitif = alacaklı
        creditors.add(_Person(id: id, amount: balance));
      } else if (balance < -0.01) { // Negatif = borçlu
        debtors.add(_Person(id: id, amount: -balance));
      }
    }

    // Greedy algoritma: en yüksek borç/alacakla başla
    int debtorIdx = 0;
    int creditorIdx = 0;

    while (debtorIdx < debtors.length && creditorIdx < creditors.length) {
      final debtor = debtors[debtorIdx];
      final creditor = creditors[creditorIdx];

      final amount = debtor.amount < creditor.amount ? debtor.amount : creditor.amount;

      transactions.add(
        Transaction(
          from: debtor.id,
          to: creditor.id,
          amount: amount,
        ),
      );

      debtor.amount -= amount;
      creditor.amount -= amount;

      if (debtor.amount < 0.01) debtorIdx++;
      if (creditor.amount < 0.01) creditorIdx++;
    }

    return transactions;
  }

  /// Kişi bazında özet al
  static Map<String, PersonSummary> getPersonSummary(
    List<Expense> expenses,
    List<User> users,
  ) {
    final Map<String, PersonSummary> summaries = {};

    for (final user in users) {
      final userExpenses = expenses.where((e) => e.paidBy == user.id).toList();
      final involvedExpenses = expenses
          .where((e) => e.splitBetween.contains(user.id))
          .toList();

      double totalPaid = userExpenses.fold(0, (sum, e) => sum + e.amount);
      double totalShare = involvedExpenses.fold(
        0,
        (sum, e) => sum + (e.amount / e.splitBetween.length),
      );

      summaries[user.id] = PersonSummary(
        userId: user.id,
        userName: user.fullName,
        totalPaid: totalPaid,
        totalShare: totalShare,
        balance: totalPaid - totalShare,
      );
    }

    return summaries;
  }

  /// Kategori bazında harcama özeti
  static Map<String, double> getCategoryExpenseSummary(
    List<Expense> expenses,
  ) {
    final Map<String, double> categories = {};

    for (final expense in expenses) {
      categories[expense.category] =
          (categories[expense.category] ?? 0) + expense.amount;
    }

    return categories;
  }

  /// Harcamaları tarihe göre grupla
  static Map<String, List<Expense>> groupExpensesByDate(
    List<Expense> expenses,
  ) {
    final Map<String, List<Expense>> grouped = {};

    for (final expense in expenses) {
      final dateKey =
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}-${expense.date.day.toString().padLeft(2, '0')}';
      
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(expense);
    }

    return grouped;
  }

  /// Günlük ortalama harcama
  static double getDailyAverageExpense(List<Expense> expenses) {
    if (expenses.isEmpty) return 0;

    final unique = <String>{};
    for (final expense in expenses) {
      unique.add(
          '${expense.date.year}-${expense.date.month}-${expense.date.day}');
    }

    final totalAmount = expenses.fold(0.0, (sum, e) => sum + e.amount);
    return totalAmount / unique.length;
  }

  /// En pahalı gün
  static ExpenseDay? getMostExpensiveDay(List<Expense> expenses) {
    if (expenses.isEmpty) return null;

    final grouped = groupExpensesByDate(expenses);
    double maxAmount = 0;
    String? maxDate;

    grouped.forEach((date, expenseList) {
      final total = expenseList.fold(0.0, (sum, e) => sum + e.amount);
      if (total > maxAmount) {
        maxAmount = total;
        maxDate = date;
      }
    });

    return maxDate != null ? ExpenseDay(date: maxDate!, amount: maxAmount) : null;
  }

  /// En ucuz gün
  static ExpenseDay? getCheapestDay(List<Expense> expenses) {
    if (expenses.isEmpty) return null;

    final grouped = groupExpensesByDate(expenses);
    double minAmount = double.infinity;
    String? minDate;

    grouped.forEach((date, expenseList) {
      final total = expenseList.fold(0.0, (sum, e) => sum + e.amount);
      if (total < minAmount) {
        minAmount = total;
        minDate = date;
      }
    });

    return minDate != null ? ExpenseDay(date: minDate!, amount: minAmount) : null;
  }

  /// En çok harcayan kişi
  static String? getTopSpender(List<Expense> expenses) {
    if (expenses.isEmpty) return null;

    final Map<String, double> spent = {};

    for (final expense in expenses) {
      spent[expense.paidBy] = (spent[expense.paidBy] ?? 0) + expense.amount;
    }

    String? topSpender;
    double maxAmount = 0;

    spent.forEach((userId, amount) {
      if (amount > maxAmount) {
        maxAmount = amount;
        topSpender = userId;
      }
    });

    return topSpender;
  }

  /// Kategori bazında en pahalı
  static String? getMostExpensiveCategory(List<Expense> expenses) {
    if (expenses.isEmpty) return null;

    final categories = getCategoryExpenseSummary(expenses);
    double maxAmount = 0;
    String? expensiveCategory;

    categories.forEach((category, amount) {
      if (amount > maxAmount) {
        maxAmount = amount;
        expensiveCategory = category;
      }
    });

    return expensiveCategory;
  }
}

// Yardımcı sınıflar
class _Person {
  final String id;
  double amount;

  _Person({
    required this.id,
    required this.amount,
  });
}

class BalanceResult {
  final Map<String, double> totalSpent;
  final Map<String, double> totalOwed;
  final Map<String, double> netBalance;
  final List<Transaction> transactions;

  BalanceResult({
    required this.totalSpent,
    required this.totalOwed,
    required this.netBalance,
    required this.transactions,
  });
}

class Transaction {
  final String from; // Borçlu (ödeyecek)
  final String to; // Alacaklı (alacak)
  final double amount;

  Transaction({
    required this.from,
    required this.to,
    required this.amount,
  });

  String get formattedAmount => amount.toStringAsFixed(2);
}

class PersonSummary {
  final String userId;
  final String userName;
  final double totalPaid;
  final double totalShare;
  final double balance; // Pozitif = alacaklı, Negatif = borçlu

  PersonSummary({
    required this.userId,
    required this.userName,
    required this.totalPaid,
    required this.totalShare,
    required this.balance,
  });

  bool get isCreditor => balance > 0;
  bool get isDebtor => balance < 0;
  bool get isEven => balance.abs() < 0.01;

  String get balanceStatus {
    if (isCreditor) {
      return '₺${balance.toStringAsFixed(2)} alacaklandırılacak';
    } else if (isDebtor) {
      return '₺${(-balance).toStringAsFixed(2)} borçlandırılacak';
    } else {
      return 'Hesap temiz';
    }
  }
}

class ExpenseDay {
  final String date;
  final double amount;

  ExpenseDay({
    required this.date,
    required this.amount,
  });

  String get formattedAmount => amount.toStringAsFixed(2);
}
