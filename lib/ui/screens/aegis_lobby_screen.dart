import 'package:flutter/material.dart';
import 'package:flutter_chess/data/repositories/aegiscore/aegis_service.dart';
import 'package:flutter_chess/data/repositories/aegiscore/models/peer.dart';

/// LOBBY UI (AegisCore P2P Discovery)
///
/// This screen demonstrates how to find players on the local mesh
/// and initiate a secure pairing session.

class AegisChessLobby extends StatefulWidget {
  const AegisChessLobby({super.key});

  @override
  State<AegisChessLobby> createState() => AegisChessLobbyState();
}

class AegisChessLobbyState extends State<AegisChessLobby> {
  final AegisService _aegis = AegisService.instance;
  final List<Peer> _nearbyPeers = [];

  @override
  void initState() {
    super.initState();
    // Start listening for nearby players on the mesh
    _aegis.onPeerDiscovered.listen((peer) {
      if (!mounted) return;
      setState(() {
        // Prevent duplicates
        if (!_nearbyPeers.any((p) => p.id == peer.id)) {
          _nearbyPeers.add(peer);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Decentralized Chess Lobby"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade900, Colors.black],
          ),
        ),
        child: Column(
          children: [
            _buildPairingSection(),
            const Divider(color: Colors.white24),
            Expanded(child: _buildPeerList()),
          ],
        ),
      ),
    );
  }

  Widget _buildPairingSection() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Card(
        color: Colors.white.withAlpha((0.1 * 255).toInt()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text(
                "Connect with a Friend",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Generate a pairing PIN to play securely over local mesh.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _startPairingFlow(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("Generate Pairing PIN",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeerList() {
    if (_nearbyPeers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.amber),
            const SizedBox(height: 20),
            Text(
              "Searching for nearby players...",
              style: TextStyle(
                  color: Colors.white.withAlpha((0.6 * 255).toInt()),
                  fontSize: 16),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _nearbyPeers.length,
      itemBuilder: (context, index) {
        final peer = _nearbyPeers[index];
        return Card(
          color: Colors.white.withAlpha((0.05 * 255).toInt()),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              peer.userName,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "P2P Mesh - ${peer.ip}",
              style: const TextStyle(color: Colors.white54),
            ),
            trailing: ElevatedButton(
              onPressed: () => _challengePlayer(peer),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              child: const Text("Challenge"),
            ),
          ),
        );
      },
    );
  }

  void _startPairingFlow() {
    // Show Aegis SPAKE2+ PIN generator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Aegis SPAKE2+ Pairing Flow initiated...")),
    );
  }

  void _challengePlayer(Peer peer) {
    // Navigate to Game and initiate AEC Sync
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Challenging ${peer.userName}...")),
    );
  }
}
