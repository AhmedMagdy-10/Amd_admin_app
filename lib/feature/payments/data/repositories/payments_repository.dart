import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';

/// Repository that listens to the top-level `payments` collection in Firestore.
/// Provides a broadcast stream so multiple cubits can subscribe.
class PaymentsRepository {
  PaymentsRepository._();
  static final PaymentsRepository instance = PaymentsRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final StreamController<List<PaymentModel>> _controller =
      StreamController<List<PaymentModel>>.broadcast();

  StreamSubscription<QuerySnapshot>? _sub;

  Stream<List<PaymentModel>> get stream => _controller.stream;

  void init() {
    _sub?.cancel();
    _sub = _firestore
        .collection('payments')
        .orderBy('dueDate', descending: false)
        .snapshots()
        .listen(
          (snap) {
            final list = snap.docs
                .map((d) => PaymentModel.fromFirestore(
                      d.id,
                      d.data(),
                    ))
                .toList();
            _controller.add(list);
          },
          onError: _controller.addError,
        );
  }

  /// Approve a payment receipt — sets status to `approved`.
  Future<void> approvePayment(String paymentId) {
    return _firestore.collection('payments').doc(paymentId).update({
      'status':     'approved',
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Reject a payment receipt — sets status back to `pending`.
  Future<void> rejectPayment(String paymentId) {
    return _firestore.collection('payments').doc(paymentId).update({
      'status':     'rejected',
      'receiptUrl': null,
    });
  }

  /// Generate N monthly payment documents for a newly approved request.
  Future<void> generatePayments({
    required String requestId,
    required String collection,
    required String userName,
    required double monthlyAmount,
    required int months,
  }) async {
    final batch = _firestore.batch();
    final now = DateTime.now();

    for (int i = 1; i <= months; i++) {
      final dueDate = DateTime(now.year, now.month + i, now.day);
      final ref = _firestore.collection('payments').doc();
      final model = PaymentModel(
        id:            ref.id,
        requestId:     requestId,
        collection:    collection,
        userName:      userName,
        paymentNumber: i,
        amount:        monthlyAmount,
        dueDate:       dueDate,
        status:        'pending',
      );
      batch.set(ref, model.toFirestore());
    }

    await batch.commit();
  }

  void dispose() {
    _sub?.cancel();
    _controller.close();
  }
}
