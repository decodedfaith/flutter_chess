import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chess/blocs/chess_cubit.dart';
import 'package:flutter_chess/blocs/chess_state.dart';
import 'package:flutter_chess/screens/chess_board_widget.dart';
import 'package:flutter_chess/widgets/game_end_dialog.dart';
import 'package:flutter_chess/widgets/promotion_dialog.dart';
import 'package:flutter_chess/widgets/review_controls.dart';
import 'package:flutter_svg/svg.dart';

class ChessScreen extends StatelessWidget {
  final String whitePlayerName;
  final String blackPlayerName;

  const ChessScreen({
    super.key,
    this.whitePlayerName = 'White Player',
    this.blackPlayerName = 'Black Player',
    this.timeLimit = const Duration(minutes: 10),
  });

  final Duration timeLimit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: _buildAppBarTitle(),
        centerTitle: true,
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
          cubit.initializeBoard(timeLimit: timeLimit);
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
            color: Colors.black87,
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
              whitePlayerName: whitePlayerName,
              blackPlayerName: blackPlayerName,
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
