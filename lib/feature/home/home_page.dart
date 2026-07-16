import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../feature/dashboard/presentation/dashboard_view.dart';
import '../../feature/requests/presentation/requests_view.dart';
import 'logic/home_cubit.dart';
import 'widgets/custom_bottom_nav_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: const _HomeContent(),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({Key? key}) : super(key: key);

  final List<Widget> _views = const [
    DashboardView(),
    const RequestsView(),
    const Center(child: Text('المدفوعات (Payments)')),
    Center(child: Text('الأعدادات (Settings)')),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: SafeArea(child: _views[state.selectedIndex]),
          bottomNavigationBar: CustomBottomNavBar(
            selectedIndex: state.selectedIndex,
            onItemSelected: (index) {
              context.read<HomeCubit>().changeTab(index);
            },
          ),
        );
      },
    );
  }
}
