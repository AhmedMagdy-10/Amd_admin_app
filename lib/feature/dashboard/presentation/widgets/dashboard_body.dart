import 'package:flutter/material.dart';
import 'collection_progress_card.dart';
import 'dashboard_header.dart';
import 'date_selector_widget.dart';
import 'loans_summary_section.dart';
import 'payments_summary_cards.dart';
import 'requests_status_section.dart';

class DashboardBody extends StatelessWidget {
  const DashboardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
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
                    DashboardHeader(),
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
    );
  }
}
