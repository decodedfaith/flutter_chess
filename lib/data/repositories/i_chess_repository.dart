abstract class IChessRepository {
  /// Initializes the repository with the local player's ID.
  Future<void> init(String myId);

  /// Pushes a move to the decentralized network.
  Future<void> pushMove(String matchId, Map<String, dynamic> moveData);

  /// Listens for moves from the opponent in real-time.
  Stream<Map<String, dynamic>> watchMoves(String matchId);

  /// Broadcasts the local player's "thinking" status.
  Future<void> setThinking(bool isThinking);

  /// Listens for the opponent's "thinking" status.
  Stream<bool> watchOpponentThinking();

  /// Persists game state locally for restoration.
  Future<void> saveLocalState(String key, Map<String, dynamic> data);

  /// Loads persisted game state.
  Future<Map<String, dynamic>?> getLocalState(String key);
}
