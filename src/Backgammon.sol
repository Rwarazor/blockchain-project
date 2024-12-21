// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library Backgammon {
    struct State {
        // highest(7-th) bit of each byte notes the color of pieces, 0 - first player, 1 - second player
        uint256 piecesOnSlot;
        // pieces "eaten" by the other player, player must first return all "eaten" pieces on board
        // before making regular moves
        uint16 blottedPieces;
        // pieces removed from board by advancing "past" the board, player must bear off all pieces to win
        uint16 bearedOffPieces;
        // pieces in the last (for this player) 6 slots, this must be all players pieces, before they can
        // bear them off from the board
        uint16 homePieces;
        bool isFirstPlayerMove;
    }

    struct DiceRolls {
        // first >= second
        uint8 first;
        uint8 second;
    }

    struct Move {
        // if moving according to dice is impossible player gives up remaining moves
        bool isGivenUp;
        // 1-24 are the board
        // 0, 25 are special values for blottedPieces and bearingOffPieces
        // 0 is blottedPieces for first player and bearingOffPieces for first player
        // 25 is the opposie
        uint8 slotFrom;
        uint8 slotTo;
    }

    function makeState(bool isFirstPlayerMove) internal pure returns (State memory) {
        State memory result;
        // first player
        result.piecesOnSlot += 2 << 0;
        result.piecesOnSlot += 5 << (11 * 8);
        result.piecesOnSlot += 3 << (16 * 8);
        result.piecesOnSlot += 5 << (18 * 8);
        result.homePieces += 5 << 0;
        // second player
        result.piecesOnSlot += (128 + 2) << ((23 - 0) * 8);
        result.piecesOnSlot += (128 + 5) << ((23 - 11) * 8);
        result.piecesOnSlot += (128 + 3) << ((23 - 16) * 8);
        result.piecesOnSlot += (128 + 5) << ((23 - 18) * 8);
        result.homePieces += 5 << 8;

        return result;
    }

    function winningPlayer(State storage state) internal view returns (uint8) {
        if ((state.bearedOffPieces & 255) == 15) {
            return 1;
        } else if ((state.bearedOffPieces >> 8) == 15) {
            return 2;
        }
        return 0;
    }

    function setIsFirstPlayerMove(State storage state, bool val) internal {
        state.isFirstPlayerMove = val;

    }

    function makeMove(State storage state, uint8 roll, Move memory move) internal {
        // TODO: no moves logic
        if (move.isGivenUp) {
            return;
        }
        if (state.isFirstPlayerMove) {
            if ((state.blottedPieces & 255) > 0) {
                require(
                    move.slotFrom == 0 && move.slotTo == roll,
                    "must return pieces if some pieces are blotted"
                );
                state.blottedPieces -= 1;
            } else if (move.slotTo == 25) {
                require(
                    (state.homePieces & 255) == 15 - (state.bearedOffPieces & 255),
                    "Bearing off pieces while some pieces are not home is not allowed"
                );
                // TODO: complex slotFrom requirement
                require(
                    move.slotFrom >= 25 - roll && move.slotFrom <= 24,
                    "must move no more than rolled amount"
                );
                state.homePieces -= 1;
                state.bearedOffPieces += 1;
            } else {
                require(
                    (move.slotFrom >= 1 && move.slotTo <= 24),
                    "Illegal slot number"
                );
            }
            if (move.slotFrom != 0) {
                require(
                    (state.piecesOnSlot >> ((move.slotFrom - 1) * 8)) & 128 == 0,
                    "Moving enemy pieces is not allowed"
                );
                require(
                    (state.piecesOnSlot >> ((move.slotFrom - 1) * 8)) >= 1,
                    "No piece to move"
                );
                state.piecesOnSlot -= 1 << ((move.slotFrom - 1) * 8);
            }
            if (move.slotTo != 25) {
                require(
                    move.slotTo - move.slotFrom == roll,
                    "must move exactly rolled amount"
                );
                if ((state.piecesOnSlot >> ((move.slotTo - 1) * 8)) & 128 == 0) {
                    // no secondPlayer pieces
                    state.piecesOnSlot += 1 << ((move.slotTo - 1) * 8);
                } else if ((state.piecesOnSlot >> ((move.slotTo - 1) * 8)) & 127 == 1) {
                    // single secondPlayer piece
                    state.piecesOnSlot &= ~(255 << ((move.slotTo - 1) * 8));
                    state.piecesOnSlot |= 1 << ((move.slotTo - 1) * 8);
                    if (move.slotTo - 1 < 6) {
                        state.homePieces -= 1 << 8;
                    }
                    state.blottedPieces += 1 << 8;
                } else {
                    revert("Can't move onto 2 or more of enemy's pieces");
                }
                if (move.slotFrom < 19 && move.slotTo >= 19) {
                    state.homePieces += 1;
                }
            }
        } else {
            if ((state.blottedPieces >> 8) > 0) {
                require(
                    move.slotFrom == 25 && move.slotTo == 25 - roll,
                    "must return pieces if some pieces are blotted"
                );
                state.blottedPieces -= 1 << 8;
            } else if (move.slotTo == 0) {
                require(
                    (state.homePieces >> 8) == 15 - (state.bearedOffPieces >> 8),
                    "Bearing off pieces while some pieces are not home is not allowed"
                );
                // TODO: complex slotFrom requirement
                require(
                    move.slotFrom <= roll && move.slotFrom >= 1,
                    "must move no more than rolled amount"
                );
                state.homePieces -= 1 << 8;
                state.bearedOffPieces += 1 << 8;
            } else {
                require(
                    (move.slotFrom <= 24 && move.slotTo >= 1),
                    "Illegal slot number"
                );
            }
            if (move.slotFrom != 25) {
                require(
                    (state.piecesOnSlot >> ((move.slotFrom - 1) * 8)) >= 129,
                    "Moving enemy pieces is not allowed/No piece to move"
                );
                state.piecesOnSlot -= 1 << ((move.slotFrom - 1) * 8);
                if ((state.piecesOnSlot >> ((move.slotFrom - 1) * 8)) == 128) {
                    state.piecesOnSlot &= ~(255 << ((move.slotTo - 1) * 8));
                    state.piecesOnSlot |= 1 << ((move.slotTo - 1) * 8);
                }
            }
            if (move.slotTo != 0) {
                require(
                    move.slotFrom - move.slotTo == roll,
                    "must move exactly rolled amount"
                );
                if ((state.piecesOnSlot >> ((move.slotTo - 1) * 8)) & 128 == 0) {
                    // no pieces
                    state.piecesOnSlot &= ~(255 << ((move.slotTo - 1) * 8));
                    state.piecesOnSlot |= 129 << ((move.slotTo - 1) * 8);
                } else if ((state.piecesOnSlot >> ((move.slotTo - 1) * 8)) & 128 == 1) {
                    // some secondPlayer pieces
                    state.piecesOnSlot += 1 << ((move.slotTo - 1) * 8);
                } else if ((state.piecesOnSlot >> ((move.slotTo - 1) * 8)) & 127 == 1) {
                    // single secondPlayer piece
                    state.piecesOnSlot &= ~(255 << ((move.slotTo - 1) * 8));
                    state.piecesOnSlot |= 129 << ((move.slotTo - 1) * 8);
                    if (move.slotTo - 1 >= 19) {
                        state.homePieces -= 1;
                    }
                    state.blottedPieces += 1;
                } else {
                    revert("Can't move onto 2 or more of enemy's pieces");
                }
                if (move.slotFrom > 6 && move.slotTo <= 6) {
                    state.homePieces += 1 << 8;
                }
            }
        }
    }

    function makeMoves(
        State storage state,
        DiceRolls memory rolls,
        Move[] memory moves
    ) internal {
        require(
            rolls.first >= 1 &&
                rolls.first <= 6 &&
                rolls.second >= 1 &&
                rolls.second <= 6,
            "Dice rolls must be between 1 and 6"
        );
        // TODO: this rule only applies if 1 or more moves are givenUp
        // require(
        //     rolls.first >= rolls.second,
        //     "Dice rolls must go from highest to lowest"
        // );
        // TODO: giving up logic
        if (rolls.first != rolls.second) {
            require(moves.length == 2, "Expected exactly 2 moves");
            makeMove(state, rolls.first, moves[0]);
            makeMove(state, rolls.second, moves[1]);
        } else {
            require(moves.length == 4, "Expected exactly 4 moves");
            makeMove(state, rolls.first, moves[0]);
            makeMove(state, rolls.first, moves[1]);
            makeMove(state, rolls.first, moves[2]);
            makeMove(state, rolls.first, moves[3]);
        }
        state.isFirstPlayerMove = !state.isFirstPlayerMove;
    }
}
