import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chess/blocs/chess_cubit.dart';
import 'package:flutter_chess/data/repositories/aegiscore/aegis_service.dart';
import 'package:flutter_chess/data/repositories/aegiscore/models/peer.dart';
import 'package:flutter_chess/data/repositories/i_chess_repository.dart';
import 'package:flutter_chess/screens/chess_screen.dart';
import 'package:google_fonts/google_fonts.dart';

/// LOBBY UI (AegisCore P2P Discovery)
///
/// This screen demonstrates how to find players on the local mesh
/// and initiate a secure pairing session.

class AegisChessLobby extends StatefulWidget {
  const AegisChessLobby({super.key});

  @override
  State<AegisChessLobby> createState() => AegisChessLobbyState();
}

class AegisChessLobbyState extends State<AegisChessLobby>
    with SingleTickerProviderStateMixin {
  final AegisService _aegis = AegisService.instance;
  final List<Peer> _nearbyPeers = [];
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Start listening for nearby players on the mesh
    _aegis.onPeerDiscovered.listen((peer) {
      if (!mounted) return;
      setState(() {
        if (!_nearbyPeers.any((p) => p.id == peer.id)) {
          _nearbyPeers.add(peer);
        }
      });
    });
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF262421),
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildPairingSection()),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      "NEARBY PLAYERS",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white38,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
              _buildPeerList(),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon:
            const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white70),
          onPressed: () {
            setState(() => _nearbyPeers.clear());
          },
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Mesh Lobby",
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Discovery active on local network",
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPairingSection() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: _GlassCard(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.qr_code_scanner,
                  color: Color(0xFF4A90E2), size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              "Private Pairing",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Share a secure PIN to connect directly with a specific opponent.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _startPairingFlow(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  "GENERATE PAIRING PIN",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeerList() {
    if (_nearbyPeers.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RadarAnimation(controller: _radarController),
            const SizedBox(height: 24),
            Text(
              "Scanning for rivals...",
              style: GoogleFonts.inter(
                color: Colors.white24,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final peer = _nearbyPeers[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PeerTile(
                peer: peer,
                onTap: () => _challengePlayer(peer),
              ),
            );
          },
          childCount: _nearbyPeers.length,
        ),
      ),
    );
  }

  void _startPairingFlow() {
    showDialog(
      context: context,
      builder: (context) => _PairingDialog(
        pin: (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString(),
      ),
    );
  }

  void _challengePlayer(Peer peer) {
    // 1. Generate a match ID (In a real app, this would be negotiated)
    final matchId = "match_${DateTime.now().millisecondsSinceEpoch}";

    // 2. Navigate to ChessScreen
    final repository = context.read<IChessRepository>();
    final cubit = ChessCubit(repository);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: cubit
            ..initializeBoard(whiteName: "Me", blackName: peer.userName)
            ..setupSync(matchId),
          child: ChessScreen(
            whitePlayerName: "Me",
            blackPlayerName: peer.userName,
          ),
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF81B64C),
        content: Text(
          "Connecting to ${peer.userName}...",
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _PeerTile extends StatelessWidget {
  final Peer peer;
  final VoidCallback onTap;

  const _PeerTile({required this.peer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF32302E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      const Color(0xFF81B64C).withValues(alpha: 0.2),
                  child: const Icon(Icons.person, color: Color(0xFF81B64C)),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: const Color(0xFF32302E), width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    peer.userName,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "P2P Network Node • ${peer.ip}",
                    style:
                        GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.bolt, color: Colors.amber, size: 20),
          ],
        ),
      ),
    );
  }
}

class _RadarAnimation extends StatelessWidget {
  final AnimationController controller;
  const _RadarAnimation({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            for (int i = 0; i < 3; i++)
              Transform.scale(
                scale: 1.0 + (controller.value + i / 3) % 1.0,
                child: Opacity(
                  opacity: 1.0 - (controller.value + i / 3) % 1.0,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: const Color(0xFF4A90E2), width: 2),
                    ),
                  ),
                ),
              ),
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFF4A90E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_tethering, color: Colors.white),
            ),
          ],
        );
      },
    );
  }
}

class _PairingDialog extends StatelessWidget {
  final String pin;
  const _PairingDialog({required this.pin});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: _GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Your Pairing PIN",
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Text(
                    pin,
                    style: GoogleFonts.robotoMono(
                      color: const Color(0xFF4A90E2),
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Opponent should enter this PIN to connect.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "CLOSE",
                      style: GoogleFonts.inter(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
