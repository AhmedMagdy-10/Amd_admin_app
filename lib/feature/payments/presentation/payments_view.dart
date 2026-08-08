import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/custom_header.dart';
import '../logic/payments_cubit.dart';
import '../logic/payments_state.dart';
import 'widgets/user_payments_group_card.dart';
import 'package:lottie/lottie.dart';

class PaymentsView extends StatelessWidget {
  const PaymentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PaymentsCubit()..init(),
      child: const _PaymentsContent(),
    );
  }
}

class _PaymentsContent extends StatefulWidget {
  const _PaymentsContent();

  @override
  State<_PaymentsContent> createState() => _PaymentsContentState();
}

class _PaymentsContentState extends State<_PaymentsContent> {
  static const _filters = ['الكل', 'مسددة', 'مرفوضة'];
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5FB),
        body: SafeArea(
          child: RefreshIndicator(
            color: const Color(0xFF4A4499),
            backgroundColor: Colors.white,
            onRefresh: () => context.read<PaymentsCubit>().refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // ── Header ─────────────────────────────────────────────────────
                  const CustomHeader(
                    name: 'حاتم سليمان',
                    role: 'الدفعات',
                    textColor: Color(0xFF4A4499),
                    subtitleColor: Colors.grey,
                    iconColor: Color(0xFF4A4499),
                    iconBgColor: Colors.white,
                    notificationCount: 0,
                  ),

                  // ── Summary strip ───────────────────────────────────────────────
                  BlocBuilder<PaymentsCubit, PaymentsState>(
                    builder: (context, state) {
                      if (state is! PaymentsLoaded) return const SizedBox.shrink();

                      final groups = UserPaymentsGroup.groupPayments(
                        state.allPayments,
                      );
                      final rejected = groups
                          .where((g) => g.status == 'rejected')
                          .length;
                      final approved = groups
                          .where((g) => g.status == 'approved')
                          .length;

                      final total = state.allPayments.fold<double>(
                        0,
                        (sum, p) => p.status == 'approved' ? sum + p.amount : sum,
                      );
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                _SummaryCard(
                                  label: 'إجمالي المحصّل',
                                  value: 'ر.س ${total.toStringAsFixed(0)}',
                                  icon: Icons.account_balance_wallet_rounded,
                                  color: const Color(0xFF4A4499),
                                  wide: true,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _SummaryCard(
                                  label: 'مسددة',
                                  value: '$approved',
                                  icon: Icons.check_circle_rounded,
                                  color: const Color(0xFF2ECA7D),
                                ),
                                const SizedBox(width: 10),
                                _SummaryCard(
                                  label: 'مرفوضة',
                                  value: '$rejected',
                                  icon: Icons.cancel_rounded,
                                  color: const Color(0xFFE94B4B),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // ── Filter Chips ────────────────────────────────────────────────
                  BlocBuilder<PaymentsCubit, PaymentsState>(
                    builder: (context, state) {
                      String selectedFilter = 'الكل';
                      if (state is PaymentsLoaded) {
                        selectedFilter = state.selectedFilter;
                      } else if (state is PaymentActionLoading) {
                        selectedFilter = state.selectedFilter;
                      }

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: _filters.asMap().entries.map((e) {
                            final i = e.key;
                            final f = e.value;
                            final isSelected = selectedFilter == f;

                            return IntrinsicWidth(
                              child: Padding(
                                padding: EdgeInsets.only(left: i < _filters.length - 1 ? 10.0 : 0.0),
                                child: GestureDetector(
                                  onTap: () =>
                                      context.read<PaymentsCubit>().changeFilter(f),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF4A4499)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF4A4499)
                                            : const Color(0xFFE0E0E8),
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF4A4499).withValues(alpha: 0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              )
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        f,
                                        style: TextStyle(
                                          fontFamily: 'ReadexPro',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF7070A0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // ── Search Bar ──────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'ابحث عن عميل أو رقم طلب...',
                        hintStyle: TextStyle(
                          fontFamily: 'ReadexPro',
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Colors.grey.shade400,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── List ────────────────────────────────────────────────────────
                  BlocBuilder<PaymentsCubit, PaymentsState>(
                    builder: (context, state) {
                      if (state is PaymentsLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(
                              color: Color(0xFF4A4499),
                            ),
                          ),
                        );
                      }
                      if (state is PaymentsError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              state.message,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        );
                      }
                      if (state is PaymentsLoaded) {
                        final allGroups = UserPaymentsGroup.groupPayments(
                          state.allPayments,
                        );
                        var list = UserPaymentsGroup.filterGrouped(
                          allGroups,
                          state.selectedFilter,
                        );

                        if (_searchQuery.isNotEmpty) {
                          list = list.where((g) {
                            return g.userName.toLowerCase().contains(
                                  _searchQuery,
                                ) ||
                                g.requestId.toLowerCase().contains(_searchQuery);
                          }).toList();
                        }

                        if (list.isEmpty) {
                          return _EmptyPayments(
                            filter: state.selectedFilter,
                            searchQuery: _searchQuery,
                          );
                        }
                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          itemCount: list.length,
                          itemBuilder: (context, index) =>
                              UserPaymentsGroupCard(group: list[index]),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Summary Card ────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool wide;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: wide ? 2 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'ReadexPro',
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'ReadexPro',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ─────────────────────────────────────────────────────────────────

class _EmptyPayments extends StatelessWidget {
  final String filter;
  final String searchQuery;
  const _EmptyPayments({required this.filter, this.searchQuery = ''});

  @override
  Widget build(BuildContext context) {
    final message = searchQuery.isNotEmpty
        ? 'لا توجد نتائج بحث مطابقة لـ "$searchQuery"'
        : filter == 'الكل'
        ? 'لا توجد دفعات بعد'
        : 'لا توجد دفعات في تصنيف "$filter"';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/lottie/No Item Found.json',
              height: 180,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'ReadexPro',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
