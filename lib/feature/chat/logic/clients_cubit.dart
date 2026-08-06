import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/chat_client.dart';
import '../../requests/data/repositories/requests_repository.dart';

abstract class ClientsState {}

class ClientsInitial extends ClientsState {}
class ClientsLoading extends ClientsState {}

class ClientsLoaded extends ClientsState {
  final List<ChatClient> allClients;
  final List<ChatClient> filteredClients;
  final String searchQuery;

  ClientsLoaded(this.allClients, {this.filteredClients = const [], this.searchQuery = ''});
}

class ClientsError extends ClientsState {
  final String error;
  ClientsError(this.error);
}

class ClientsCubit extends Cubit<ClientsState> {
  StreamSubscription? _requestsSub;

  ClientsCubit() : super(ClientsInitial()) {
    _initStream();
  }

  void _initStream() {
    emit(ClientsLoading());
    
    void updateClients(requests) {
      if (isClosed) return;
      final Map<String, ChatClient> clientsMap = {};
      
      for (var req in requests) {
        final clientId = req.raw['userId'] ?? 'CUSTOMER-001';
        clientsMap[clientId] = ChatClient(id: clientId, name: req.name);
      }
      
      final clientsList = clientsMap.values.toList();
      
      String currentQuery = '';
      if (state is ClientsLoaded) {
        currentQuery = (state as ClientsLoaded).searchQuery;
      }
      
      final filtered = _filter(clientsList, currentQuery);
      emit(ClientsLoaded(clientsList, filteredClients: filtered, searchQuery: currentQuery));
    }

    // Initial load
    updateClients(RequestsRepository.instance.cached);

    // Listen for updates
    _requestsSub = RequestsRepository.instance.stream.listen((requests) {
      updateClients(requests);
    }, onError: (error) {
      if (!isClosed) emit(ClientsError(error.toString()));
    });
  }

  List<ChatClient> _filter(List<ChatClient> clients, String query) {
    if (query.isEmpty) return clients;
    final lowerQuery = query.toLowerCase();
    return clients.where((c) => c.name.toLowerCase().contains(lowerQuery)).toList();
  }

  void search(String query) {
    if (state is ClientsLoaded) {
      final currentState = state as ClientsLoaded;
      final filtered = _filter(currentState.allClients, query);
      emit(ClientsLoaded(currentState.allClients, filteredClients: filtered, searchQuery: query));
    }
  }

  @override
  Future<void> close() {
    _requestsSub?.cancel();
    return super.close();
  }
}
