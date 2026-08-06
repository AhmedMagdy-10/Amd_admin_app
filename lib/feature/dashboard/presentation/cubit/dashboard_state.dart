part of 'dashboard_cubit.dart';

abstract class DashboardState {
  const DashboardState();
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final double todayPaymentsTotal;
  final double monthPaymentsTotal;
  final int requestsCount;
  final int underReviewRequestsCount;
  final int paidLoansCount;
  final int unpaidLoansCount;
  final double totalCollectedAmount;
  final double totalTargetAmount;

  const DashboardLoaded({
    required this.todayPaymentsTotal,
    required this.monthPaymentsTotal,
    required this.requestsCount,
    required this.underReviewRequestsCount,
    required this.paidLoansCount,
    required this.unpaidLoansCount,
    required this.totalCollectedAmount,
    required this.totalTargetAmount,
  });
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
}
