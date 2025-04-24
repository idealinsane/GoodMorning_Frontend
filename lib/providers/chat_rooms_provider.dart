import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:good_morning/data/room_dummy.dart';
import 'package:good_morning/models/chat_room.dart';
import 'package:good_morning/models/message.dart';

class ChatRoomsNotifier extends StateNotifier<List<ChatRoom>> {
  ChatRoomsNotifier() : super(dummyChatRooms);

  void appendMessage(String roomId, Message message) {
    state = [
      for (final room in state)
        if (room.id == roomId)
          room.copyWith(messages: [...room.messages, message])
        else
          room,
    ];
  }

  void addRoom(ChatRoom room) {
    if (!state.any((r) => r.id == room.id)) {
      state = [...state, room];
    }
  }
}

final chatRoomsProvider =
    StateNotifierProvider<ChatRoomsNotifier, List<ChatRoom>>(
      (ref) => ChatRoomsNotifier(),
    );
