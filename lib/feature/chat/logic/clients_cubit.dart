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
      // Step 1: Collect names from all request collections
      final Map<String, String> nameMap = {};

      final collections = ['FinancingRequests', 'requests', 'orders'];
      for (final col in collections) {
        try {
          final snap = await _firestore.collection(col).get();
          for (final doc in snap.docs) {
            final data = doc.data();
            final userId = data['userId']?.toString() ??
                data['clientId']?.toString() ??
                '';
            if (userId.isEmpty) continue;

            // Try to build name from multiple possible fields
            final firstName =
                (data['firstName'] ?? data['first_name'] ?? '').toString().trim();
            final lastName =
                (data['lastName'] ?? data['last_name'] ?? '').toString().trim();
            String name = '';
            if (firstName.isNotEmpty || lastName.isNotEmpty) {
              name = '$firstName $lastName'.trim();
            } else {
              name = (data['name'] ??
                      data['fullName'] ??
                      data['clientName'] ??
                      '')
                  .toString()
                  .trim();
            }
            if (name.isNotEmpty && !nameMap.containsKey(userId)) {
              nameMap[userId] = name;
            }
          }
        } catch (_) {}
      }

      // Step 2: Also try users collection
      try {
        final usersSnap = await _firestore.collection('users').get();
        for (final doc in usersSnap.docs) {
          final data = doc.data();
          final firstName =
              (data['firstName'] ?? data['first_name'] ?? '').toString().trim();
          final lastName =
              (data['lastName'] ?? data['last_name'] ?? '').toString().trim();
          String name = '';
          if (firstName.isNotEmpty || lastName.isNotEmpty) {
            name = '$firstName $lastName'.trim();
          } else {
            name = (data['name'] ?? data['fullName'] ?? '').toString().trim();
          }
          if (name.isNotEmpty && !nameMap.containsKey(doc.id)) {
            nameMap[doc.id] = name;
          }
        }
      } catch (_) {}

      // Step 3: Listen to chats collection for live updates
      _clientsSub =
          _firestore.collection('chats').snapshots().listen((snapshot) {
        if (isClosed) return;

        final List<ChatClient> clientsList = [];

        // Always include CUSTOMER-001 first (hardcoded for testing)
        final customer001Name = nameMap['CUSTOMER-001'] ?? 'CUSTOMER-001';
        clientsList.add(ChatClient(id: 'CUSTOMER-001', name: customer001Name));

        // Add all other clients from chats collection
        for (final doc in snapshot.docs) {
          final clientId = doc.id;
          if (clientId == 'CUSTOMER-001') continue; // already added
          final name = nameMap[clientId] ?? clientId;
          clientsList.add(ChatClient(id: clientId, name: name));
        }

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
