import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
              return RefreshIndicator(
                onRefresh: () => context.read<ClientsCubit>().refresh(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    alignment: Alignment.center,
                    child: const Text('لا يوجد عملاء بهذا الاسم'),
                  ),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () => context.read<ClientsCubit>().refresh(),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.filteredClients.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final client = state.filteredClients[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF4A4499),
                      child: Text(
                        client.name.isNotEmpty
                            ? client.name[0].toUpperCase()
                            : 'C',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      client.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: StreamBuilder<List<dynamic>>(
                      stream: FirebaseFirestore.instance
                          .collection('chats')
                          .doc(client.id)
                          .collection('messages')
                          .orderBy('timestamp', descending: true)
                          .limit(1)
                          .snapshots()
                          .map((s) => s.docs.map((d) => d.data()).toList()),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          final lastMsgData = snapshot.data!.first;
                          String text = lastMsgData['text'] ?? 'صورة مرفقة';
                          if (text.isEmpty && lastMsgData['imageUrl'] != null) {
                            text = 'صورة مرفقة';
                          }
                          return Text(
                            text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey),
                          );
                        }
                        return const Text(
                          'اضغط لبدء المحادثة',
                          style: TextStyle(color: Colors.grey),
                        );
                      },
                    ),
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
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
