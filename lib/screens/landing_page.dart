import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chess/blocs/chess_cubit.dart';
import 'package:flutter_chess/screens/chess_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  String selectedMode = 'Local';
  String selectedTime = '10 min';
  final TextEditingController player1Controller =
      TextEditingController(text: 'Grandmaster 1');
  final TextEditingController player2Controller =
      TextEditingController(text: 'Grandmaster 2');

  final List<String> gameModes = ['Local', 'vs Bot', 'Online'];
  final List<String> timeControls = [
    '1 min',
    '3 min',
    '5 min',
    '10 min',
    '15 min',
    'None'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          // Dynamic Abstract Background
          Positioned.fill(
            child: _AnimatedBackground(),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Thematic Icon
                    Hero(
                      tag: 'app_logo',
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: const Icon(
                          Icons
                              .workspace_premium, // Or a custom Chess icon if available
                          size: 64,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'legendary.CHESS',
                      style: GoogleFonts.outfit(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 4,
                      ),
                    ),
                    Text(
                      'CONQUER THE BOARD',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white54,
                        letterSpacing: 6,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Setup Card with Glassmorphism
                    _buildGlassSetupCard(),

                    const SizedBox(height: 40),

                    // Play Button
                    _buildPremiumPlayButton(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassSetupCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModernSectionTitle('GAME MODE'),
              _buildModeChips(),
              const SizedBox(height: 32),
              _buildModernSectionTitle('TIME CONTROL'),
              _buildTimeChips(),
              const SizedBox(height: 32),
              _buildModernSectionTitle('CHALLENGERS'),
              _buildMinimalPlayerInputs(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.white38,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildModeChips() {
    return Row(
      children: gameModes.map((mode) {
        final isSelected = selectedMode == mode;
        final isImplemented = mode == 'Local';

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: isImplemented
                  ? () => setState(() => selectedMode = mode)
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.purple[600]
                      : (isImplemented
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black26),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isSelected ? Colors.purpleAccent : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      mode,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: isSelected
                            ? Colors.white
                            : (isImplemented ? Colors.white70 : Colors.white24),
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    if (!isImplemented)
                      Text(
                        'LOCKED',
                        style: GoogleFonts.inter(
                            fontSize: 8,
                            color: Colors.amber,
                            fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: timeControls.map((time) {
          final isSelected = selectedTime == time;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(time),
              selected: isSelected,
              onSelected: (val) => setState(() => selectedTime = time),
              selectedColor: Colors.purple[600],
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              labelStyle: GoogleFonts.inter(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              side: BorderSide(
                  color: isSelected ? Colors.purpleAccent : Colors.white10),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMinimalPlayerInputs() {
    return Column(
      children: [
        _buildInputField(player1Controller, 'White', Icons.circle_outlined),
        const SizedBox(height: 16),
        _buildInputField(player2Controller, 'Black', Icons.circle,
            isEnabled: selectedMode == 'Local'),
      ],
    );
  }

  Widget _buildInputField(
      TextEditingController controller, String label, IconData icon,
      {bool isEnabled = true}) {
    return TextField(
      controller: controller,
      enabled: isEnabled,
      style: GoogleFonts.inter(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon,
            color: isEnabled ? Colors.white54 : Colors.white24, size: 18),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
    );
  }

  Widget _buildPremiumPlayButton(BuildContext context) {
    return InkWell(
      onTap: () => _startGame(context),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
          gradient: const LinearGradient(
            colors: [Color(0xFF8E24AA), Color(0xFF6A1B9A)],
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bolt, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'REIGN SUPREME',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startGame(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => ChessCubit()
            ..initializeBoard(timeLimit: _parseTime(selectedTime)),
          child: ChessScreen(
            whitePlayerName: player1Controller.text.trim().isEmpty
                ? 'Grandmaster 1'
                : player1Controller.text.trim(),
            blackPlayerName: player2Controller.text.trim().isEmpty
                ? (selectedMode == 'vs Bot' ? 'Bot' : 'Grandmaster 2')
                : player2Controller.text.trim(),
            timeLimit: _parseTime(selectedTime),
          ),
        ),
      ),
    );
  }

  Duration _parseTime(String timeString) {
    switch (timeString) {
      case '1 min':
        return const Duration(minutes: 1);
      case '3 min':
        return const Duration(minutes: 3);
      case '5 min':
        return const Duration(minutes: 5);
      case '10 min':
        return const Duration(minutes: 10);
      case '15 min':
        return const Duration(minutes: 15);
      default:
        return const Duration(hours: 99);
    }
  }

  @override
  void dispose() {
    player1Controller.dispose();
    player2Controller.dispose();
    super.dispose();
  }
}

class _AnimatedBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.8, -0.6),
          radius: 1.2,
          colors: [
            Color(0xFF2E044B),
            Color(0xFF130122),
          ],
        ),
      ),
      child: Stack(
        children: [
          _Blob(
              color: Colors.purple.withValues(alpha: 0.1),
              top: -100,
              left: -100,
              size: 400),
          _Blob(
              color: Colors.deepPurple.withValues(alpha: 0.1),
              bottom: -50,
              right: -50,
              size: 300),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double? top, bottom, left, right;
  final double size;

  const _Blob(
      {required this.color,
      this.top,
      this.bottom,
      this.left,
      this.right,
      required this.size});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
