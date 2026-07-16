import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_header.dart';
import 'filter_chips_row.dart';
import 'request_item_card.dart';
import 'requests_summary_chart.dart';
import 'status_cards_row.dart';

class RequestsBody extends StatelessWidget {
  const RequestsBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const CustomHeader(
            name: 'حاتم سليمان',
            role: 'صباح الخير،',
            textColor: Color(0xFF4A4499),
            subtitleColor: Colors.grey,
            iconColor: Color(0xFF4A4499),
            iconBgColor: Colors.white,
            notificationCount: 1, // Just a placeholder count to show the dot
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
          // List of requests
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const RequestItemCard(
                  name: 'حاتم سليمان',
                  requestId: '#REQ-10255',
                  date: '2026-01-25',
                  status: 'جاري المراجعة',
                  currentStep: 1, 
                ),
                const SizedBox(height: 16),
                const RequestItemCard(
                  name: 'أحمد محمود',
                  requestId: '#REQ-10256',
                  date: '2026-01-26',
                  status: 'انتظار تسليم المبلغ',
                  currentStep: 3, 
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
