class FirebaseMessagingService {
  // Singleton pattern
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();

  factory FirebaseMessagingService() {
    return _instance;
  }

  FirebaseMessagingService._internal();

  /// Placeholder for accepting request notification logic
  Future<void> sendAcceptNotification({required String clientId, required String requestId}) async {
    // TODO: Implement FCM logic to notify client that their request was accepted
    print('FCM: Request $requestId accepted for client $clientId');
  }

  /// Placeholder for refusing request notification logic
  Future<void> sendRefuseNotification({required String clientId, required String requestId}) async {
    // TODO: Implement FCM logic to notify client that their request was refused
    print('FCM: Request $requestId refused for client $clientId');
  }
}
