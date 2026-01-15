import 'dart:async';
import 'dart:convert';
import 'package:flutter_chess/data/repositories/aegiscore/aegis_service.dart';

import 'package:flutter_chess/data/repositories/i_chess_repository.dart';

/// A repository that bridges Flutter Chess logic with the AegisCore decentralized engine.
class AegisChessRepository implements IChessRepository {
  final AegisService _aegis = AegisService.instance;

  /// Initializes AegisCore for Chess.
  @override
  Future<void> init(String deviceId) async {
    // dbPath relative to app docs directory
    _aegis.startNetwork();
    _aegis.listenToPeerTyping();
  }

  /// Pushes a local move to the decentralized network.
  @override
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
  /// Listens for remote moves from the opponent.
  @override
  Stream<Map<String, dynamic>> watchMoves(String matchId) {
    // In Aegis, we watch for changes to specific keys
    // For simplicity, we filter events by the matchId in the payload
    final controller = StreamController<Map<String, dynamic>>();

    _aegis.watch(); // Start the native watch listener

    // Listen to the typing/presence events as well as the DB changes
    // In this SDK version, we assume moves are stored at 'match_$matchId'
    // We poll or use a watch callback. Since Aegis is decentralized,
    // we should ideally have a broadcast stream of all incoming mutations.

    // For this implementation, we'll use a periodic poll or the watch stream if available.
    // The current AegisService.watch uses a static callback. We need to bridge it.

    Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      if (controller.isClosed) {
        timer.cancel();
        return;
      }
      final data = await _aegis.get('match_$matchId');
      if (data != null) {
        try {
          final move = jsonDecode(utf8.decode(data));
          controller.add(move);
        } catch (_) {}
      }
    });

    return controller.stream;
  }

  @override
  Future<void> setThinking(bool isThinking) async {
    _aegis.setTypingStatus(isThinking);
  }

  /// Listens for opponent's "Thinking" status.
  @override
  Stream<bool> watchOpponentThinking() {
    return _aegis.onPeerTyping.map((event) => event.isTyping);
  }

  /// Get bandwidth usage for the current session.
  Future<Map<String, dynamic>> getStats() => _aegis.getBandwidthStats();

  @override
  Future<void> saveLocalState(String key, Map<String, dynamic> data) async {
    final payload = jsonEncode(data);
    await _aegis.put('local_$key', utf8.encode(payload));
  }

  @override
  Future<Map<String, dynamic>?> getLocalState(String key) async {
    final data = await _aegis.get('local_$key');
    if (data == null) return null;
    try {
      return jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
