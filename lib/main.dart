import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chess/data/repositories/aegis_chess_repository.dart';
import 'package:flutter_chess/data/repositories/aegiscore/aegis_service.dart';
import 'package:flutter_chess/data/repositories/i_chess_repository.dart';
import 'package:flutter_chess/screens/landing_page.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AegisCore (Real Engine)
  final appDocDir = await getApplicationDocumentsDirectory();
  await AegisService.instance.init(
    dbPath: '${appDocDir.path}/chess_db',
    clientId: 'chess_client_${DateTime.now().millisecondsSinceEpoch}',
    enableMesh: true,
  );

  runApp(const ChessApp());
}

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<IChessRepository>(
      create: (context) => AegisChessRepository(),
      child: MaterialApp(
        title: 'Flutter Chess',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.purple,
          useMaterial3: true,
        ),
        home: const LandingPage(),
      ),
    );
  }
}
