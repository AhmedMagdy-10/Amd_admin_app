import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/firebase_messaging_service.dart';
import '../data/models/payment_model.dart';
import '../data/repositories/payments_repository.dart';
import 'payments_state.dart';

class PaymentsCubit extends Cubit<PaymentsState> {
  final PaymentsRepository _repository;
  StreamSubscription<List<PaymentModel>>? _sub;

  PaymentsCubit({PaymentsRepository? repository})
      : _repository = repository ?? PaymentsRepository.instance,
        super(PaymentsInitial());

  void init() {
    emit(PaymentsLoading());
    _repository.init();
    _sub = _repository.stream.listen(
      (payments) {
        final currentFilter = state is PaymentsLoaded
            ? (state as PaymentsLoaded).selectedFilter
            : state is PaymentActionLoading
                ? (state as PaymentActionLoading).selectedFilter
                : 'الكل';
        emit(PaymentsLoaded(payments, selectedFilter: currentFilter));
      },
      onError: (Object e) => emit(PaymentsError(e.toString())),
    );
  }

  void changeFilter(String filter) {
    if (state is PaymentsLoaded) {
      emit(PaymentsLoaded(
        (state as PaymentsLoaded).allPayments,
        selectedFilter: filter,
      ));
    }
  }

  Future<void> approvePayment(PaymentModel payment) async {
    try {
      await _repository.approvePayment(payment);

      // Trigger FCM notification asynchronously to not block UI
      unawaited(() async {
        try {
          final clientId = await FirebaseMessagingService().getClientIdFromRequest(
            payment.requestId,
            payment.collection,
          );
          if (clientId != null) {
            await FirebaseMessagingService().sendPaymentApprovedNotification(
              clientId: clientId,
              installmentNum: payment.paymentNumber,
            );
          }
        } catch (e) {
          print('FCM Payment Approved Notification Error: $e');
        }
      }());
    } catch (e) {
      emit(PaymentsError(e.toString()));
    }
  }

  Future<void> rejectPayment(PaymentModel payment) async {
    try {
      await _repository.rejectPayment(payment.id);

      // Trigger FCM notification asynchronously to not block UI
      unawaited(() async {
        try {
          final clientId = await FirebaseMessagingService().getClientIdFromRequest(
            payment.requestId,
            payment.collection,
          );
          if (clientId != null) {
            await FirebaseMessagingService().sendPaymentRejectedNotification(
              clientId: clientId,
              installmentNum: payment.paymentNumber,
            );
          }
        } catch (e) {
          print('FCM Payment Rejected Notification Error: $e');
        }
      }());
    } catch (e) {
      emit(PaymentsError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
