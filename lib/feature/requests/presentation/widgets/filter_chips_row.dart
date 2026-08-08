import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../logic/requests_cubit.dart';
import '../../logic/requests_state.dart';

class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final filters = [
      'الكل',
      'جاري المراجعه',
      'تقديم الطلب',
      'انتظار تسليم المبلغ',
      'مكتملة',
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocBuilder<RequestsCubit, RequestsState>(
        builder: (context, state) {
          final selectedFilter = (state is RequestsLoaded)
              ? state.selectedFilter
              : 'الكل';

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: filters.map((title) {
                final isActive = title == selectedFilter;

                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      context.read<RequestsCubit>().changeFilter(title);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF2A2375) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive
                              ? const Color(0xFF2A2375)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        title,
                        style: AppTextStyles.readexMedium14.copyWith(
                          color: isActive ? Colors.white : Colors.black87,
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
    );
  }
}
