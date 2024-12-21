// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Backgammon} from "../src/Backgammon.sol";
import {Utils} from "../src/Utils.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

contract StateWrapper {
    Backgammon.State public state;

    function resetState() external {
        Backgammon.resetState(state);
    }

    function makeMove(uint8 roll, bool giveUp, uint8 from, uint8 to) external {
        Backgammon.makeMove(state, roll, Backgammon.Move(giveUp, from, to));
    }

    function makeMoves(
        Backgammon.DiceRolls memory rolls,
        Backgammon.Move[] memory moves
    ) external {
        Backgammon.makeMoves(state, rolls, moves);
    }

    function toString() external view returns (string memory) {
        return Utils.stateToString(state);
    }

    function winner() external view returns (uint8) {
        return Backgammon.winningPlayer(state);
    }
}

contract BackgammonTest is Test {
    StateWrapper wrapper = new StateWrapper();

    function myExpect(uint8 roll, bool giveUp, uint8 from, uint8 to) public {
        vm.expectRevert();
        wrapper.makeMove(roll, giveUp, from, to);
    }

    function testBackgammonState() public {
        wrapper.resetState();
        Backgammon.Move[] memory moves;

        assertEq(
            wrapper.toString(),
            "-------------------|------------------- player1: *\n"
            "| *           x    | x              * | player2: x\n"
            "| *           x    | x              * | move: 1\n"
            "| *           x    | x                |\n"
            "| *                | x                | beared1: 0\n"
            "| *                | x                | beared2: 0\n"
            "|                  |                  |\n"
            "|------------------|------------------|\n"
            "|                  |                  |\n"
            "| x                | *                | blotted1: 0\n"
            "| x                | *                | blotted2: 0\n"
            "| x           *    | *                |\n"
            "| x           *    | *              x |\n"
            "| x           *    | *              x |\n"
            "-------------------|-------------------\n"
        );

        myExpect(6, false, 19, 25);
        myExpect(1, false, 0, 1);
        myExpect(1, false, 1, 3);
        myExpect(1, false, 2, 3);
        myExpect(5, false, 1, 6);

        moves = new Backgammon.Move[](2);
        moves[0] = Backgammon.Move(false, 1, 2);
        moves[1] = Backgammon.Move(false, 1, 3);
        wrapper.makeMoves(Backgammon.DiceRolls(1, 2), moves);

        assertEq(
            wrapper.toString(),
            "-------------------|------------------- player1: *\n"
            "| *           x    | x        *  *    | player2: x\n"
            "| *           x    | x                | move: 2\n"
            "| *           x    | x                |\n"
            "| *                | x                | beared1: 0\n"
            "| *                | x                | beared2: 0\n"
            "|                  |                  |\n"
            "|------------------|------------------|\n"
            "|                  |                  |\n"
            "| x                | *                | blotted1: 0\n"
            "| x                | *                | blotted2: 0\n"
            "| x           *    | *                |\n"
            "| x           *    | *              x |\n"
            "| x           *    | *              x |\n"
            "-------------------|-------------------\n"
        );

        myExpect(6, false, 6, 0);
        myExpect(1, false, 25, 24);
        myExpect(1, false, 24, 22);
        myExpect(1, false, 23, 22);
        myExpect(5, false, 24, 19);

        moves = new Backgammon.Move[](4);
        moves[0] = Backgammon.Move(false, 6, 2);
        moves[1] = Backgammon.Move(false, 6, 2);
        moves[2] = Backgammon.Move(false, 8, 4);
        moves[3] = Backgammon.Move(false, 8, 4);
        wrapper.makeMoves(Backgammon.DiceRolls(4, 4), moves);

        assertEq(
            wrapper.toString(),
            "-------------------|------------------- player1: *\n"
            "| *           x    | x     x  *  x    | player2: x\n"
            "| *                | x     x     x    | move: 1\n"
            "| *                | x                |\n"
            "| *                |                  | beared1: 0\n"
            "| *                |                  | beared2: 0\n"
            "|                  |                  |\n"
            "|------------------|------------------|\n"
            "|                  |                  |\n"
            "| x                | *                | blotted1: 1\n"
            "| x                | *                | blotted2: 0\n"
            "| x           *    | *                |\n"
            "| x           *    | *              x |\n"
            "| x           *    | *              x |\n"
            "-------------------|-------------------\n"
        );

        myExpect(6, false, 19, 25);
        myExpect(1, false, 1, 3);
        myExpect(1, false, 2, 3);
        myExpect(5, false, 1, 6);
        myExpect(2, false, 3, 5);

        moves = new Backgammon.Move[](2);
        moves[0] = Backgammon.Move(true, 0, 0);
        moves[1] = Backgammon.Move(true, 0, 0);
        wrapper.makeMoves(Backgammon.DiceRolls(2, 4), moves);

        assertEq(
            wrapper.toString(),
            "-------------------|------------------- player1: *\n"
            "| *           x    | x     x  *  x    | player2: x\n"
            "| *                | x     x     x    | move: 2\n"
            "| *                | x                |\n"
            "| *                |                  | beared1: 0\n"
            "| *                |                  | beared2: 0\n"
            "|                  |                  |\n"
            "|------------------|------------------|\n"
            "|                  |                  |\n"
            "| x                | *                | blotted1: 1\n"
            "| x                | *                | blotted2: 0\n"
            "| x           *    | *                |\n"
            "| x           *    | *              x |\n"
            "| x           *    | *              x |\n"
            "-------------------|-------------------\n"
        );

        moves = new Backgammon.Move[](4);
        moves[0] = Backgammon.Move(false, 6, 5);
        moves[1] = Backgammon.Move(false, 5, 4);
        moves[2] = Backgammon.Move(false, 8, 7);
        moves[3] = Backgammon.Move(false, 7, 6);
        wrapper.makeMoves(Backgammon.DiceRolls(1, 1), moves);

        assertEq(
            wrapper.toString(),
            "-------------------|------------------- player1: *\n"
            "| *                | x     x  *  x    | player2: x\n"
            "| *                | x     x     x    | move: 1\n"
            "| *                | x     x          |\n"
            "| *                |                  | beared1: 0\n"
            "| *                |                  | beared2: 0\n"
            "|                  |                  |\n"
            "|------------------|------------------|\n"
            "|                  |                  |\n"
            "| x                | *                | blotted1: 1\n"
            "| x                | *                | blotted2: 0\n"
            "| x           *    | *                |\n"
            "| x           *    | *              x |\n"
            "| x           *    | *              x |\n"
            "-------------------|-------------------\n"
        );

        moves = new Backgammon.Move[](2);
        moves[0] = Backgammon.Move(false, 0, 3);
        moves[1] = Backgammon.Move(false, 17, 19);
        wrapper.makeMoves(Backgammon.DiceRolls(3, 2), moves);

        assertEq(
            wrapper.toString(),
            "-------------------|------------------- player1: *\n"
            "| *                | x     x  *  x    | player2: x\n"
            "| *                | x     x  *  x    | move: 2\n"
            "| *                | x     x          |\n"
            "| *                |                  | beared1: 0\n"
            "| *                |                  | beared2: 0\n"
            "|                  |                  |\n"
            "|                  |                  |\n"
            "|------------------|------------------|\n"
            "|                  |                  |\n"
            "|                  | *                | blotted1: 0\n"
            "| x                | *                | blotted2: 0\n"
            "| x                | *                |\n"
            "| x                | *                |\n"
            "| x           *    | *              x |\n"
            "| x           *    | *              x |\n"
            "-------------------|-------------------\n"
        );

        moves = new Backgammon.Move[](4);
        moves[0] = Backgammon.Move(false, 13, 7);
        moves[1] = Backgammon.Move(false, 13, 7);
        moves[2] = Backgammon.Move(false, 13, 7);
        moves[3] = Backgammon.Move(false, 13, 7);
        wrapper.makeMoves(Backgammon.DiceRolls(6, 6), moves);

        moves = new Backgammon.Move[](4);
        moves[0] = Backgammon.Move(false, 12, 18);
        moves[1] = Backgammon.Move(false, 12, 18);
        moves[2] = Backgammon.Move(false, 12, 18);
        moves[3] = Backgammon.Move(false, 12, 18);
        wrapper.makeMoves(Backgammon.DiceRolls(6, 6), moves);

        assertEq(
            wrapper.toString(),
            "-------------------|------------------- player1: *\n"
            "| *              x | x     x  *  x    | player2: x\n"
            "|                x | x     x  *  x    | move: 2\n"
            "|                x | x     x          |\n"
            "|                x |                  | beared1: 0\n"
            "|                  |                  | beared2: 0\n"
            "|                  |                  |\n"
            "|                  |                  |\n"
            "|------------------|------------------|\n"
            "|                  |                  |\n"
            "|                  | *                | blotted1: 0\n"
            "|                  | *                | blotted2: 0\n"
            "|                * | *                |\n"
            "|                * | *                |\n"
            "|             *  * | *              x |\n"
            "| x           *  * | *              x |\n"
            "-------------------|-------------------\n"
        );

        moves = new Backgammon.Move[](4);
        moves[0] = Backgammon.Move(false, 13, 7);
        moves[1] = Backgammon.Move(false, 7, 1);
        moves[2] = Backgammon.Move(false, 7, 1);
        moves[3] = Backgammon.Move(false, 7, 1);
        wrapper.makeMoves(Backgammon.DiceRolls(6, 6), moves);

        moves = new Backgammon.Move[](4);
        moves[0] = Backgammon.Move(false, 3, 9);
        moves[1] = Backgammon.Move(false, 3, 9);
        moves[2] = Backgammon.Move(false, 9, 15);
        moves[3] = Backgammon.Move(false, 9, 15);
        wrapper.makeMoves(Backgammon.DiceRolls(6, 6), moves);

        assertEq(
            wrapper.toString(),
            "-------------------|------------------- player1: *\n"
            "| *              x | x     x     x  x | player2: x\n"
            "|                x | x     x     x  x | move: 2\n"
            "|                  | x     x        x |\n"
            "|                  |                  | beared1: 0\n"
            "|                  |                  | beared2: 0\n"
            "|                  |                  |\n"
            "|                  |                  |\n"
            "|------------------|------------------|\n"
            "|                  |                  |\n"
            "|                  | *                | blotted1: 0\n"
            "|                  | *                | blotted2: 0\n"
            "|                * | *                |\n"
            "|                * | *                |\n"
            "|       *     *  * | *              x |\n"
            "|       *     *  * | *              x |\n"
            "-------------------|-------------------\n"
        );

        moves = new Backgammon.Move[](4);
        moves[0] = Backgammon.Move(false, 7, 5);
        moves[1] = Backgammon.Move(false, 7, 5);
        moves[2] = Backgammon.Move(false, 6, 4);
        moves[3] = Backgammon.Move(false, 24, 22);
        wrapper.makeMoves(Backgammon.DiceRolls(2, 2), moves);

        moves = new Backgammon.Move[](4);
        moves[0] = Backgammon.Move(false, 18, 24);
        moves[1] = Backgammon.Move(false, 18, 24);
        moves[2] = Backgammon.Move(false, 18, 24);
        moves[3] = Backgammon.Move(false, 18, 24);
        wrapper.makeMoves(Backgammon.DiceRolls(6, 6), moves);

        assertEq(
            wrapper.toString(),
            "-------------------|------------------- player1: *\n"
            "| *                | x  x  x     x  x | player2: x\n"
            "|                  | x  x  x     x  x | move: 2\n"
            "|                  |       x        x |\n"
            "|                  |       x          | beared1: 0\n"
            "|                  |                  | beared2: 0\n"
            "|                  |                  |\n"
            "|                  |                  |\n"
            "|------------------|------------------|\n"
            "|                  |                  |\n"
            "|                  | *                | blotted1: 0\n"
            "|                  | *                | blotted2: 1\n"
            "|                  | *              * |\n"
            "|                  | *              * |\n"
            "|       *     *    | *              * |\n"
            "|       *     *    | *        x     * |\n"
            "-------------------|-------------------\n"
        );
        myExpect(6, false, 6, 0);
        myExpect(1, false, 4, 2);
        myExpect(1, false, 4, 3);
        myExpect(5, false, 6, 1);
        myExpect(2, false, 3, 1);
        myExpect(1, false, 25, 24);
        myExpect(2, false, 25, 22);

        moves = new Backgammon.Move[](2);
        moves[0] = Backgammon.Move(false, 25, 22);
        moves[1] = Backgammon.Move(false, 4, 2);
        wrapper.makeMoves(Backgammon.DiceRolls(3, 2), moves);

        moves = new Backgammon.Move[](4);
        moves[0] = Backgammon.Move(false, 17, 23);
        moves[1] = Backgammon.Move(false, 17, 23);
        moves[2] = Backgammon.Move(false, 15, 21);
        moves[3] = Backgammon.Move(false, 15, 21);
        wrapper.makeMoves(Backgammon.DiceRolls(6, 6), moves);

        assertEq(
            wrapper.toString(),
            "-------------------|------------------- player1: *\n"
            "| *                | x  x  x     x  x | player2: x\n"
            "|                  | x  x  x     x  x | move: 2\n"
            "|                  |       x     x  x |\n"
            "|                  |                  | beared1: 0\n"
            "|                  |                  | beared2: 0\n"
            "|                  |                  |\n"
            "|                  |                  |\n"
            "|------------------|------------------|\n"
            "|                  |                  |\n"
            "|                  | *                | blotted1: 0\n"
            "|                  | *                | blotted2: 0\n"
            "|                  | *              * |\n"
            "|                  | *              * |\n"
            "|                  | *     *  x  *  * |\n"
            "|                  | *     *  x  *  * |\n"
            "-------------------|-------------------\n"
        );

        moves = new Backgammon.Move[](4);
        moves[0] = Backgammon.Move(false, 22, 16);
        moves[1] = Backgammon.Move(false, 22, 16);
        moves[2] = Backgammon.Move(false, 16, 10);
        moves[3] = Backgammon.Move(false, 16, 10);
        wrapper.makeMoves(Backgammon.DiceRolls(6, 6), moves);

        moves = new Backgammon.Move[](4);
        moves[0] = Backgammon.Move(false, 12, 18);
        moves[1] = Backgammon.Move(false, 18, 24);
        moves[2] = Backgammon.Move(false, 19, 25);
        moves[3] = Backgammon.Move(false, 19, 25);
        wrapper.makeMoves(Backgammon.DiceRolls(6, 6), moves);

        assertEq(
            wrapper.toString(),
            "-------------------|------------------- player1: *\n"
            "|       x          | x  x  x     x  x | player2: x\n"
            "|       x          | x  x  x     x  x | move: 2\n"
            "|                  |       x     x  x |\n"
            "|                  |                  | beared1: 2\n"
            "|                  |                  | beared2: 0\n"
            "|                  |                  |\n"
            "|------------------|------------------|\n"
            "|                  |                  |\n"
            "|                  |                * | blotted1: 0\n"
            "|                  | *              * | blotted2: 0\n"
            "|                  | *              * |\n"
            "|                  | *     *     *  * |\n"
            "|                  | *     *     *  * |\n"
            "-------------------|-------------------\n"
        );

        moves = new Backgammon.Move[](4);
        moves[0] = Backgammon.Move(false, 10, 4);
        moves[1] = Backgammon.Move(false, 10, 4);
        moves[2] = Backgammon.Move(false, 6, 0);
        moves[3] = Backgammon.Move(false, 6, 0);
        wrapper.makeMoves(Backgammon.DiceRolls(6, 6), moves);

        moves = new Backgammon.Move[](4);
        moves[0] = Backgammon.Move(false, 19, 25);
        moves[1] = Backgammon.Move(false, 19, 25);
        moves[2] = Backgammon.Move(false, 19, 25);
        moves[3] = Backgammon.Move(false, 19, 25);
        wrapper.makeMoves(Backgammon.DiceRolls(6, 6), moves);

        moves = new Backgammon.Move[](4);
        moves[0] = Backgammon.Move(false, 5, 0);
        moves[1] = Backgammon.Move(false, 5, 0);
        moves[2] = Backgammon.Move(false, 4, 0);
        moves[3] = Backgammon.Move(false, 4, 0);
        wrapper.makeMoves(Backgammon.DiceRolls(6, 6), moves);

        moves = new Backgammon.Move[](4);
        moves[0] = Backgammon.Move(false, 21, 25);
        moves[1] = Backgammon.Move(false, 21, 25);
        moves[2] = Backgammon.Move(false, 23, 25);
        moves[3] = Backgammon.Move(false, 23, 25);
        wrapper.makeMoves(Backgammon.DiceRolls(6, 6), moves);

        assertEq(wrapper.winner(), 0);
        assertEq(
            wrapper.toString(),
            "-------------------|------------------- player1: *\n"
            "|                  |       x     x  x | player2: x\n"
            "|                  |       x     x  x | move: 2\n"
            "|                  |       x     x  x |\n"
            "|                  |                  | beared1: 10\n"
            "|                  |                  | beared2: 6\n"
            "|                  |                  |\n"
            "|------------------|------------------|\n"
            "|                  |                  |\n"
            "|                  |                * | blotted1: 0\n"
            "|                  |                * | blotted2: 0\n"
            "|                  |                * |\n"
            "|                  |                * |\n"
            "|                  |                * |\n"
            "-------------------|-------------------\n"
        );

        moves = new Backgammon.Move[](4);
        moves[0] = Backgammon.Move(false, 4, 0);
        moves[1] = Backgammon.Move(false, 4, 0);
        moves[2] = Backgammon.Move(false, 4, 0);
        moves[3] = Backgammon.Move(false, 2, 0);
        wrapper.makeMoves(Backgammon.DiceRolls(6, 6), moves);

        moves = new Backgammon.Move[](4);
        moves[0] = Backgammon.Move(false, 24, 25);
        moves[1] = Backgammon.Move(false, 24, 25);
        moves[2] = Backgammon.Move(false, 24, 25);
        moves[3] = Backgammon.Move(false, 24, 25);
        wrapper.makeMoves(Backgammon.DiceRolls(6, 6), moves);

        moves = new Backgammon.Move[](4);
        moves[0] = Backgammon.Move(false, 2, 0);
        moves[1] = Backgammon.Move(false, 2, 0);
        moves[2] = Backgammon.Move(false, 1, 0);
        moves[3] = Backgammon.Move(false, 1, 0);
        wrapper.makeMoves(Backgammon.DiceRolls(6, 6), moves);

        moves = new Backgammon.Move[](2);
        moves[0] = Backgammon.Move(false, 24, 25);
        moves[1] = Backgammon.Move(true, 0, 0);
        wrapper.makeMoves(Backgammon.DiceRolls(2, 3), moves);

        assertEq(wrapper.winner(), 1);
        assertEq(
            wrapper.toString(),
            "-------------------|------------------- player1: *\n"
            "|                  |                x | player2: x\n"
            "|                  |                  | move: 2\n"
            "|                  |                  |\n"
            "|                  |                  | beared1: 15\n"
            "|                  |                  | beared2: 14\n"
            "|                  |                  |\n"
            "|------------------|------------------|\n"
            "|                  |                  |\n"
            "|                  |                  | blotted1: 0\n"
            "|                  |                  | blotted2: 0\n"
            "|                  |                  |\n"
            "|                  |                  |\n"
            "|                  |                  |\n"
            "-------------------|-------------------\n"
        );
    }
}
