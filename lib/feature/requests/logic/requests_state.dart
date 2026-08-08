import '../data/models/request_model.dart';

abstract class RequestsState {}

class RequestsInitial extends RequestsState {}

class RequestsLoading extends RequestsState {}

class RequestsLoaded extends RequestsState {
  final List<RequestModel> allRequests;
  final String selectedFilter;

  RequestsLoaded(this.allRequests, {this.selectedFilter = 'الكل'});

  bool _isRejected(RequestModel r) {
    final status = r.status.trim();
    return status == 'not approved' || status == 'مرفوض';
  }

  bool _isCompleted(RequestModel r) {
    final status = r.status.trim();
    return status == 'approved' || status == 'مكتملة' || status == 'مكتمل' || status == 'transfer_approved';
  }

  int get countInReview => allRequests.where((r) => r.currentStep == 1 && !_isRejected(r) && !_isCompleted(r)).length;
  int get countSubmission => allRequests.where((r) => r.currentStep == 2 && !_isRejected(r) && !_isCompleted(r)).length;
  int get countWaitingTransfer => allRequests.where((r) => r.currentStep == 3 && !_isRejected(r) && !_isCompleted(r)).length;
  int get countCompleted => allRequests.where((r) => r.currentStep >= 4 || _isCompleted(r)).length;
  int get countTotal => allRequests.length;

  /// Returns filtered requests based on [selectedFilter].
  List<RequestModel> get requests {
    if (selectedFilter == 'الكل') return allRequests;

    if (selectedFilter == 'جاري المراجعة' || selectedFilter == 'جاري المراجعه') {
      return allRequests.where((r) => r.currentStep == 1 && !_isRejected(r) && !_isCompleted(r)).toList();
    }
    if (selectedFilter == 'تقديم الطلب') {
      return allRequests.where((r) => r.currentStep == 2 && !_isRejected(r) && !_isCompleted(r)).toList();
    }
    if (selectedFilter == 'انتظار تسليم المبلغ') {
      return allRequests.where((r) => r.currentStep == 3 && !_isRejected(r) && !_isCompleted(r)).toList();
    }
    if (selectedFilter == 'مكتملة' || selectedFilter == 'متكملة') {
      return allRequests.where((r) => r.currentStep >= 4 || _isCompleted(r)).toList();
    }

    return allRequests;
  }
}

class RequestsError extends RequestsState {
  final String message;
  RequestsError(this.message);
}
