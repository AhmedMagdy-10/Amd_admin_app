import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/custom_header.dart';
import '../logic/payments_cubit.dart';
import '../logic/payments_state.dart';
import 'widgets/user_payments_group_card.dart';

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

class _PaymentsContent extends StatelessWidget {
  const _PaymentsContent();

  static const _filters = ['الكل', 'قيد المراجعة', 'مسددة', 'مرفوضة'];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5FB),
        body: SafeArea(
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
                  
                  final groups = UserPaymentsGroup.groupPayments(state.allPayments);
                  final underReview = groups.where((g) => g.status == 'under_review').length;
                  final approved = groups.where((g) => g.status == 'approved').length;
                  
                  final total = state.allPayments.fold<double>(
                    0,
                    (sum, p) => p.status == 'approved' ? sum + p.amount : sum,
                  );
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
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
                              label: 'قيد المراجعة',
                              value: '$underReview',
                              icon: Icons.hourglass_top_rounded,
                              color: const Color(0xFFFFB03A),
                            ),
                            const SizedBox(width: 10),
                            _SummaryCard(
                              label: 'مسددة',
                              value: '$approved',
                              icon: Icons.check_circle_rounded,
                              color: const Color(0xFF2ECA7D),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              // ── Filter chips ────────────────────────────────────────────────
              BlocBuilder<PaymentsCubit, PaymentsState>(
                builder: (context, state) {
                  final selected = state is PaymentsLoaded
                      ? state.selectedFilter
                      : 'الكل';
                  return SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemCount: _filters.length,
                      itemBuilder: (context, i) {
                        final f = _filters[i];
                        final isSelected = f == selected;
                        return GestureDetector(
                          onTap: () =>
                              context.read<PaymentsCubit>().changeFilter(f),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
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
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // ── List ────────────────────────────────────────────────────────
              Expanded(
                child: BlocBuilder<PaymentsCubit, PaymentsState>(
                  builder: (context, state) {
                    if (state is PaymentsLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF4A4499)),
                      );
                    }
                    if (state is PaymentsError) {
                      return Center(
                        child: Text(state.message,
                            style: const TextStyle(color: Colors.red)),
                      );
                    }
                    if (state is PaymentsLoaded) {
                      final allGroups = UserPaymentsGroup.groupPayments(state.allPayments);
                      final list = UserPaymentsGroup.filterGrouped(allGroups, state.selectedFilter);
                      if (list.isEmpty) {
                        return _EmptyPayments(filter: state.selectedFilter);
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: list.length,
                        itemBuilder: (context, index) =>
                            UserPaymentsGroupCard(group: list[index]),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
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
                  Text(label,
                      style: TextStyle(
                          fontFamily: 'ReadexPro',
                          fontSize: 12,
                          color: Colors.grey.shade500)),
                  Text(value,
                      style: TextStyle(
                          fontFamily: 'ReadexPro',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: color)),
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
  const _EmptyPayments({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF4A4499).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.payments_outlined,
                size: 38, color: Color(0xFF4A4499)),
          ),
          const SizedBox(height: 16),
          Text(
            filter == 'الكل'
                ? 'لا توجد دفعات بعد'
                : 'لا توجد دفعات في تصنيف "$filter"',
            style: const TextStyle(
              fontFamily: 'ReadexPro',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
