import 'package:amd_admin/core/utils/app_text_styles.dart';
import 'package:amd_admin/feature/home/widgets/app_icons.dart';
import 'package:amd_admin/feature/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentsSummaryCards extends StatelessWidget {
  const PaymentsSummaryCards({super.key});

  String _formatAmount(double amount) {
    if (amount >= 1000) {
      return (amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 1) + 'k';
    }
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        String todayTotalStr = '0';
        String monthTotalStr = '0';

        if (state is DashboardLoaded) {
          todayTotalStr = _formatAmount(state.todayPaymentsTotal);
          monthTotalStr = _formatAmount(state.monthPaymentsTotal);
        } else if (state is DashboardLoading) {
          todayTotalStr = '...';
          monthTotalStr = '...';
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              // Today's Payments (Right in RTL)
              Expanded(
                child: _buildCard(
                  title: 'دفعات اليوم',
                  amount: todayTotalStr,
                  currency: 'ر.س',
                  iconColor: const Color(0xFF4A4499),
                  svgString: AppIcons.todayPayments,
                ),
              ),
              const SizedBox(width: 16),
              // Month's Payments (Left in RTL)
              Expanded(
                child: _buildCard(
                  title: 'دفعات الشهر',
                  amount: monthTotalStr,
                  currency: 'ر.س',
                  iconColor: const Color(0xFF2ECA7D),
                  svgString: AppIcons.monthPayments,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard({
    required String title,
    required String amount,
    required String currency,
    required Color iconColor,
    required String svgString,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomNavIcon(
              svgString: svgString,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.readexMedium14.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: AppTextStyles.readexMedium32.copyWith(
                    color: const Color(0xFF4A4499),
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 6.0,
                  ), // increased padding slightly for larger font
                  child: Text(
                    currency,
                    style: AppTextStyles.readexMedium12.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
