// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Backgammon} from "./Backgammon.sol";
import {CommitRevealRandom} from "./CommitRevealRandom.sol";

contract BackgammonGame {
    address public creator;
    address public firstPlayer;
    address public secondPlayer;
    uint8 public winner = 0;

    bytes32 public lastRandomFirstPlayerCommitPart;
    uint128 public lastRandomFirstPlayerOpenPart;
    bytes32 public lastRandomSecondPlayerCommitPart;
    uint128 public lastRandomSecondPlayerOpenPart;

    Backgammon.State public state;

    constructor(address firstPlayer_, bytes32 randomFirstPlayerCommitPart) {
        firstPlayer = firstPlayer_;
        lastRandomFirstPlayerCommitPart = randomFirstPlayerCommitPart;
        Backgammon.resetState(state);
    }

    bool public accepted = false;
    function accept(
        bytes32 randomCommitNext,
        uint128 randomOpenPartNext
    ) public {
        require(!accepted, "Game already accepted");
        accepted = true;
        secondPlayer = msg.sender;
        lastRandomSecondPlayerCommitPart = randomCommitNext;
        lastRandomSecondPlayerOpenPart = randomOpenPartNext;
    }

    modifier isPlayer() {
        require(accepted, "Second player not accepted");
        require(
            (state.isFirstPlayerMove && msg.sender == firstPlayer) ||
                (!state.isFirstPlayerMove && msg.sender == secondPlayer),
            "msg.sender is not the current player"
        );
        _;
    }

    bool public rollReceived = false;
    Backgammon.DiceRolls public lastRoll;

    function receiveDice(
        uint128 randomRevealLast,
        bytes32 randomCommitNext,
        uint128 randomOpenPartNext
    ) external isPlayer {
        require(!rollReceived, "Dice already rolled");

        uint256 random;
        if (state.isFirstPlayerMove) {
            CommitRevealRandom.verifyPart(
                lastRandomFirstPlayerCommitPart,
                randomRevealLast
            );
            random = CommitRevealRandom.combine(
                randomRevealLast,
                lastRandomSecondPlayerOpenPart
            );
            lastRandomFirstPlayerCommitPart = randomCommitNext;
            lastRandomFirstPlayerOpenPart = randomOpenPartNext;
        } else {
            CommitRevealRandom.verifyPart(
                lastRandomSecondPlayerCommitPart,
                randomRevealLast
            );
            random = CommitRevealRandom.combine(
                randomRevealLast,
                lastRandomFirstPlayerOpenPart
            );
            lastRandomSecondPlayerCommitPart = randomCommitNext;
            lastRandomSecondPlayerOpenPart = randomOpenPartNext;
        }

        lastRoll.first = uint8((random % 6) + 1);
        lastRoll.second = uint8(((random >> 128) % 6) + 1);

        rollReceived = true;
    }

    function makeMoves(
        uint16[] memory moves_,
        bool orderReversed
    ) external isPlayer {
        require(rollReceived, "Dice not rolled");
        require(winner == 0, "Game already ended");

        if (orderReversed) {
            lastRoll.first += lastRoll.second;
            lastRoll.second = lastRoll.first - lastRoll.second;
            lastRoll.first = lastRoll.first - lastRoll.second;
        }
        Backgammon.Move[] memory moves = new Backgammon.Move[](moves_.length);
        for (uint256 i = 0; i < moves_.length; ++i) {
            moves[i] = Backgammon.Move(
                moves_[i] == 0,
                uint8(moves_[i] & 255),
                uint8(moves_[i] >> 8)
            );
        }
        Backgammon.makeMoves(state, lastRoll, moves);
        winner = Backgammon.winningPlayer(state);
        rollReceived = false;
    }
}

contract BackgammonGameCreator {
    event GameCreated(address firstPlayer, uint magic1, address game, uint magic2);

    function createGame(
        bytes32 randomFirstPlayerCommitPart
    ) external returns (address) {
        address result = address(
            new BackgammonGame(msg.sender, randomFirstPlayerCommitPart)
        );
        emit GameCreated(msg.sender, 42, result, 228);
        return result;
    }
}
