import '../data/models/payment_model.dart';

abstract class PaymentsState {}

class PaymentsInitial  extends PaymentsState {}
class PaymentsLoading  extends PaymentsState {}

class PaymentsLoaded extends PaymentsState {
  final List<PaymentModel> allPayments;
  final String selectedFilter;

  PaymentsLoaded(this.allPayments, {this.selectedFilter = 'الكل'});
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
