// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Backgammon} from "./Backgammon.sol";

contract BackgammonGame {
    address public creator;
    address public firstPlayer;
    address public secondPlayer;
    uint8 public winner = 0;

    Backgammon.State public state;

    constructor() {
        firstPlayer = msg.sender;
        state = Backgammon.makeState();
    }

    bool public accepted = false;
    function accept() public {
        require(!accepted, "Game already accepted");
        accepted = true;
        secondPlayer = msg.sender;
    }

    modifier isPlayer() {
        require(accepted, "Second player not accepted");
        require(msg.sender == firstPlayer || msg.sender == secondPlayer, "msg.sender is not a player");
        _;
    }

    function makeMove(Backgammon.Move memory move) public isPlayer {
    }
}
