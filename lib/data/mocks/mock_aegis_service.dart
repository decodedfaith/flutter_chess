import 'dart:async';
import 'package:flutter/foundation.dart';

/// A mock version of AegisService to simulate the engine behavior
/// for development and testing without the native C++ engine.
class MockAegisService {
  static final MockAegisService instance = MockAegisService._internal();
  MockAegisService._internal();

  final _peerDiscoveredController = StreamController<MockPeer>.broadcast();
  final _typingController = StreamController<MockTypingEvent>.broadcast();

  Stream<MockPeer> get onPeerDiscovered => _peerDiscoveredController.stream;
  Stream<MockTypingEvent> get onPeerTyping => _typingController.stream;

  Future<void> init(
      {String? dbPath,
      String? clientId,
      bool? enableMesh,
      String? appName,
      String? appVersion}) async {
    debugPrint("MOCK: AegisService Initialized (ID: $clientId)");
  }

  Future<void> startNetwork() async {
    debugPrint("MOCK: Starting network discovery...");
    // Simulate finding a peer after 3 seconds
    Timer(const Duration(seconds: 3), () {
      _peerDiscoveredController.add(MockPeer(
        id: "mock-peer-123",
        userName: "Guest Opponent",
        ip: "192.168.1.50",
      ));
    });
  }

  void listenToPeerTyping() {
    debugPrint("MOCK: Listening for peer typing signals");
  }

  Future<void> put(String key, Uint8List data) async {
    debugPrint("MOCK: Data pushed to network: $key");
  }

  void setTypingStatus(bool isTyping) {
    debugPrint("MOCK: Local typing status: $isTyping");
    // Simulate opponent "thinking" back
    if (isTyping) {
      Timer(const Duration(seconds: 1), () {
        _typingController.add(MockTypingEvent(isTyping: true));
      });
    } else {
      _typingController.add(MockTypingEvent(isTyping: false));
    }
  }

  Future<Map<String, dynamic>> getBandwidthStats() async {
    return {
      'sent': 1024,
      'received': 2048,
      'mesh_nodes': 1,
    };
  }
}

class MockPeer {
  final String id;
  final String userName;
  final String ip;
  MockPeer({required this.id, required this.userName, required this.ip});
}

class MockTypingEvent {
  final bool isTyping;
  MockTypingEvent({required this.isTyping});
}
