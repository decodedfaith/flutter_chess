import 'dart:convert';
import 'package:flutter_chess/data/repositories/aegiscore/aegis_service.dart';

/// A repository that bridges Flutter Chess logic with the AegisCore decentralized engine.
class AegisChessRepository {
  final AegisService _aegis = AegisService.instance;

  /// Initializes AegisCore for Chess.
  Future<void> init(String deviceId) async {
    _aegis.init(dbPath: 'chess_moves.db', clientId: deviceId, enableMesh: true);
    _aegis.startNetwork();
    _aegis.listenToPeerTyping();
  }

  /// Pushes a local move to the decentralized network.
  Future<void> pushMove(String matchId, Map<String, dynamic> moveData) async {
    final payload = jsonEncode({
      'type': 'MOVE',
      'matchId': matchId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      ...moveData,
    });

    await _aegis.put('match_$matchId', utf8.encode(payload));
  }

  /// Listens for remote moves from the opponent.
  // Note: AEC watch implementation usually uses a centralized stream in modern versions
  // For this blueprint, we assume a simple watch pattern.
  Stream<Map<String, dynamic>> watchMoves(String matchId) {
    // In a real implementation, you'd filter the main update stream
    // This is a simplified blueprint for your Cubit.
    return const Stream.empty();
  }

  /// Broadcasts "Thinking" status using AEC Transient Signaling.
  void setThinking(bool isThinking) {
    _aegis.setTypingStatus(isThinking);
  }

  /// Listens for opponent's "Thinking" status.
  Stream<bool> watchOpponentThinking() {
    return _aegis.onPeerTyping.map((event) => event.isTyping);
  }

  /// Get bandwidth usage for the current session.
  Future<Map<String, dynamic>> getStats() => _aegis.getBandwidthStats();
}
