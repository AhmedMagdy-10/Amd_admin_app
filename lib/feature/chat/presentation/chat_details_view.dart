import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/widgets/custom_toast.dart';
import 'package:image_picker/image_picker.dart';
import '../logic/chat_cubit.dart';
import '../data/chat_message.dart';
import 'widgets/full_screen_image_viewer.dart';
import '../../../core/services/firebase_messaging_service.dart';
import 'package:file_picker/file_picker.dart' as fp;

import 'package:flutter_contacts/flutter_contacts.dart';
import '../data/chat_client.dart';

class ChatDetailsView extends StatelessWidget {
  final ChatClient client;
  
  const ChatDetailsView({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(clientId: client.id),
      child: _ChatContent(client: client),
    );
  }
}

class _ChatContent extends StatefulWidget {
  final ChatClient client;
  
  const _ChatContent({required this.client});

  @override
  State<_ChatContent> createState() => _ChatContentState();
}

class _ChatContentState extends State<_ChatContent> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final FirebaseMessagingService _fcmService = FirebaseMessagingService();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source, imageQuality: 70);
    if (image != null) {
      if (!mounted) return;
      context.read<ChatCubit>().sendImageMessage(File(image.path));
      
      // Notify client
      _fcmService.sendChatMessageNotification(
        clientId: widget.client.id,
        messagePreview: 'صورة مرفقة',
      );
    }
  }

  Future<void> _pickDocument() async {
    try {
      fp.FilePickerResult? result = await fp.FilePicker.platform.pickFiles(
        type: fp.FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        if (!mounted) return;
        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;
        
        context.read<ChatCubit>().sendDocumentMessage(file, fileName);

        // Notify client
        _fcmService.sendChatMessageNotification(
          clientId: widget.client.id,
          messagePreview: 'ملف مرفق: $fileName',
        );
      }
    } catch (e) {
      showToast(text: 'فشل اختيار الملف', state: ToastStates.error);
    }
  }

  void _sendMessage() {
    final text = _textController.text;
    if (text.trim().isEmpty) return;

    context.read<ChatCubit>().sendMessage(text);
    
    // Notify client
    _fcmService.sendChatMessageNotification(
      clientId: widget.client.id,
      messagePreview: text.trim(),
    );
    
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(widget.client.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is ChatError) {
            showToast(text: state.error, state: ToastStates.error);
          }
        },
        builder: (context, state) {
          if (state is ChatLoading || state is ChatInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChatLoaded) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true, // Show latest at bottom
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      return _ChatBubble(message: message);
                    },
                  ),
                ),
                if (state.isUploadingImage)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: LinearProgressIndicator(),
                  ),
                _buildMessageInput(context),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Future<void> _pickContact() async {
    try {
      if (await FlutterContacts.requestPermission()) {
        final contact = await FlutterContacts.openExternalPick();
        if (contact != null) {
          final fullContact = await FlutterContacts.getContact(contact.id);
          if (fullContact != null && fullContact.phones.isNotEmpty) {
            String contactName = fullContact.displayName;
            String contactPhone = fullContact.phones.first.number;
            String message = 'جهة اتصال 👤\nالاسم: $contactName\nالرقم: $contactPhone';
            
            if (!mounted) return;
            context.read<ChatCubit>().sendMessage(message);
            
            _fcmService.sendChatMessageNotification(
              clientId: widget.client.id,
              messagePreview: 'جهة اتصال: $contactName',
            );
          } else {
            showToast(text: 'جهة الاتصال لا تحتوي على رقم هاتف', state: ToastStates.error);
          }
        }
      } else {
        showToast(text: 'يرجى إعطاء صلاحية الوصول لجهات الاتصال', state: ToastStates.error);
      }
    } catch (e) {
      showToast(text: 'فشل اختيار جهة الاتصال', state: ToastStates.error);
    }
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return Container(
          height: 150,
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _attachmentItem(
                  icon: Icons.image,
                  color: Colors.purple,
                  label: "المعرض",
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                _attachmentItem(
                  icon: Icons.camera_alt,
                  color: Colors.pink,
                  label: "الكاميرا",
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _attachmentItem(
                  icon: Icons.insert_drive_file,
                  color: Colors.blue,
                  label: "مستند",
                  onTap: () {
                    Navigator.pop(context);
                    _pickDocument();
                  },
                ),
                _attachmentItem(
                  icon: Icons.person,
                  color: Colors.blueAccent,
                  label: "جهة اتصال",
                  onTap: () {
                    Navigator.pop(context);
                    _pickContact();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _attachmentItem({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _textController,
                builder: (context, value, child) {
                  final isTyping = value.text.isNotEmpty;
                  return TextField(
                    controller: _textController,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالتك...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.grey.shade100,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Transform.rotate(
                              angle: -0.785, // -45 degrees for upright paperclip
                              child: const Icon(Icons.attach_file, color: Colors.grey),
                            ),
                            onPressed: () => _showAttachmentOptions(context),
                          ),
                          if (!isTyping)
                            IconButton(
                              icon: const Icon(Icons.camera_alt_outlined, color: Colors.grey),
                              onPressed: () => _pickImage(ImageSource.camera),
                            ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                    textInputAction: TextInputAction.newline,
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: const Color(0xFF4A4499),
              radius: 22,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final adminUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isMe = adminUid.isNotEmpty
        ? message.senderId == adminUid
        : message.senderId == 'ADMIN-001';
    
    String timeFormat = '';
    if (message.timestamp != null) {
      final hour = message.timestamp!.hour;
      final minute = message.timestamp!.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'م' : 'ص';
      final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      timeFormat = '$hour12:$minute $period';
    }

    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        constraints: BoxConstraints(
          minWidth: 85,
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF4A4499) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(4) : const Radius.circular(16),
            bottomRight: isMe ? const Radius.circular(16) : const Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 12,
                right: 12,
                top: 10,
                bottom: 24, // Space for the timestamp
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.imageUrl != null)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullScreenImageViewer(imageUrl: message.imageUrl!),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: (message.text.isNotEmpty && message.text != 'صورة مرفقة') ? 8.0 : 0.0,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: message.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 150,
                              width: 150,
                              color: Colors.grey.shade200,
                              child: const Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 150,
                              width: 150,
                              color: Colors.grey.shade200,
                              child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (message.text.isNotEmpty && message.text != 'صورة مرفقة')
                    Text(
                      message.text,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                        fontSize: 15,
                        height: 1.3,
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              bottom: 4,
              left: 12,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  timeFormat,
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.black54,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
