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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF262421), // Chess.com dark background
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                child: Column(
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF81B64C), // Chess.com green
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.grid_4x4,
                          color: Colors.white, size: 48),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Flutter Chess',
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'PLAY • LEARN • IMPROVE',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFBABABA),
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Menu Section
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _MenuCard(
                    title: 'Play Local',
                    subtitle: 'Play with a friend on one device',
                    icon: Icons.people,
                    color: const Color(0xFF81B64C),
                    onTap: () => _showSetupModal(context),
                  ),
                  const SizedBox(height: 16),
                  const _MenuCard(
                    title: 'Computer',
                    subtitle: 'Challenge the engine',
                    icon: Icons.smart_toy,
                    color: Color(0xFF454341),
                    isLocked: true,
                  ),
                  const SizedBox(height: 16),
                  const _MenuCard(
                    title: 'Play Online',
                    subtitle: 'Coming soon to a board near you',
                    icon: Icons.public,
                    color: Color(0xFF454341),
                    isLocked: true,
                  ),
                  const SizedBox(height: 16),
                  const _MenuCard(
                    title: 'Puzzles',
                    subtitle: 'Improve your tactics',
                    icon: Icons.extension,
                    color: Color(0xFF454341),
                    isLocked: true,
                  ),
                  const SizedBox(height: 48),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSetupModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _GameSetupSheet(),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isLocked;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLocked ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isLocked ? const Color(0xFF2B2926) : const Color(0xFF32302E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLocked
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isLocked ? Colors.white38 : Colors.white,
                        ),
                      ),
                      if (isLocked) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.lock, color: Colors.white24, size: 14),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isLocked ? Colors.white24 : Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
            if (!isLocked)
              const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}

class _GameSetupSheet extends StatefulWidget {
  const _GameSetupSheet();

  @override
  State<_GameSetupSheet> createState() => _GameSetupSheetState();
}

class _GameSetupSheetState extends State<_GameSetupSheet> {
  String selectedTime = '10 min';
  final TextEditingController p1Controller =
      TextEditingController(text: 'Player 1');
  final TextEditingController p2Controller =
      TextEditingController(text: 'Player 2');

  final List<String> times = [
    '1 min',
    '3 min',
    '5 min',
    '10 min',
    '15 min',
    'None'
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF262421),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          controller: controller,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Play Local',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              _label('TIME CONTROL'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: times.map((t) {
                  final isSelected = selectedTime == t;
                  return ChoiceChip(
                    label: Text(t),
                    selected: isSelected,
                    onSelected: (val) => setState(() => selectedTime = t),
                    selectedColor: const Color(0xFF81B64C),
                    backgroundColor: const Color(0xFF32302E),
                    labelStyle: GoogleFonts.inter(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF81B64C)
                            : Colors.white10),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              _label('PLAYER NAMES'),
              const SizedBox(height: 12),
              _textField(p1Controller, 'White', Icons.circle_outlined),
              const SizedBox(height: 16),
              _textField(p2Controller, 'Black', Icons.circle),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _startGame(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF81B64C),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'PLAY',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: Colors.white38,
        letterSpacing: 2,
      ),
    );
  }

  Widget _textField(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      style: GoogleFonts.inter(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: Colors.white54, size: 18),
        filled: true,
        fillColor: const Color(0xFF32302E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _startGame(BuildContext context) {
    final cubit = ChessCubit();
    final timeLimit = _parseTime(selectedTime);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: cubit..initializeBoard(timeLimit: timeLimit),
          child: ChessScreen(
            whitePlayerName: p1Controller.text.trim().isEmpty
                ? 'Player 1'
                : p1Controller.text.trim(),
            blackPlayerName: p2Controller.text.trim().isEmpty
                ? 'Player 2'
                : p2Controller.text.trim(),
            timeLimit: timeLimit,
          ),
        ),
      ),
    );
  }

  Duration _parseTime(String t) {
    switch (t) {
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
}
