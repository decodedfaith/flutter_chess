import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chess/blocs/chess_cubit.dart';
import 'package:flutter_chess/blocs/chess_state.dart';
import 'package:flutter_chess/screens/chess_board_widget.dart';
import 'package:flutter_chess/widgets/game_end_dialog.dart';
import 'package:flutter_chess/widgets/promotion_dialog.dart';
import 'package:flutter_chess/widgets/review_controls.dart';
import 'package:flutter_svg/svg.dart';

class ChessScreen extends StatefulWidget {
  final String whitePlayerName;
  final String blackPlayerName;
  final Duration timeLimit;

  const ChessScreen({
    super.key,
    this.whitePlayerName = 'White Player',
    this.blackPlayerName = 'Black Player',
    this.timeLimit = const Duration(minutes: 10),
  });

  @override
  State<ChessScreen> createState() => _ChessScreenState();
}

class _ChessScreenState extends State<ChessScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        context.read<ChessCubit>().onResume();
      }
    } else if (state == AppLifecycleState.paused) {
      if (mounted) {
        context.read<ChessCubit>().onPause();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showResignConfirmation(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF3D3A38), // Warm dark brown
          foregroundColor: Colors.white,
          elevation: 0,
          title: _buildAppBarTitle(),
          centerTitle: true,
          automaticallyImplyLeading: false, // Remove default back button
          leading: IconButton(
            icon: const Icon(Icons.flag, color: Colors.redAccent),
            onPressed: () => _showResignConfirmation(context),
            tooltip: 'Resign',
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.flip_camera_android),
              onPressed: () => context.read<ChessCubit>().toggleFlip(),
              tooltip: 'Flip Board',
            ),
          ],
        ),
        body: BlocListener<ChessCubit, ChessState>(
          listener: (context, state) {
            // Show endgame dialog on checkmate, stalemate, resignation, or timeout
            if (state is GameEnded) {
              _showGameEndDialog(context, state);
            } else if (state is AwaitingPromotion) {
              _showPromotionDialog(context, state);
            }
          },
          child: BlocBuilder<ChessCubit, ChessState>(
            builder: (context, state) {
              return _buildStateBody(context, state);
            },
          ),
        ),
      ), // Close Scaffold
    );
  }

  void _showResignConfirmation(BuildContext context) {
    final cubit = context.read<ChessCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF262421),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Resign Game?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to resign? This will end the game.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              cubit.resign();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Resign'),
          ),
        ],
      ),
    );
  }

  void _showPromotionDialog(BuildContext context, AwaitingPromotion state) {
    final cubit = context.read<ChessCubit>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PromotionDialog(
        color: state.board.currentTurn,
        onSelect: (type) {
          cubit.completePromotion(
            state.promotionFrom,
            state.promotionTo,
            type,
          );
        },
      ),
    );
  }

  void _showGameEndDialog(BuildContext context, GameEnded state) {
    final cubit = context.read<ChessCubit>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => GameEndDialog(
        winner: state.winner,
        reason: state.reason,
        moveCount: state.moveCount,
        onNewGame: () {
          Navigator.of(dialogContext).pop();
          cubit.initializeBoard(timeLimit: widget.timeLimit);
        },
        onMainMenu: () {
          Navigator.of(dialogContext).pop();
          Navigator.of(context).pop();
        },
        onReview: () {
          Navigator.of(dialogContext).pop();
          cubit.startReviewMode();
        },
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/chess_pieces_svg/black-pawn.svg',
          height: 30.0,
        ),
        const SizedBox(width: 4.0),
        const Text(
          'flutter.Chess',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStateBody(BuildContext context, ChessState state) {
    // Always show the board, overlays handle Check/Checkmate alerts
    final chessCubit = BlocProvider.of<ChessCubit>(context);
    return Column(
      children: [
        Expanded(
          child: Center(
            child: ChessBoardWidget(
              chessBoard: state.board,
              chessCubit: chessCubit,
              whitePlayerName: widget.whitePlayerName,
              blackPlayerName: widget.blackPlayerName,
            ),
          ),
        ),
        if (state is ReviewingGame)
          ReviewControls(
            currentIndex: state.currentMoveIndex,
            totalMoves: chessCubit.moveHistoryLength,
            onFirst: () => chessCubit.jumpToMove(-1),
            onLast: () =>
                chessCubit.jumpToMove(chessCubit.moveHistoryLength - 1),
            onNext: chessCubit.nextMove,
            onPrevious: chessCubit.previousMove,
          ),
      ],
    );
  }
}
