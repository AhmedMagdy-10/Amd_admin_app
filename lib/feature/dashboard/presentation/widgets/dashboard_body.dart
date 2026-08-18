import 'package:amd_admin/feature/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:flutter/material.dart';
import 'collection_progress_card.dart';
import '../../../../core/widgets/custom_header.dart';
import 'date_selector_widget.dart';
import 'loans_summary_section.dart';
import 'payments_summary_cards.dart';
import 'requests_status_section.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardBody extends StatelessWidget {
  const DashboardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFF4A4499),
      backgroundColor: Colors.white,
      onRefresh: () => context.read<DashboardCubit>().refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Stack to hold the scrolling blue header and the top cards
            Stack(
              children: [
                // Blue Background that scrolls with the content
                Container(
                  height: 250,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4A4499),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Column(
                    children: const [
                      CustomHeader(
                        name: 'مرحبا، محمد احمد',
                        role: 'مدير النظام',
                        textColor: Colors.white,
                        subtitleColor: Colors.white70,
                        iconColor: Colors.white,
                        iconBgColor: Color(0x26FFFFFF),
                        notificationCount: 0,
                      ),
                      SizedBox(height: 16),
                      DateSelectorWidget(),
                      SizedBox(height: 24),
                      PaymentsSummaryCards(),
                    ],
                  ),
                ),
              ],
            ),
            // Remaining content below the blue header stack
            const RequestsStatusSection(),
            const LoansSummarySection(),
            const CollectionProgressCard(),
            const SizedBox(height: 40), // Padding for bottom nav
          ],
        ),
      ),
    );
  }
}
