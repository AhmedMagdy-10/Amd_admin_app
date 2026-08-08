import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/chat_message.dart';
import '../data/chat_repository.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final bool isUploadingImage;

  ChatLoaded(this.messages, {this.isUploadingImage = false});
}

class ChatError extends ChatState {
  final String error;
  ChatError(this.error);
}

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;
  final String clientId;

  ChatCubit({required this.clientId})
      : _repository = ChatRepository(),
        super(ChatInitial()) {
    _initStream();
  }

  void _initStream() {
    emit(ChatLoading());
    _repository.getMessagesStream(clientId).listen(
      (messages) {
        if (isClosed) return;
        final isUploading = (state is ChatLoaded) ? (state as ChatLoaded).isUploadingImage : false;
        emit(ChatLoaded(messages, isUploadingImage: isUploading));
      },
      onError: (error) {
        if (!isClosed) emit(ChatError(error.toString()));
      },
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await _repository.sendMessage(clientId: clientId, text: text.trim());
    } catch (e) {
      if (!isClosed) emit(ChatError("فشل إرسال الرسالة")); // Failed to send message
    }
  }

  Future<void> sendImageMessage(File imageFile) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      emit(ChatLoaded(currentState.messages, isUploadingImage: true));
    }

    try {
      final imageUrl = await _repository.uploadImageToFirebase(imageFile);
      if (imageUrl != null) {
        await _repository.sendMessage(
          clientId: clientId,
          text: 'صورة مرفقة', // "Attached image"
          imageUrl: imageUrl,
        );
      } else {
        if (!isClosed) emit(ChatError("فشل رفع الصورة. تأكد من مفتاح Imgbb API."));
      }
    } catch (e) {
      if (!isClosed) emit(ChatError("حدث خطأ أثناء إرسال الصورة"));
    } finally {
      if (!isClosed && state is ChatLoaded) {
        final currentState = state as ChatLoaded;
        emit(ChatLoaded(currentState.messages, isUploadingImage: false));
      }
    }
  }
}
