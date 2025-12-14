import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chess/blocs/chess_cubit.dart';
import 'package:flutter_chess/screens/chess_screen.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  String selectedMode = 'Local';
  String selectedTime = '10 min';
  final TextEditingController player1Controller =
      TextEditingController(text: 'Player 1');
  final TextEditingController player2Controller =
      TextEditingController(text: 'Player 2');

  final List<String> gameModes = ['Local', 'vs Bot', 'Online'];
  final List<String> timeControls = [
    '1 min',
    '3 min',
    '5 min',
    '10 min',
    '15 min',
    'No Limit'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple[900]!,
              Colors.purple[700]!,
              Colors.pink[500]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Title
                  Icon(
                    Icons.games,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Flutter Chess',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const Text(
                    'Master the Board',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Game Setup Card
                  _buildSetupCard(),

                  const SizedBox(height: 32),

                  // Play Button
                  _buildPlayButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetupCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Game Mode'),
          _buildModeSelector(),
          const SizedBox(height: 24),
          _buildSectionTitle('Time Control'),
          _buildTimeSelector(),
          const SizedBox(height: 24),
          _buildSectionTitle('Players'),
          _buildPlayerInputs(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.purple[900],
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Row(
      children: gameModes.map((mode) {
        final isSelected = selectedMode == mode;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => selectedMode = mode),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.purple[700] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  mode,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: timeControls.map((time) {
        final isSelected = selectedTime == time;
        return GestureDetector(
          onTap: () => setState(() => selectedTime = time),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.purple[700] : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.purple[900]! : Colors.transparent,
                width: 2,
              ),
            ),
            child: Text(
              time,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlayerInputs() {
    return Column(
      children: [
        TextField(
          controller: player1Controller,
          decoration: InputDecoration(
            labelText: 'White Player',
            prefixIcon: Icon(Icons.person, color: Colors.grey[700]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: player2Controller,
          enabled: selectedMode == 'Local',
          decoration: InputDecoration(
            labelText: selectedMode == 'vs Bot' ? 'Bot' : 'Black Player',
            prefixIcon: Icon(
              selectedMode == 'vs Bot' ? Icons.smart_toy : Icons.person,
              color: Colors.grey[700],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _startGame(context),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[600]!, Colors.green[400]!],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.5),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow, color: Colors.white, size: 32),
            SizedBox(width: 8),
            Text(
              'START GAME',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
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
          create: (context) => ChessCubit(),
          child: ChessScreen(
            whitePlayerName: player1Controller.text.trim().isEmpty
                ? 'Player 1'
                : player1Controller.text.trim(),
            blackPlayerName: player2Controller.text.trim().isEmpty
                ? (selectedMode == 'vs Bot' ? 'Bot' : 'Player 2')
                : player2Controller.text.trim(),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    player1Controller.dispose();
    player2Controller.dispose();
    super.dispose();
  }
}
