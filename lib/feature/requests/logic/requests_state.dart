import '../data/models/request_model.dart';

abstract class RequestsState {}

class RequestsInitial extends RequestsState {}

class RequestsLoading extends RequestsState {}

class RequestsLoaded extends RequestsState {
  final List<RequestModel> allRequests;
  final String selectedFilter;

  RequestsLoaded(this.allRequests, {this.selectedFilter = 'الكل'});

  /// Returns filtered requests based on [selectedFilter].
  List<RequestModel> get requests {
    if (selectedFilter == 'الكل') return allRequests;

    const filterMap = <String, List<String>>{
      'جاري المراجعه':       ['eligibility_pending', 'جاري المراجعة', 'جاري المراجعه'],
      'تقديم الطلب':         ['تقديم طلب', 'تقديم الطلب', 'eligibility_approved', 'request_pending', 'request_pendding'],
      'انتظار تسليم المبلغ': ['انتظار تسليم المبلغ', 'transfer_pending'],
      'متكملة':              ['مكتملة', 'متكملة', 'مكتمل', 'request_approved', 'transfer_approved'],
    };

    final allowed = filterMap[selectedFilter] ?? [selectedFilter];

    return allRequests.where((r) {
      return allowed.any((s) => r.status.trim() == s);
    }).toList();
  }
}

class RequestsError extends RequestsState {
  final String message;
  RequestsError(this.message);
}
