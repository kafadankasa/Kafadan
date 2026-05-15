import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense_model.dart';
import '../models/user_model.dart';
import '../services/balance_service.dart';
import 'expense_provider.dart';
import 'user_provider.dart';

final balanceProvider =
    FutureProvider.family<BalanceResult, String>((ref, tripId) async {
  final expenses = ref.watch(expensesProvider);
  final tripExpenses =
      expenses.where((e) => e.tripId == tripId).toList();

  return BalanceService.calculateBalance(tripExpenses, []);
});

final personSummaryProvider =
    FutureProvider.family<Map<String, PersonSummary>, String>((ref, tripId) async {
  final expenses = ref.watch(expensesProvider);
  final users = ref.watch(usersProvider);
  final tripExpenses =
      expenses.where((e) => e.tripId == tripId).toList();

  return BalanceService.getPersonSummary(tripExpenses, users);
});

final categoryExpenseSummaryProvider =
    FutureProvider.family<Map<String, double>, String>((ref, tripId) async {
  final expenses = ref.watch(expensesProvider);
  final tripExpenses =
      expenses.where((e) => e.tripId == tripId).toList();

  return BalanceService.getCategoryExpenseSummary(tripExpenses);
});
