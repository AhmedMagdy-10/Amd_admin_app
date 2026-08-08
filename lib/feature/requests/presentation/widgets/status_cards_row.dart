import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../logic/requests_cubit.dart';
import '../../logic/requests_state.dart';

class StatusCardsRow extends StatelessWidget {
  const StatusCardsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequestsCubit, RequestsState>(
      builder: (context, state) {
        int inReview = 0;
        int submission = 0;
        int waiting = 0;
        int completed = 0;

        if (state is RequestsLoaded) {
          inReview = state.countInReview;
          submission = state.countSubmission;
          waiting = state.countWaitingTransfer;
          completed = state.countCompleted;
        }

        return Row(
          children: [
            Expanded(
              child: _buildStatusCard(
                icon: Icons.access_time,
                iconColor: const Color(0xFF7A6DFF),
                iconBgColor: const Color(0xFFF4F5F7),
                title: 'جاري المراجعة',
                count: '$inReview',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatusCard(
                icon: Icons.receipt_long,
                iconColor: const Color(0xFF7A6DFF),
                iconBgColor: const Color(0xFFEBEAF4),
                title: 'تقديم طلب',
                count: '$submission',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatusCard(
                icon: Icons.hourglass_empty,
                iconColor: const Color(0xFF7A6DFF),
                iconBgColor: const Color(0xFFF0EFFF),
                title: 'انتظار تسليم المبلغ',
                count: '$waiting',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatusCard(
                icon: Icons.check_circle_outline,
                iconColor: const Color(0xFF2ECA7D),
                iconBgColor: const Color(0xFFE8FAF0),
                title: 'مكتملة',
                count: '$completed',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: AppTextStyles.readexMedium10.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              count,
              style: AppTextStyles.readexMedium24.copyWith(
                color: const Color(0xFF2A2375),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
