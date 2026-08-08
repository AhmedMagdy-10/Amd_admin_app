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
                separatorBuilder: (context, index) => const Divider(height: 1, indent: 80, endIndent: 20, color: Color(0xFFEEEEEE)),
                itemBuilder: (context, index) {
                  final client = state.filteredClients[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatDetailsView(client: client),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A4499),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4A4499).withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                client.name.isNotEmpty
                                    ? client.name[0].toUpperCase()
                                    : 'C',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'ReadexPro',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: StreamBuilder<List<dynamic>>(
                              stream: FirebaseFirestore.instance
                                  .collection('chats')
                                  .doc(client.id)
                                  .collection('messages')
                                  .orderBy('timestamp', descending: true)
                                  .limit(1)
                                  .snapshots()
                                  .map((s) => s.docs.map((d) => d.data()).toList()),
                              builder: (context, snapshot) {
                                String text = 'اضغط لبدء المحادثة';
                                String timeText = '';
                                bool isUnread = false;

                                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                                  final lastMsgData = snapshot.data!.first;
                                  text = lastMsgData['text'] ?? '';
                                  if (text.isEmpty && lastMsgData['imageUrl'] != null) {
                                    text = 'صورة مرفقة 📷';
                                  }
                                  
                                  if (lastMsgData['timestamp'] != null) {
                                    final ts = lastMsgData['timestamp'] as Timestamp;
                                    final dt = ts.toDate();
                                    final now = DateTime.now();
                                    if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
                                      timeText = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
                                    } else {
                                      timeText = "${dt.year}/${dt.month}/${dt.day}";
                                    }
                                  }
                                  
                                  // Simplified unread check (if sender is not admin and isRead is false)
                                  final senderId = lastMsgData['senderId'] ?? '';
                                  final isRead = lastMsgData['isRead'] ?? true;
                                  if (senderId != 'admin' && !isRead) {
                                    isUnread = true;
                                  }
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            client.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              fontFamily: 'ReadexPro',
                                              color: Color(0xFF222222),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (timeText.isNotEmpty)
                                          Text(
                                            timeText,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isUnread ? const Color(0xFF4A4499) : Colors.grey.shade500,
                                              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                                              fontFamily: 'ReadexPro',
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            text,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: isUnread ? const Color(0xFF222222) : Colors.grey.shade600,
                                              fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                                              fontSize: 14,
                                              fontFamily: 'ReadexPro',
                                            ),
                                          ),
                                        ),
                                        if (isUnread)
                                          Container(
                                            margin: const EdgeInsets.only(right: 8),
                                            width: 10,
                                            height: 10,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF4A4499),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
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
