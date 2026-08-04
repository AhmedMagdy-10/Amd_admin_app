import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/request_model.dart';
import '../data/repositories/requests_repository.dart';
import '../../payments/data/repositories/payments_repository.dart';
import 'requests_state.dart';

/// Thin cubit that subscribes to [RequestsRepository] and applies filter state.
///
/// Contains zero Firestore code — all data access is delegated to the repository.
class RequestsCubit extends Cubit<RequestsState> {
  final RequestsRepository _repository;

  StreamSubscription<List<RequestModel>>? _subscription;

  RequestsCubit({RequestsRepository? repository})
      : _repository = repository ?? RequestsRepository.instance,
        super(RequestsInitial());

  // ── Lifecycle ─────────────────────────────────────────────────────────────────

  /// Starts listening to the repository stream.
  ///
  /// If data is already cached (from a previous screen visit), it is emitted
  /// immediately — no loading spinner, no extra network call.
  void init() {
    // Emit cached data right away so the UI never shows a stale loading state
    if (_repository.hasData) {
      emit(RequestsLoaded(_repository.cached));
    } else {
      emit(RequestsLoading());
    }

    _subscription = _repository.stream.listen(
      (requests) {
        final currentFilter = state is RequestsLoaded
            ? (state as RequestsLoaded).selectedFilter
            : 'الكل';
        emit(RequestsLoaded(requests, selectedFilter: currentFilter));
      },
      onError: (Object error) => emit(RequestsError(error.toString())),
    );
  }

  // ── Filter ────────────────────────────────────────────────────────────────────

  void changeFilter(String filter) {
    if (state is RequestsLoaded) {
      emit(RequestsLoaded(
        (state as RequestsLoaded).allRequests,
        selectedFilter: filter,
      ));
    }
  }

  // ── Actions ───────────────────────────────────────────────────────────────────

  /// Accepts a request: advances its step and sets step-appropriate status.
  /// When step 3 is approved, auto-generates monthly payment documents.
  Future<void> acceptRequest(RequestModel model) async {
    try {
      final nextStep = (model.currentStep < 4) ? model.currentStep + 1 : 4;
      final String nextStatus;
      if (model.currentStep == 1) {
        nextStatus = 'eligibility_approved';
      } else if (model.currentStep == 2) {
        nextStatus = 'request_approved';
      } else if (model.currentStep == 3) {
        nextStatus = 'transfer_approved';
      } else {
        nextStatus = 'approved';
      }

      await _repository.updateStatus(model.id, model.collection, {
        'status':      nextStatus,
        'currentStep': nextStep,
      });

      // Auto-generate monthly installment payment documents
      if (model.currentStep == 3) {
        final months = _parseInt(model.duration);
        final totalAmount = _parseDouble(model.amount);
        if (months > 0 && totalAmount > 0) {
          final monthlyAmount = totalAmount / months;
          await PaymentsRepository.instance.generatePayments(
            requestId:     model.id,
            collection:    model.collection,
            userName:      model.name,
            monthlyAmount: monthlyAmount,
            months:        months,
          );
        }
      }
    } catch (e) {
      emit(RequestsError(e.toString()));
    }
  }

  /// Rejects a request: sets status to `not approved`.
  Future<void> rejectRequest(RequestModel model) async {
    try {
      await _repository.updateStatus(model.id, model.collection, {
        'status': 'not approved',
      });
    } catch (e) {
      emit(RequestsError(e.toString()));
    }
  }

  // ── Cleanup ───────────────────────────────────────────────────────────────────

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  // ── Private helpers ───────────────────────────────────────────────────────────

  static int _parseInt(String value) {
    // Strip non-numeric chars (e.g. " شهر", commas)
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(cleaned) ?? 0;
  }

  static double _parseDouble(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }
}
