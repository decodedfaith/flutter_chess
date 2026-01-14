import 'package:flutter/material.dart';
import 'package:flutter_chess/data/repositories/aegiscore/aegis_service.dart';
import 'package:flutter_chess/screens/landing_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AegisCore SDK
  await AegisService.instance.init(
    dbPath: "chess_moves.db",
    clientId: "FlutterChess_v1.0.0",
    enableMesh: true,
  );

  runApp(const ChessApp());
}

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chess',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
      ),
      home: const LandingPage(),
    );
  }
}
