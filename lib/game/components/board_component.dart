import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess/blocs/chess_cubit.dart';
import 'package:flutter_chess/blocs/chess_state.dart';
import 'package:flutter_chess/game/chess_board.dart';
import 'package:flutter_chess/game/chess_piece.dart';
import 'package:flutter_chess/game/components/piece_component.dart';
import 'package:flutter_chess/game/position.dart';
import 'package:flutter_chess/utils/audio_service.dart';

class BoardComponent extends PositionComponent
    with FlameBlocListenable<ChessCubit, ChessState>, TapCallbacks {
  static const double squareSize = 64.0; // Size of a single square

  late final Sprite lightSquareSprite;
  late final Sprite darkSquareSprite;

  // Track pieces to animate/remove them easily
  final Map<Position, PieceComponent> _pieceComponents = {};

  final Paint _highlightPaint = Paint()
    ..color = Colors.yellow.withValues(alpha: 0.5);
  final Paint _validMovePaint = Paint()
    ..color = Colors.green.withValues(alpha: 0.5);

  Position? _selectedPosition;
  List<Position> _validMoves = [];

  BoardComponent() : super(size: Vector2(squareSize * 8, squareSize * 8));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // In a real app we might use sprites, but here I'll just draw rects in render
    // or we could create SquareComponents. For efficiency, drawing is fine or child components.
    // Let's us child components for pieces.
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 8; col++) {
        final bool isLight = (row + col) % 2 == 0;
        final Color color = isLight
            ? const Color(0xFFEEEED2)
            : const Color(0xFF769656); // Traditional green/cream

        final rect = Rect.fromLTWH(
            col * squareSize, row * squareSize, squareSize, squareSize);
        canvas.drawRect(rect, Paint()..color = color);

        // Highlight selected
        if (_selectedPosition != null &&
            _selectedPosition!.row == row &&
            chessColToIndex(_selectedPosition!.col) == col) {
          canvas.drawRect(rect, _highlightPaint);
        }

        // Highlight valid moves
        final pos = Position(row: row, col: indexToChessCol(col));
        if (_validMoves.any((p) => p.row == row && p.col == pos.col)) {
          // Draw a dot or highlight
          canvas.drawCircle(rect.center, squareSize / 6, _validMovePaint);
        }
      }
    }
  }

  @override
  void onNewState(ChessState state) {
    if (state is ChessInitial ||
        state is MoveMade ||
        state is Checkmate ||
        state is CheckState ||
        state is Stalemate) {
      if (state is ChessInitial) {
        _syncPieces(state.board);
      } else if (state is MoveMade) {
        _syncPieces(state.board);
        AudioService().playMoveSound();
      } else if (state is Checkmate) {
        _syncPieces(state.board);
        AudioService().playGameOverSound();
      } else if (state is CheckState) {
        _syncPieces(state.board);
        AudioService().playCheckSound();
      }
      // Update valid moves if a piece is selected
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
    // 1. Mark all pieces currently on the board
    final Set<String> visiblePieceIds = {};

    // 2. Iterate through the new board state
    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 8; col++) {
        final pos = Position(row: row, col: indexToChessCol(col));
        final piece = board.getPiece(pos);

        if (piece != null) {
          visiblePieceIds.add(piece.id);

          final targetPositionVector = _boardPositionToVector(pos);

          // Check if we already have a component for this piece ID
          final existingComponentEntry = _pieceComponents.entries
              .where((entry) => entry.value.piece.id == piece.id)
              .firstOrNull;

          if (existingComponentEntry != null) {
            // Update the key in the map if the position changed (conceptually, though map key is Position, which is problematic if piece moved)
            // Actually, tracking by ID is better than tracking by Position in the Map.
            // But let's stick to our Map<Position, Component> but we need to find it by ID first.
            // Refactoring map to Map<String, PieceComponent> (d: pieceId) would be better.
            // For this step, I'll search by ID.

            final existingComponent = existingComponentEntry.value;
            final currentPos = existingComponent.position;

            // If position changed, animate
            if (currentPos != targetPositionVector) {
              existingComponent.add(
                MoveEffect.to(
                  targetPositionVector,
                  EffectController(duration: 0.2, curve: Curves.easeInOut),
                ),
              );
            }
            // Update the piece data in the component (in case type changed e.g. promotion)
            // existingComponent.piece = piece; // PieceComponent needs to support this if we did promotion
          } else {
            // New piece (or we lost track), create it
            _createPiece(piece, pos);
          }
        }
      }
    }

    // 3. Remove pieces that are no longer on the board
    final idsToRemove = _pieceComponents.values
        .where((comp) => !visiblePieceIds.contains(comp.piece.id))
        .map((comp) => comp.piece.id)
        .toList();

    // Remove components
    _pieceComponents.removeWhere((pos, comp) {
      if (idsToRemove.contains(comp.piece.id)) {
        remove(comp);
        return true;
      }
      return false;
    });

    // Rebuild map to match new positions?
    // The Map<Position, PieceComponent> concept is flawed if we want to track by ID easily.
    // Let's rebuild the map based on the new positions of the components we kept.
    // Actually, simpler: Just rebuild the map.
    _pieceComponents.clear();
    for (var child in children) {
      if (child is PieceComponent) {
        // Find logical position for this component from the board
        // Iterate board to find pos for this piece.id
        Position? logicalPos;
        for (var row = 0; row < 8; row++) {
          for (var col = 0; col < 8; col++) {
            final p = Position(row: row, col: indexToChessCol(col));
            final piece = board.getPiece(p);
            if (piece != null && piece.id == child.piece.id) {
              logicalPos = p;
              break;
            }
          }
          if (logicalPos != null) break;
        }

        if (logicalPos != null) {
          _pieceComponents[logicalPos] = child;
        }
      }
    }
  }

  void _createPiece(ChessPiece piece, Position pos) {
    final comp = PieceComponent(piece: piece);
    comp.position = _boardPositionToVector(pos);
    comp.size = Vector2.all(squareSize);
    add(comp);
    _pieceComponents[pos] = comp;
  }

  Vector2 _boardPositionToVector(Position p) {
    final colIndex = chessColToIndex(p.col);
    return Vector2(colIndex * squareSize, p.row * squareSize);
  }

  @override
  void onTapDown(TapDownEvent event) {
    final colIndex = (event.localPosition.x / squareSize).floor();
    final row = (event.localPosition.y / squareSize).floor();

    if (colIndex >= 0 && colIndex < 8 && row >= 0 && row < 8) {
      final clickedPos = Position(row: row, col: indexToChessCol(colIndex));

      final cubit = bloc;
      if (cubit.selectedPiece == null) {
        cubit.selectPiece(clickedPos);
      } else {
        // Attempt move or select different piece
        final pieceAtTarget = cubit.state.board.getPiece(clickedPos);
        if (pieceAtTarget != null &&
            pieceAtTarget.color == cubit.selectedPiece!.color) {
          // Change selection
          cubit.selectPiece(clickedPos);
        } else {
          // Try move
          cubit.makeMove(cubit.selectedPosition!, clickedPos);
          // After move deselect handled by state change usually, or manual:
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
