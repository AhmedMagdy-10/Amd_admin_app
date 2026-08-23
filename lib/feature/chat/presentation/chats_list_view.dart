import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../logic/clients_cubit.dart';
import '../data/chat_client.dart';
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
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'المحادثات',
          style: TextStyle(
            fontFamily: 'ReadexPro',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Color(0xFF1F1F39),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (value) => context.read<ClientsCubit>().search(value),
              decoration: InputDecoration(
                hintText: 'ابحث عن عميل...',
                hintStyle: TextStyle(
                  fontFamily: 'ReadexPro',
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF0F0F7),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<ClientsCubit, ClientsState>(
        builder: (context, state) {
          if (state is ClientsLoading || state is ClientsInitial) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A4499)),
            );
          } else if (state is ClientsError) {
            return Center(child: Text(state.error));
          } else if (state is ClientsLoaded) {
            if (state.filteredClients.isEmpty) {
              return RefreshIndicator(
                color: const Color(0xFF4A4499),
                onRefresh: () => context.read<ClientsCubit>().refresh(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد محادثات',
                          style: TextStyle(
                            fontFamily: 'ReadexPro',
                            fontSize: 16,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return RefreshIndicator(
              color: const Color(0xFF4A4499),
              onRefresh: () => context.read<ClientsCubit>().refresh(),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: state.filteredClients.length,
                itemBuilder: (context, index) {
                  final client = state.filteredClients[index];
                  return _ChatTile(client: client);
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

// ── Chat Tile with Swipe to Delete ────────────────────────────────────────────

class _ChatTile extends StatelessWidget {
  final ChatClient client;

  const _ChatTile({required this.client});

  // Generate a consistent color from the client name
  Color _avatarColor() {
    const colors = [
      Color(0xFF4A4499),
      Color(0xFF7C6DFA),
      Color(0xFF00838F),
      Color(0xFF3F51B5),
      Color(0xFF2ECA7D),
      Color(0xFFE91E8C),
    ];
    final index = client.name.codeUnits.fold(0, (a, b) => a + b) % colors.length;
    return colors[index];
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'حذف المحادثة',
            style: TextStyle(fontFamily: 'ReadexPro', fontWeight: FontWeight.w700),
          ),
          content: Text(
            'هل تريد حذف محادثة ${client.name} نهائياً؟ لا يمكن التراجع عن هذا الإجراء.',
            style: const TextStyle(fontFamily: 'ReadexPro', fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('إلغاء',
                  style: TextStyle(
                      fontFamily: 'ReadexPro', color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4B4B),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('حذف',
                  style: TextStyle(
                      fontFamily: 'ReadexPro', color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ClientsCubit>();
    final color = _avatarColor();
    final initial = client.name.isNotEmpty ? client.name[0] : 'ع';

    return Dismissible(
      key: Key(client.id),
      direction: DismissDirection.endToStart, // swipe left to delete
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFF4B4B),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text(
              'حذف',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'ReadexPro',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => cubit.deleteChat(client.id),
      child: GestureDetector(
        onLongPress: () async {
          final confirmed = await _confirmDelete(context);
          if (confirmed == true) cubit.deleteChat(client.id);
        },
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatDetailsView(client: client),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ReadexPro',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Last message info
                Expanded(
                  child: _LastMessageBuilder(client: client, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Last Message Stream Builder ───────────────────────────────────────────────

class _LastMessageBuilder extends StatelessWidget {
  final ChatClient client;
  final Color color;

  const _LastMessageBuilder({required this.client, required this.color});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
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
        bool isMe = false;

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final lastMsgData = snapshot.data!.first;
          text = lastMsgData['text'] ?? '';
          if (text.isEmpty && lastMsgData['imageUrl'] != null) {
            text = '📷 صورة مرفقة';
          }
          if (text.isEmpty && lastMsgData['fileUrl'] != null) {
            text = '📎 ملف مرفق';
          }

          if (lastMsgData['timestamp'] != null) {
            final ts = lastMsgData['timestamp'] as Timestamp;
            final dt = ts.toDate();
            final now = DateTime.now();
            if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
              final hour = dt.hour;
              final minute = dt.minute.toString().padLeft(2, '0');
              final period = hour >= 12 ? 'م' : 'ص';
              final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
              timeText = '$hour12:$minute $period';
            } else {
              final diff = now.difference(dt);
              if (diff.inDays == 1) {
                timeText = 'أمس';
              } else if (diff.inDays < 7) {
                timeText = '${diff.inDays} أيام';
              } else {
                timeText = '${dt.year}/${dt.month}/${dt.day}';
              }
            }
          }

          final adminUid = FirebaseAuth.instance.currentUser?.uid ?? '';
          final senderId = lastMsgData['senderId'] ?? '';
          final isRead = lastMsgData['isRead'] ?? true;

          isMe = adminUid.isNotEmpty
              ? senderId == adminUid
              : senderId == 'ADMIN-001';
          if (!isMe && !isRead) isUnread = true;
        }

        final hasReq = client.requestNumber != null && client.requestNumber!.isNotEmpty && client.requestNumber != client.id;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      text: client.name,
                      style: TextStyle(
                        fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 15,
                        fontFamily: 'ReadexPro',
                        color: const Color(0xFF1F1F39),
                      ),
                      children: hasReq
                          ? [
                              TextSpan(
                                text: ' (طلب ${client.requestNumber})',
                                // Uses the exact same style as the parent TextSpan (the name)
                                // since we don't override the style here.
                              ),
                            ]
                          : [],
                    ),
                  ),
                ),
                if (timeText.isNotEmpty)
                  Text(
                    timeText,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'ReadexPro',
                      color: isUnread ? color : Colors.grey.shade400,
                      fontWeight:
                          isUnread ? FontWeight.w700 : FontWeight.normal,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                if (isMe) ...[
                  Icon(Icons.done_all,
                      size: 15, color: Colors.blue.shade300),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isUnread
                          ? const Color(0xFF444466)
                          : Colors.grey.shade500,
                      fontWeight:
                          isUnread ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 13,
                      fontFamily: 'ReadexPro',
                    ),
                  ),
                ),
                if (isUnread)
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
