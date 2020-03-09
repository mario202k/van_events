class FirestorePath {
  static String user(String uid) => 'users/$uid';
  static String users() => 'users';
  static String event(String uid) => 'events/$uid';
  static String events() => 'events';
  static String messages(String chatId) =>
      'chat/$chatId/messages';
}
