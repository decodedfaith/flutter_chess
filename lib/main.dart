// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/screens/chess_board_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const ChessApp());
}

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChessScreen(),
    );
  }
}

class ChessScreen extends StatefulWidget {
  const ChessScreen({super.key});

  @override
  _ChessScreenState createState() => _ChessScreenState();
}

class _ChessScreenState extends State<ChessScreen> {
  late ChessBoard chessBoard;

  @override
  void initState() {
    super.initState();
    chessBoard = ChessBoard();
    chessBoard.initializeBoard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple, // Customize your AppBar color
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/chess_pieces_svg/black-pawn.svg', // Ensure your pawn.svg file is in assets
              height: 30.0, // Size of the SVG pawn
            ),
            const SizedBox(width: 4.0), // Space between icon and text
            const Text(
              ' flutter.Chess',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto', // Customize font family
                letterSpacing: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        centerTitle: true, 
      ),
      body: Center( // Ensures the content inside the body is centered
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
          crossAxisAlignment: CrossAxisAlignment.center, // Center content horizontally
          children: [

            SizedBox(
              height: 26,
              child: Container(color: Colors.grey,child: Text("1. e4  d5  2. exd5 Qxd5 3. Nc3")),
            ),

            // Profile section above the chessboard
            const UserProfile(color: 'Black',),
            
            const SizedBox(height: 40), // Space between profile and chessboard
            ChessBoardWidget(chessBoard: chessBoard), // Your chessboard widget
            const SizedBox(height: 40), // Space after chessboard
            // Profile section below chessboard
            const UserProfile(color: 'White',),
            const Text(
              'User Stats or Info', // You can add additional user information here
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserProfile extends StatelessWidget {
  
  const UserProfile({
    super.key, required this.color
  });

  final String color;

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        CircleAvatar(
      radius: 20, // Size of the profile icon
      // backgroundImage: AssetImage('assets/user_icon.png'), // Your user icon image  //throwing errors due to abscence of specified .png file within the asset folder
    ),
    SizedBox(width: 8), // Space between the profile and name
    Text(
      'Blacj Player', // Replace with dynamic player name
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),

    SizedBox(width:170),
    Text(
      '3 Days', // Replace with dynamic player name
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
      ],
    );
  }
}
