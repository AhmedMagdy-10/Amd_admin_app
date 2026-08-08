import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../requests/data/repositories/requests_repository.dart';
import '../../../payments/data/repositories/payments_repository.dart';
import '../../../requests/data/models/request_model.dart';
import '../../../payments/data/models/payment_model.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final RequestsRepository _requestsRepo = RequestsRepository.instance;
  final PaymentsRepository _paymentsRepo = PaymentsRepository.instance;

  StreamSubscription? _requestsSub;
  StreamSubscription? _paymentsSub;
  
  List<RequestModel> _requests = [];
  List<PaymentModel> _payments = [];

  DashboardCubit() : super(const DashboardInitial());

  void fetchDashboardStats() {
    emit(const DashboardLoading());

    // Ensure repositories are initialized so their streams have data
    _requestsRepo.init();
    _paymentsRepo.init();

    _requests = _requestsRepo.cached;
    _recalculateStats();

    _requestsSub?.cancel();
    _requestsSub = _requestsRepo.stream.listen((requests) {
      _requests = requests;
      _recalculateStats();
    });

    _paymentsSub?.cancel();
    _paymentsSub = _paymentsRepo.stream.listen((payments) {
      _payments = payments;
      _recalculateStats();
    });
  }

  Future<void> refresh() async {
    await _requestsRepo.refresh();
    await _paymentsRepo.refresh();
  }

  void _recalculateStats() {
    if (isClosed) return;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    double todayTotal = 0.0;
    double monthTotal = 0.0;
    double totalCollected = 0.0;

    for (var p in _payments) {
      if (p.status == 'approved') {
        totalCollected += p.amount;
        if (p.approvedAt != null) {
          if (p.approvedAt!.isAfter(startOfMonth) && p.approvedAt!.isBefore(endOfMonth)) {
            monthTotal += p.amount;
          }
          if (p.approvedAt!.isAfter(startOfDay) && p.approvedAt!.isBefore(endOfDay)) {
            todayTotal += p.amount;
          }
        }
      }
    }

    int reqCount = 0;
    int underReviewCount = 0;
    int paidLoans = 0;
    int unpaidLoans = 0;
    double outstandingSum = 0.0;

    for (var r in _requests) {
      if (r.status == 'eligibility_pending' || r.status == 'pending' || r.currentStep == 1) {
        reqCount++;
      } else if (r.status == 'under_review') {
        underReviewCount++;
      } else if (r.status == 'approved' || r.status == 'loan_active' || r.outstandingBalance > 0) {
        // If a request is approved and payments are generated, it becomes a loan
        // Some old requests might not have outstandingBalance yet, but we'll use it if present
        if (r.outstandingBalance <= 0 && (r.status == 'approved' || r.status == 'loan_active')) {
          paidLoans++;
        } else if (r.outstandingBalance > 0) {
          unpaidLoans++;
          outstandingSum += r.outstandingBalance;
        }
      }
    }

    emit(DashboardLoaded(
      todayPaymentsTotal: todayTotal,
      monthPaymentsTotal: monthTotal,
      requestsCount: reqCount,
      underReviewRequestsCount: underReviewCount,
      paidLoansCount: paidLoans,
      unpaidLoansCount: unpaidLoans,
      totalCollectedAmount: totalCollected,
      totalTargetAmount: totalCollected + outstandingSum,
    ));
  }

  @override
  Future<void> close() {
    _requestsSub?.cancel();
    _paymentsSub?.cancel();
    return super.close();
  }
}
