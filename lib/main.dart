import 'package:flutter/material.dart';

void main() {
  runApp(ChessGameApp());
}

class ChessGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChessGameScreen(),
    );
  }
}

class ChessGameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Minimal Chess Game'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
            ),
            itemBuilder: (context, index) {
              final isDarkSquare = (index ~/ 8 + index % 8) % 2 == 1;
              return Container(
                color: isDarkSquare ? Colors.brown : Colors.white,
              );
            },
            itemCount: 64,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // Add your functionality here
        child: Icon(Icons.refresh),
        backgroundColor: Colors.black,
      ),
    );
  }
}
