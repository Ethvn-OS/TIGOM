import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tigom_app/models/goal.dart';

class SupabaseService {
  static final _client = Supabase.instance.client;

  static String get currentUserId => _client.auth.currentUser!.id;

  // ACCOUNTS
  static Future<List<Map<String, dynamic>>> getAccounts() async {
    final res = await _client
        .from('accounts')
        .select()
        .eq('user_id', currentUserId);
    return List<Map<String, dynamic>>.from(res);
  }

  static Future<void> upsertAccount({
    required String accountId,
    required String accountType,
    required double balance,
  }) async {
    await _client.from('accounts').upsert({
      'account_id': accountId,
      'user_id': currentUserId,
      'account_type': accountType,
      'balance': balance,
    });
  }

  // GOALS
  static Future<List<Goal>> getGoals() async {
    final res = await _client
        .from('goals')
        .select()
        .eq('user_id', currentUserId)
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(res)
        .map((g) => Goal.fromMap(g))
        .toList();
  }

  static Future<void> upsertGoal({
    required String goalId,
    required String title,
    required double targetAmount,
    required double currentAmount,
    required String goalDate,
    String status = 'active',
  }) async {
    await _client.from('goals').upsert({
      'goal_id': goalId,
      'user_id': currentUserId,
      'title': title,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'goal_date': goalDate,
      'status': status,
    });
  }

  static Future<void> deleteGoal(String goalId) async {
    await _client.from('goals').delete().eq('goal_id', goalId);
  }

  // TRANSACTIONS
  static Future<List<Map<String, dynamic>>> getTransactions() async {
    final res = await _client
        .from('transactions')
        .select('*, categories(name)')
        .eq('user_id', currentUserId)
        .order('transaction_date', ascending: false)
        .limit(50);
    return List<Map<String, dynamic>>.from(res);
  }

  static Future<List<Map<String, dynamic>>> getRecentTransactions() async {
    final now = DateTime.now();
    final firstOfMonth =
        DateTime(now.year, now.month, 1).toIso8601String();
    final res = await _client
        .from('transactions')
        .select('*, categories(name)')
        .eq('user_id', currentUserId)
        .gte('transaction_date', firstOfMonth)
        .order('transaction_date', ascending: false)
        .limit(3);
    return List<Map<String, dynamic>>.from(res);
  }

  static Future<double> getMonthlySpending() async {
    final now = DateTime.now();
    final firstOfMonth =
        DateTime(now.year, now.month, 1).toIso8601String();
    final res = await _client
        .from('transactions')
        .select('amount')
        .eq('user_id', currentUserId)
        .eq('type', 'expense')
        .gte('transaction_date', firstOfMonth);
    final list = List<Map<String, dynamic>>.from(res);
    return list.fold<double>(
  0.0,
  (sum, t) => sum + (t['amount'] as num).toDouble(),
);
  }

  // CATEGORIES
  static Future<List<Map<String, dynamic>>> getCategories() async {
    final res = await _client.from('categories').select();
    return List<Map<String, dynamic>>.from(res);
  }

  // PROFILE
static Future<Map<String, dynamic>?> getProfile() async {
  final res = await _client
      .from('users')
      .select()
      .eq('user_id', currentUserId)
      .maybeSingle();
  return res;
}

static Future<void> updateProfile({
  required String name,
  required String email,
  String? phone,
}) async {
   await _client.from('users').update({
    'name': name,
    'email': email,
    'phone': phone ?? '',
  }).eq('user_id', currentUserId); 
}

static Future<void> updatePassword(String newPassword) async {
  await _client.auth.updateUser(
    UserAttributes(password: newPassword),
  );
}

static Future<void> logout() async {
  await _client.auth.signOut();
}
}