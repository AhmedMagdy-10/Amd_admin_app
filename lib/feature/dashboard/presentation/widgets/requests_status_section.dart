import 'package:amd_admin/core/utils/app_text_styles.dart';
import 'package:amd_admin/feature/home/widgets/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/dashboard_cubit.dart';

class RequestsStatusSection extends StatelessWidget {
  const RequestsStatusSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        int underReview = 0;
        int newRequests = 0;

        if (state is DashboardLoaded) {
          underReview = state.underReviewRequestsCount;
          newRequests = state.requestsCount;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'حالة الطلبات الحالية',
                style: AppTextStyles.readexSemiBold20.copyWith(
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatusCard(
                title: 'طلبات تحت المراجعة',
                count: underReview.toString(),
                percentage: 'اليوم',
                iconColor: const Color(0xFFFF8A00),
                svgString: AppIcons.requestsReview,
              ),
              const SizedBox(height: 12),
              _buildStatusCard(
                title: 'طلبات جديدة',
                count: newRequests.toString(),
                percentage: 'اليوم',
                iconColor: const Color(0xFF2F5CBB),
                svgString: AppIcons.requestsNew,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String count,
    required String percentage,
    required Color iconColor,
    required String svgString,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Icon on the right (First in RTL)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
            ),
            child: CustomNavIcon(
              svgString: svgString,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Texts
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.readexMedium14.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            count,
                            style: AppTextStyles.readexMedium32.copyWith(
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.trending_up,
                                  color: Color(0xFF2ECA7D),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  percentage,
                                  style: AppTextStyles.readexMedium12.copyWith(
                                    color: const Color(0xFF2ECA7D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Arrow icon on the left (Last in RTL)
                Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
