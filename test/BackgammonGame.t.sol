// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Backgammon} from "../src/Backgammon.sol";
import {BackgammonGame, BackgammonGameCreator} from "../src/BackgammonGame.sol";
import {Utils} from "../src/Utils.sol";

import "@openzeppelin/contracts/utils/Strings.sol";


contract BackgammonTest is Test {
    BackgammonGameCreator creator = new BackgammonGameCreator();

    uint pk = vm.envUint("PRIVATE_KEY");
    address me = vm.addr(pk);

    function testBackgammonState() public {
        vm.startPrank(me);
        BackgammonGame game = BackgammonGame(creator.createGame(keccak256(abi.encode(12345))));
        game.accept(keccak256(abi.encode(12346)), 12345);

        game.receiveDice(12345, keccak256(abi.encode(12347)), 12346);
        (uint8 first, uint8 second) = game.lastRoll();
        console2.log("first: ", first);
        console2.log("second: ", second);
        uint16[] memory moves = new uint16[](2);
        moves[0] = 12 + (18 << 8);
        moves[1] = 17 + (20 << 8);
        game.makeMoves(moves, false);

        game.receiveDice(12346, keccak256(abi.encode(12348)), 12347);
        (first, second) = game.lastRoll();
        console2.log("first: ", first);
        console2.log("second: ", second);

        moves[0] = 13 + (8 << 8);
        moves[1] = 24 + (18 << 8);
        game.makeMoves(moves, true);
    }
}
