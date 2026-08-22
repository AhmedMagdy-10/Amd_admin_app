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
    return status == 'not approved' || status == 'مرفوض' || status == 'rejected';
  }

  bool _isCompleted(RequestModel r) {
    final status = r.status.trim();
    return status == 'approved' || status == 'مكتملة' || status == 'مكتمل' || status == 'transfer_approved';
  }

  bool _isOutsideSaudi(RequestModel r) {
    final c = r.residenceCountry.trim().isNotEmpty ? r.residenceCountry.trim() : r.country.trim();
    if (c.isEmpty) return false;
    
    // Check against the specific 5 Gulf countries (excluding Saudi Arabia)
    // This avoids matching nationality fields (like "مصر" or "اليمن")
    if (c == 'دولة الإمارات العربية المتحدة' || c == 'الإمارات' ||
        c == 'دولة الكويت' || c == 'الكويت' ||
        c == 'مملكة البحرين' || c == 'البحرين' ||
        c == 'دولة قطر' || c == 'قطر' ||
        c == 'سلطنة عُمان' || c == 'سلطنة عمان' || c == 'عمان') {
      return true;
    }
    
    return false;
  }

  int get countInReview => allRequests.where((r) => r.currentStep == 1 && !_isRejected(r) && !_isCompleted(r) && !_isOutsideSaudi(r)).length;
  int get countSubmission => allRequests.where((r) => r.currentStep == 2 && !_isRejected(r) && !_isCompleted(r) && !_isOutsideSaudi(r)).length;
  int get countWaitingTransfer => allRequests.where((r) => r.currentStep == 3 && !_isRejected(r) && !_isCompleted(r) && !_isOutsideSaudi(r)).length;
  int get countCompleted => allRequests.where((r) => (r.currentStep >= 4 || _isCompleted(r)) && !_isOutsideSaudi(r)).length;
  int get countOutsideSaudi => allRequests.where((r) => _isOutsideSaudi(r)).length;
  int get countTotal => allRequests.where((r) => !_isOutsideSaudi(r)).length;

  /// Returns filtered requests based on [selectedFilter].
  List<RequestModel> get requests {
    if (selectedFilter == 'طلبات خارج المملكة') {
      return allRequests.where((r) => _isOutsideSaudi(r)).toList();
    }

    // Exclude outside Saudi from all other normal filters
    final validRequests = allRequests.where((r) => !_isOutsideSaudi(r)).toList();

    if (selectedFilter == 'الكل') return validRequests;

    if (selectedFilter == 'جاري المراجعة' || selectedFilter == 'جاري المراجعه') {
      return validRequests.where((r) => r.currentStep == 1 && !_isRejected(r) && !_isCompleted(r)).toList();
    }
    if (selectedFilter == 'تقديم الطلب') {
      return validRequests.where((r) => r.currentStep == 2 && !_isRejected(r) && !_isCompleted(r)).toList();
    }
    if (selectedFilter == 'انتظار تسليم المبلغ') {
      return validRequests.where((r) => r.currentStep == 3 && !_isRejected(r) && !_isCompleted(r)).toList();
    }
    if (selectedFilter == 'مكتملة' || selectedFilter == 'متكملة') {
      return validRequests.where((r) => r.currentStep >= 4 || _isCompleted(r)).toList();
    }

    return validRequests;
  }
}

class RequestsError extends RequestsState {
  final String message;
  RequestsError(this.message);
}
