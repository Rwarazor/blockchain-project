// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Backgammon} from "../src/Backgammon.sol";
import {BackgammonGame} from "../src/BackgammonGame.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

contract CounterTest is Test {
    BackgammonGame public game;

    function setUp() public {
        game = new BackgammonGame();
    }

    function stateToString(
        Backgammon.State memory state
    ) public pure returns (string memory) {
        uint256 max_height = 5;
        for (uint8 i = 0; i < 24; ++i) {
            if ((state.piecesOnSlot >> (8 * i)) & 127 > max_height) {
                max_height = ((state.piecesOnSlot >> (8 * i)) & 127);
            }
        }
        string memory res;
        res = string.concat(res, "\n-------------------|------------------- player1: *\n");
        for (uint256 i = 0; i < max_height; ++i) {
            res = string.concat(res, "|");
            for (uint8 j = 11; ; --j) {
                if ((state.piecesOnSlot >> (8 * j)) & 127 > i) {
                    if ((state.piecesOnSlot >> (8 * j)) & 128 == 0) {
                        res = string.concat(res, " * ");
                    } else {
                        res = string.concat(res, " x ");
                    }
                } else {
                    res = string.concat(res, "   ");
                }
                if (j == 6) {
                    res = string.concat(res, "|");
                }
                if (j == 0) {
                    break;
                }
            }
            res = string.concat(res, "|");
            if (i == 0) {
                res = string.concat(res, " player2: x");
            }
            if (i == 2) {
                res = string.concat(res, " move: ");
                if (state.isFirstPlayerMove) {
                    res = string.concat(res, "1");
                } else {
                    res = string.concat(res, "2");
                }
            }
            if (i == 3) {
                res = string.concat(res, "beared1: ");
                res = string.concat(res, Strings.toString(state.bearedOffPieces & 255));
            }
            if (i == 4) {
                res = string.concat(res, "beared2: ");
                res = string.concat(res, Strings.toString(state.bearedOffPieces >> 8));
            }
            res = string.concat(res, "\n");
        }
        res = string.concat(res, "|                  |                  |\n");
        res = string.concat(res, "|------------------|------------------|\n");
        res = string.concat(res, "|                  |                  |\n");
        for (uint256 i = max_height - 1; i >= 0; --i) {
            res = string.concat(res, "|");
            for (uint8 j = 12; j < 24; ++j) {
                if ((state.piecesOnSlot >> (8 * j)) & 127 > i) {
                    if ((state.piecesOnSlot >> (8 * j)) & 128 == 0) {
                        res = string.concat(res, " * ");
                    } else {
                        res = string.concat(res, " x ");
                    }
                } else {
                    res = string.concat(res, "   ");
                }
                if (j == 17) {
                    res = string.concat(res, "|");
                }
            }
            res = string.concat(res, "|");
            res = string.concat(res, "\n");
            if (i == 0) {
                break;
            }
        }
        res = string.concat(res, "-------------------|-------------------\n");
        return res;
    }

    function testBackgammon() public {
        (uint256 a, uint16 b, uint16 c, uint16 d, bool e) = game.state();
        Backgammon.State memory state = Backgammon.State(a, b, c, d, e);
        // Backgammon.State memory state = Backgammon.State(game.state());
        string memory s = stateToString(state);
        console2.log(s);
    }
}
