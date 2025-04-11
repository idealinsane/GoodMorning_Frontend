import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:good_morning/models/chat_room.dart';
import 'package:good_morning/models/message.dart';

class ChatRoomsNotifier extends StateNotifier<List<ChatRoom>> {
  ChatRoomsNotifier() : super([]);

  void appendMessage(String roomId, Message message) {
    state = [
      for (final room in state)
        if (room.id == roomId)
          ChatRoom(
            id: room.id,
            title: room.title,
            participants: room.participants,
            connection: room.connection,
            createdAt: room.createdAt,
            messages: [...room.messages, message],
          )
        else
          room,
    ];
  }

  void addRoom(ChatRoom room) {
    state = [...state, room];
  }
}

final chatRoomsProvider =
    StateNotifierProvider<ChatRoomsNotifier, List<ChatRoom>>(
      (ref) => ChatRoomsNotifier(),
    );
