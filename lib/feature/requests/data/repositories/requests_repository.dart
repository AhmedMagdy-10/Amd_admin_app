import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/request_model.dart';

class RequestsRepository {
  RequestsRepository._();

  static final RequestsRepository instance = RequestsRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<String, RequestModel> _cache = {};

  final StreamController<List<RequestModel>> _controller =
      StreamController<List<RequestModel>>.broadcast();

  final List<StreamSubscription<QuerySnapshot>> _subscriptions = [];

  bool _initialized = false;
  bool _isReady = false; // Tracks if at least one snapshot has fired

  Stream<List<RequestModel>> get stream => _controller.stream;

  List<RequestModel> get cached => List.unmodifiable(_cache.values.toList());

  bool get hasData => _cache.isNotEmpty;
  bool get isReady => _isReady;

  void init() {
    if (_initialized) return;
    _initialized = true;

    _listenToCollection(
      collectionName: 'FinancingRequests',
      cachePrefix: 'fin',
    );

    _listenToCollection(collectionName: 'requests', cachePrefix: 'req');

    _listenToCollection(collectionName: 'orders', cachePrefix: 'ord');
  }

  /// Updates a document's status in Firestore (accept / reject).
  Future<void> updateStatus(
    String docId,
    String collection,
    Map<String, dynamic> fields,
  ) {
    return _firestore.collection(collection).doc(docId).update(fields);
  }

  /// Releases all listeners. Call only when the entire app is shutting down.
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    _controller.close();
    _initialized = false;
    _isReady = false;
  }

  /// Forces a manual refresh of the data by restarting the Firestore streams.
  Future<void> refresh() async {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    _initialized = false;
    _isReady = false;
    
    // Restart streams
    init();

    // Short delay so the UI refresh indicator shows nicely while first snapshots are processed
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  // ── Private helpers ──────────────────────────────────────────────────────────

  final Map<String, String> _userResidenceCache = {};

  void _listenToCollection({
    required String collectionName,
    required String cachePrefix,
  }) {
    final sub = _firestore
        .collection(collectionName)
        .snapshots()
        .listen(
          (snapshot) => _onSnapshot(snapshot, collectionName, cachePrefix),
          onError: (Object error) {
            // Errors are emitted as a dedicated error event on the stream
            _controller.addError(error);
          },
        );

    _subscriptions.add(sub);
  }

  Future<void> _onSnapshot(
    QuerySnapshot snapshot,
    String collectionName,
    String cachePrefix,
  ) async {
    // Remove documents deleted from this collection since last snapshot
    final liveIds = snapshot.docs.map((d) => '${cachePrefix}_${d.id}').toSet();
    _cache.removeWhere(
      (key, _) => key.startsWith('${cachePrefix}_') && !liveIds.contains(key),
    );

    // Upsert changed/new documents
    for (final doc in snapshot.docs) {
      final cacheKey = '${cachePrefix}_${doc.id}';
      final data = doc.data() as Map<String, dynamic>;
      
      final userId = (data['userId'] ?? data['uid'])?.toString();
      if (userId != null && userId.isNotEmpty) {
        if (!_userResidenceCache.containsKey(userId)) {
          try {
            final userDoc = await _firestore.collection('users').doc(userId).get();
            _userResidenceCache[userId] = userDoc.data()?['residence']?.toString() ?? '';
          } catch (e) {
            _userResidenceCache[userId] = '';
          }
        }
        data['fetched_residence'] = _userResidenceCache[userId];
      }

      _cache[cacheKey] = RequestModel.fromFirestore(
        doc.id,
        data,
        collectionName,
      );
    }

    _isReady = true;
    if (!_controller.isClosed) {
      _controller.add(cached);
    }
  }
}
