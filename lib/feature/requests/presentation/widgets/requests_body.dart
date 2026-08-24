import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/widgets/custom_header.dart';
import '../../logic/requests_cubit.dart';
import '../../logic/requests_state.dart';
import 'filter_chips_row.dart';
import 'request_item_card.dart';
import 'requests_summary_chart.dart';
import 'status_cards_row.dart';

class RequestsBody extends StatelessWidget {
  const RequestsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFF4A4499),
      backgroundColor: Colors.white,
      onRefresh: () => context.read<RequestsCubit>().refresh(),
      child: BlocBuilder<RequestsCubit, RequestsState>(
        builder: (context, state) {
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const CustomHeader(
                      name: 'حاتم سليمان',
                      role: 'صباح الخير،',
                      textColor: Color(0xFF4A4499),
                      subtitleColor: Colors.grey,
                      iconColor: Color(0xFF4A4499),
                      iconBgColor: Colors.white,
                      notificationCount: 1,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: RequestsSummaryChart(),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: StatusCardsRow(),
                    ),
                    const SizedBox(height: 16),
                    const FilterChipsRow(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              if (state is RequestsLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4A4499),
                      ),
                    ),
                  ),
                )
              else if (state is RequestsError)
                SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      'حدث خطأ: ${state.message}',
                      style: const TextStyle(
                        fontFamily: 'ReadexPro',
                        color: Colors.red,
                      ),
                    ),
                  ),
                )
              else if (state is RequestsLoaded)
                if (state.requests.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: _EmptyState(filter: state.selectedFilter),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final model = state.requests[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: RequestItemCard(
                              name: model.name,
                              docId: model.id,
                              collection: model.collection,
                              displayId: model.requestId,
                              date: model.date,
                              status: model.status,
                              currentStep: model.currentStep,
                            ),
                          );
                        },
                        childCount: state.requests.length,
                      ),
                    ),
                  ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Empty state widget ────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String filter;

  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final message = filter == 'الكل'
        ? 'لا توجد أي طلبات مسجلة حالياً'
        : 'لا توجد طلبات تحت تصنيف "$filter" حالياً';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/No Item Found.json',
            height: 180,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.cloud_off, size: 48, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'ReadexPro',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
