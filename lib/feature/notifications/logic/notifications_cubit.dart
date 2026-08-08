import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/notification_model.dart';
import '../data/repositories/notifications_repository.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository _repository;
  StreamSubscription<List<NotificationModel>>? _sub;

  NotificationsCubit({NotificationsRepository? repository})
      : _repository = repository ?? NotificationsRepository.instance,
        super(NotificationsInitial());

  void init() {
    emit(NotificationsLoading());
    _repository.init();
    
    _sub = _repository.stream.listen(
      (notifications) {
        emit(NotificationsLoaded(notifications));
      },
      onError: (Object e) {
        emit(NotificationsError(e.toString()));
      },
    );
  }

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
