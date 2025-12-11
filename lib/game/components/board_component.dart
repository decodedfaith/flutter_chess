import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess/blocs/chess_cubit.dart';
import 'package:flutter_chess/blocs/chess_state.dart';
import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/components/piece_component.dart';
import 'package:flutter_chess/game/position.dart';
import 'package:flutter_chess/utils/audio_service.dart';

class BoardComponent extends PositionComponent
    with FlameBlocListenable<ChessCubit, ChessState>, TapCallbacks {
  // Track pieces by ID for robust updates
  final Map<String, PieceComponent> _pieceComponents = {};

  final Paint _highlightPaint = Paint()
    ..color = Colors.yellow.withValues(alpha: 0.5);
  final Paint _validMovePaint = Paint()
    ..color = Colors.green.withValues(alpha: 0.5);

  // Traditional Green/Cream colors
  static const Color _lightColor = Color(0xFFEEEED2);
  static const Color _darkColor = Color(0xFF769656);

  Position? _selectedPosition;
  List<Position> _validMoves = [];

  BoardComponent();

  // Calculate square size dynamically from board size
  double get squareSize => size.x / 8;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    for (var i = 0; i < 8; i++) {
      for (var j = 0; j < 8; j++) {
        // i = Visual Row Index (0 = Top/Rank 8, 7 = Bottom/Rank 1)
        // j = Visual Col Index (0 = File A, 7 = File H)

        final bool isLight = (i + j) % 2 == 0;
        final Color color = isLight ? _lightColor : _darkColor;

        final rect = Rect.fromLTWH(
            j * squareSize, i * squareSize, squareSize, squareSize);
        canvas.drawRect(rect, Paint()..color = color);

        // Map Visual (i,j) to Logical Position for Highlighting
        // Rank = 8 - i
        // File = indexToChessCol(j)
        final logicalRow = 8 - i;
        final logicalCol = indexToChessCol(j);

        // Highlight selected
        if (_selectedPosition != null &&
            _selectedPosition!.row == logicalRow &&
            _selectedPosition!.col == logicalCol) {
          canvas.drawRect(rect, _highlightPaint);
        }

        // Highlight valid moves
        // Check if ANY valid move matches this visual square
        if (_validMoves
            .any((p) => p.row == logicalRow && p.col == logicalCol)) {
          // If capture (piece exists), maybe red? For now just dot.
          canvas.drawCircle(rect.center, squareSize / 6, _validMovePaint);
        }
      }
    }
  }

  @override
  void onNewState(ChessState state) {
    // Always sync on these states
    if (state is ChessInitial ||
        state is MoveMade ||
        state is Checkmate ||
        state is CheckState ||
        state is Stalemate) {
      _syncPieces(state.board);

      if (state is MoveMade) AudioService().playMoveSound();
      if (state is Checkmate) AudioService().playGameOverSound();
      if (state is CheckState) AudioService().playCheckSound();

      // Update Selection Highlights
      final cubit = bloc;
      _selectedPosition = cubit.selectedPosition;
      if (_selectedPosition != null) {
        final piece = state.board.getPiece(_selectedPosition!);
        _validMoves = piece?.getValidMoves(state.board) ?? [];
      } else {
        _validMoves = [];
      }
    }
  }

  void _syncPieces(ChessBoard board) {
    final Set<String> activePieceIds = {};

    // 1. Iterate ALL squares to find pieces
    for (var row = 1; row <= 8; row++) {
      for (var colIndex = 0; colIndex < 8; colIndex++) {
        final col = indexToChessCol(colIndex);
        final pos = Position(col: col, row: row);
        final piece = board.getPiece(pos);

        if (piece != null) {
          activePieceIds.add(piece.id);
          final targetVector = _boardPositionToVector(pos);

          if (_pieceComponents.containsKey(piece.id)) {
            // Update existing piece
            final comp = _pieceComponents[piece.id]!;

            // If position mismatch, animate
            if (comp.position != targetVector) {
              // Remove existing move effects to prevent conflict
              comp.children
                  .whereType<MoveEffect>()
                  .forEach((e) => e.removeFromParent());

              comp.add(
                MoveEffect.to(
                  targetVector,
                  EffectController(duration: 0.2, curve: Curves.easeInOut),
                ),
              );
            }
            // Update internal piece reference (for capture logic etc) if needed
            // comp.piece = piece; // Assuming PieceComponent allows this, or we just rely on ID
          } else {
            // New piece detected
            final comp = PieceComponent(piece: piece);
            comp.position = targetVector;
            comp.size = Vector2.all(squareSize);
            add(comp);
            _pieceComponents[piece.id] = comp;
          }
        }
      }
    }

    // 2. Remove pieces that are gone (Captured)
    final idsToRemove = _pieceComponents.keys
        .where((id) => !activePieceIds.contains(id))
        .toList();

    for (var id in idsToRemove) {
      final comp = _pieceComponents[id];
      if (comp != null) {
        remove(comp);
        _pieceComponents.remove(id);
      }
    }
  }

  Vector2 _boardPositionToVector(Position p) {
    // Map Logical Position to Visual Vector
    // Col 'a' -> 0 -> X=0
    // Row 8 -> Y=0. Row 1 -> Y=7*64.
    // Y = (8 - row) * 64
    final colIndex = chessColToIndex(p.col);
    final visualRowIndex = 8 - p.row;
    return Vector2(colIndex * squareSize, visualRowIndex * squareSize);
  }

  @override
  void onTapDown(TapDownEvent event) {
    final clickX = event.localPosition.x;
    final clickY = event.localPosition.y;

    final visualColIndex = (clickX / squareSize).floor();
    final visualRowIndex = (clickY / squareSize).floor();

    if (visualColIndex >= 0 &&
        visualColIndex < 8 &&
        visualRowIndex >= 0 &&
        visualRowIndex < 8) {
      // Map Visual -> Logical
      // Col: 0 -> 'a'
      // Row: 0 -> 8
      final logicalCol = indexToChessCol(visualColIndex);
      final logicalRow = 8 - visualRowIndex;

      final clickedPos = Position(row: logicalRow, col: logicalCol);
      final cubit = bloc;

      // Interaction Logic
      if (cubit.selectedPiece == null) {
        cubit.selectPiece(clickedPos);
      } else {
        final pieceAtTarget = cubit.state.board.getPiece(clickedPos);
        // Is this my piece? Select it.
        if (pieceAtTarget != null &&
            pieceAtTarget.color == cubit.selectedPiece!.color) {
          cubit.selectPiece(clickedPos);
        } else {
          // Attempt move
          cubit.makeMove(cubit.selectedPosition!, clickedPos);
          cubit.selectedPiece = null;
          cubit.selectedPosition = null;
        }
      }
    }
  }

  int chessColToIndex(String col) {
    return col.codeUnitAt(0) - 'a'.codeUnitAt(0);
  }

  String indexToChessCol(int colIndex) {
    return String.fromCharCode('a'.codeUnitAt(0) + colIndex);
  }
}
