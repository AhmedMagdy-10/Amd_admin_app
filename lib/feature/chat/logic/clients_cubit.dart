import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/chat_client.dart';

abstract class ClientsState {}

class ClientsInitial extends ClientsState {}

class ClientsLoading extends ClientsState {}

class ClientsLoaded extends ClientsState {
  final List<ChatClient> allClients;
  final List<ChatClient> filteredClients;
  final String searchQuery;

  ClientsLoaded(this.allClients,
      {this.filteredClients = const [], this.searchQuery = ''});
}

class ClientsError extends ClientsState {
  final String error;
  ClientsError(this.error);
}

class ClientsCubit extends Cubit<ClientsState> {
  StreamSubscription? _clientsSub;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ClientsCubit() : super(ClientsInitial()) {
    _initStream();
  }

  void _initStream() {
    emit(ClientsLoading());
    _buildClientsList();
  }

  Future<void> _buildClientsList() async {
    try {
      _clientsSub = _firestore
          .collectionGroup('messages')
          .snapshots()
          .listen((snapshot) async {
        if (isClosed) return;

        // Collect unique conversation IDs
        final Set<String> seenIds = {};
        for (final doc in snapshot.docs) {
          final chatDocRef = doc.reference.parent.parent;
          if (chatDocRef != null) {
            seenIds.add(chatDocRef.id);
          }
        }

        final List<ChatClient> clientsList = [];

        for (final clientId in seenIds) {
          String name = clientId;

          // 1. Try users/{clientId}
          try {
            final userDoc =
                await _firestore.collection('users').doc(clientId).get();
            if (userDoc.exists) {
              final data = userDoc.data()!;
              final firstName = (data['firstName'] ??
                      data['first_name'] ??
                      data['fname'] ??
                      '')
                  .toString()
                  .trim();
              final lastName = (data['lastName'] ??
                      data['last_name'] ??
                      data['lname'] ??
                      '')
                  .toString()
                  .trim();

              if (firstName.isNotEmpty || lastName.isNotEmpty) {
                name = '$firstName $lastName'.trim();
              } else {
                final singleName = (data['name'] ??
                        data['fullName'] ??
                        data['displayName'] ??
                        data['username'] ??
                        '')
                    .toString()
                    .trim();
                if (singleName.isNotEmpty) name = singleName;
              }
            }
          } catch (_) {}

          // 2. If still just the raw ID, try FinancingRequests collection
          if (name == clientId) {
            try {
              final reqSnap = await _firestore
                  .collection('FinancingRequests')
                  .where('userId', isEqualTo: clientId)
                  .limit(1)
                  .get();
              if (reqSnap.docs.isNotEmpty) {
                final data = reqSnap.docs.first.data();
                final eligibility =
                    data['eligibilityData'] as Map<String, dynamic>?;
                final firstName =
                    (eligibility?['firstName'] ?? data['firstName'] ?? data['first_name'] ?? '')
                        .toString()
                        .trim();
                final lastName =
                    (eligibility?['lastName'] ?? data['lastName'] ?? data['last_name'] ?? '')
                        .toString()
                        .trim();
                if (firstName.isNotEmpty || lastName.isNotEmpty) {
                  name = '$firstName $lastName'.trim();
                } else {
                  final sn = (data['name'] ?? data['fullName'] ?? data['clientName'] ?? '')
                      .toString()
                      .trim();
                  if (sn.isNotEmpty) name = sn;
                }
              }
            } catch (_) {}
          }

          // 3. Fetch last message timestamp for sorting
          DateTime? lastTime;
          try {
            final lastMsgSnap = await _firestore
                .collection('chats')
                .doc(clientId)
                .collection('messages')
                .orderBy('timestamp', descending: true)
                .limit(1)
                .get();
            if (lastMsgSnap.docs.isNotEmpty) {
              final ts = lastMsgSnap.docs.first.data()['timestamp'];
              if (ts is Timestamp) lastTime = ts.toDate();
            }
          } catch (_) {}

          clientsList.add(ChatClient(id: clientId, name: name, lastMessageTime: lastTime));
        }

        if (isClosed) return;

        // Sort by last message time — most recent first
        clientsList.sort((a, b) {
          if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
          if (a.lastMessageTime == null) return 1;
          if (b.lastMessageTime == null) return -1;
          return b.lastMessageTime!.compareTo(a.lastMessageTime!);
        });

        String currentQuery = '';
        if (state is ClientsLoaded) {
          currentQuery = (state as ClientsLoaded).searchQuery;
        }

        final filtered = _filter(clientsList, currentQuery);
        emit(ClientsLoaded(clientsList,
            filteredClients: filtered, searchQuery: currentQuery));
      }, onError: (error) {
        if (!isClosed) emit(ClientsError(error.toString()));
      });
    } catch (e) {
      if (!isClosed) emit(ClientsError(e.toString()));
    }
  }

  /// Delete an entire chat conversation (all messages under chats/{clientId})
  Future<void> deleteChat(String clientId) async {
    try {
      final messagesRef = _firestore
          .collection('chats')
          .doc(clientId)
          .collection('messages');

      // Delete in batches of 100
      QuerySnapshot snapshot;
      do {
        snapshot = await messagesRef.limit(100).get();
        final batch = _firestore.batch();
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      } while (snapshot.docs.length == 100);

      // Also delete the parent chat document if it exists
      await _firestore.collection('chats').doc(clientId).delete();
    } catch (e) {
      // Ignore — stream will auto-update UI
    }
  }

  List<ChatClient> _filter(List<ChatClient> clients, String query) {
    if (query.isEmpty) return clients;
    final lowerQuery = query.toLowerCase();
    return clients
        .where((c) => c.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  void search(String query) {
    if (state is ClientsLoaded) {
      final currentState = state as ClientsLoaded;
      final filtered = _filter(currentState.allClients, query);
      emit(ClientsLoaded(currentState.allClients,
          filteredClients: filtered, searchQuery: query));
    }
  }

  Future<void> refresh() async {
    _clientsSub?.cancel();
    _initStream();
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  @override
  Future<void> close() {
    _clientsSub?.cancel();
    return super.close();
  }
}
