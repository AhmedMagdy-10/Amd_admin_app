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

    // Read clients from ALL known request collections to build name map
    // then merge with chats collection to show clients that have chats
    _buildClientsList();
  }

  Future<void> _buildClientsList() async {
    try {
      // Listen to chats collection for live updates
      _clientsSub =
          _firestore.collection('chats').snapshots().listen((snapshot) async {
        if (isClosed) return;

        final List<ChatClient> clientsList = [];

        for (final doc in snapshot.docs) {
          final clientId = doc.id;
          String name = clientId; // Default fallback = the ID itself

          // Try to get the real name from users/{clientId}
          try {
            final userDoc =
                await _firestore.collection('users').doc(clientId).get();
            if (userDoc.exists) {
              final data = userDoc.data()!;
              // Try every possible name field combination
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

          // If still no name found, try FinancingRequests collection
          if (name == clientId) {
            try {
              final reqSnap = await _firestore
                  .collection('FinancingRequests')
                  .where('userId', isEqualTo: clientId)
                  .limit(1)
                  .get();
              if (reqSnap.docs.isNotEmpty) {
                final data = reqSnap.docs.first.data();
                final firstName =
                    (data['firstName'] ?? data['first_name'] ?? '')
                        .toString()
                        .trim();
                final lastName =
                    (data['lastName'] ?? data['last_name'] ?? '')
                        .toString()
                        .trim();
                if (firstName.isNotEmpty || lastName.isNotEmpty) {
                  name = '$firstName $lastName'.trim();
                } else {
                  final sn = (data['name'] ?? data['fullName'] ?? '')
                      .toString()
                      .trim();
                  if (sn.isNotEmpty) name = sn;
                }
              }
            } catch (_) {}
          }

          clientsList.add(ChatClient(id: clientId, name: name));
        }

        if (isClosed) return;

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
