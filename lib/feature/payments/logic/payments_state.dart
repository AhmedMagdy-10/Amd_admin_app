import '../data/models/payment_model.dart';

abstract class PaymentsState {}

class PaymentsInitial  extends PaymentsState {}
class PaymentsLoading  extends PaymentsState {}

class PaymentsLoaded extends PaymentsState {
  final List<PaymentModel> allPayments;
  final String selectedFilter; // الكل | قيد المراجعة | مسددة | مرفوضة

  PaymentsLoaded(this.allPayments, {this.selectedFilter = 'الكل'});

  List<PaymentModel> get payments {
    if (selectedFilter == 'الكل') return allPayments;
    final statusMap = {
      'قيد المراجعة': 'under_review',
      'مسددة':        'approved',
      'مرفوضة':       'rejected',
    };
    final target = statusMap[selectedFilter];
    if (target == null) return allPayments;
    return allPayments.where((p) => p.status == target).toList();
  }
}

class PaymentsError extends PaymentsState {
  final String message;
  PaymentsError(this.message);
}

class PaymentActionLoading extends PaymentsState {
  final List<PaymentModel> allPayments;
  final String selectedFilter;
  PaymentActionLoading(this.allPayments, {this.selectedFilter = 'الكل'});
}
