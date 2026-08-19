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

  final Map<String, String> _userNamesCache = {};

  Stream<List<PaymentModel>> get stream => _controller.stream;

  Future<void> refresh() async {
    _sub?.cancel();
    init();
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  void init() {
    _sub?.cancel();
    _sub = _firestore.collectionGroup('installments').snapshots().listen((snap) async {
      final list = <PaymentModel>[];
      for (final doc in snap.docs) {
        final requestRef = doc.reference.parent.parent;
        if (requestRef == null) continue;

        final reqId = requestRef.id;

        String userName = _userNamesCache[reqId] ?? '';
        if (userName.isEmpty) {
          final reqDoc = await requestRef.get();
          if (reqDoc.exists) {
            final data = reqDoc.data() ?? {};
            // Try eligibilityData sub-map (old format)
            final eligibility = data['eligibilityData'] as Map<String, dynamic>?;
            final fName = (eligibility?['firstName'] ?? data['firstName'] ?? data['first_name'] ?? '').toString().trim();
            final lName = (eligibility?['lastName'] ?? data['lastName'] ?? data['last_name'] ?? '').toString().trim();
            userName = '$fName $lName'.trim();
            // Fallbacks for direct name fields (new customer app format)
            if (userName.isEmpty) {
              userName = (data['name'] ?? data['fullName'] ?? data['clientName'] ?? '').toString().trim();
            }
            if (userName.isEmpty) userName = 'بدون اسم';
          } else {
            userName = 'مستخدم غير معروف';
          }
          _userNamesCache[reqId] = userName;
        }

        final payment = PaymentModel.fromFirestore(doc.reference, doc.data(), userName);
        
        // Show payments that have an uploaded receipt OR are pending_review (customer app)
        // status: pending_review always means a receipt was uploaded waiting for admin
        final hasReceipt = payment.receiptUrl != null && payment.receiptUrl!.isNotEmpty;
        final isPendingReview = payment.status == 'pending_review';
        if (hasReceipt || isPendingReview) {
          list.add(payment);
        }
      }

      // Sort locally by due date since collection group query across parents might not be ordered.
      list.sort((a, b) => a.dueDate.compareTo(b.dueDate));

      if (!_controller.isClosed) {
        _controller.add(list);
      }
    }, onError: _controller.addError);
  }

  /// Approve a payment receipt — sets status to `approved`.
  Future<void> approvePayment(PaymentModel payment) async {
    final batch = _firestore.batch();

    // 1. Update the payment status
    final paymentRef = _firestore.doc(payment.path);
    batch.update(paymentRef, {
      'status': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
    });

    // 2. Deduct from customer's outstanding loan balance
    final requestRef = _firestore
        .collection(payment.collection)
        .doc(payment.requestId);
    batch.update(requestRef, {
      'outstandingBalance': FieldValue.increment(-payment.amount),
    });

    await batch.commit();
  }

  /// Reject a payment receipt — sets status to `rejected`.
  Future<void> rejectPayment(PaymentModel payment) async {
    final paymentRef = _firestore.doc(payment.path);
    await paymentRef.update({'status': 'rejected', 'receiptUrl': null});
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

    final totalAmount = monthlyAmount * months;

    // 1. Initialize outstanding balance on the request document
    final requestRef = _firestore.collection(collection).doc(requestId);
    batch.update(requestRef, {'outstandingBalance': totalAmount});

    // 2. Generate monthly payments
    for (int i = 1; i <= months; i++) {
      final dueDate = DateTime(now.year, now.month + i, now.day);
      final ref = requestRef.collection('installments').doc(i.toString());
      final model = PaymentModel(
        id: ref.id,
        path: ref.path,
        requestId: requestId,
        collection: collection,
        userName: userName,
        paymentNumber: i,
        amount: monthlyAmount,
        dueDate: dueDate,
        status: 'pending_payment',
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
