import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/clients_cubit.dart';
import 'chat_details_view.dart';

class ChatsListView extends StatelessWidget {
  const ChatsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClientsCubit(),
      child: const _ChatsListContent(),
    );
  }
}

class _ChatsListContent extends StatelessWidget {
  const _ChatsListContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('المحادثات'), // Chats
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (value) => context.read<ClientsCubit>().search(value),
              decoration: InputDecoration(
                hintText: 'ابحث عن عميل...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<ClientsCubit, ClientsState>(
        builder: (context, state) {
          if (state is ClientsLoading || state is ClientsInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ClientsError) {
            return Center(child: Text(state.error));
          } else if (state is ClientsLoaded) {
            if (state.filteredClients.isEmpty) {
              return const Center(child: Text('لا يوجد عملاء بهذا الاسم'));
            }
            return ListView.separated(
              itemCount: state.filteredClients.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final client = state.filteredClients[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF4A4499),
                    child: Text(
                      client.name.isNotEmpty ? client.name[0].toUpperCase() : 'C',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    client.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('اضغط لبدء المحادثة'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailsView(client: client),
                      ),
                    );
                  },
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
