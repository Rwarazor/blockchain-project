// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {Backgammon} from "../src/Backgammon.sol";
import {BackgammonGame, BackgammonGameCreator} from "../src/BackgammonGame.sol";
import {Utils} from "../src/Utils.sol";

contract CreateGameScript is Script {
    BackgammonGameCreator creator = BackgammonGameCreator(vm.envAddress("CREATOR_ADDRESS"));
    uint pk = vm.envUint("PRIVATE_KEY");

    uint random1 = vm.envUint("RANDOM1");

    function setUp() public {
    }

    function run() public {
        vm.startBroadcast(pk);
        address game = creator.createGame(keccak256(abi.encode(random1)));
        vm.stopBroadcast();
    }
}

contract AcceptGameScript is Script {
    BackgammonGame game = BackgammonGame(vm.envAddress("GAME_ADDRESS"));
    uint pk = vm.envUint("PRIVATE_KEY");

    uint128 random1 = uint128(vm.envUint("RANDOM1"));

    function setUp() public {
    }

    function run() public {
        vm.startBroadcast(pk);
        game.accept(keccak256(abi.encode(random1)), uint128(vm.randomUint()));
        vm.stopBroadcast();
    }
}

contract GetStateScript is Script {
    BackgammonGame game = BackgammonGame(vm.envAddress("GAME_ADDRESS"));

    function run() public {
        (uint256 a, uint16 b, uint16 c, uint16 d, bool e) = game.state();
        console2.log(string.concat("\n", Utils.stateToString(Backgammon.State(a,b,c,d,e))));
        console2.log("move:", e ? "1" : "2");
        if (game.rollReceived()) {
            (uint8 f, uint8 g) = game.lastRoll();
            console2.log("dice:", f, g);
        } else {
            console2.log("dice: Not rolled");
        }
    }
}

contract RollDiceScript is Script {
    BackgammonGame game = BackgammonGame(vm.envAddress("GAME_ADDRESS"));
    uint pk = vm.envUint("PRIVATE_KEY");
    uint128 random1 = uint128(vm.envUint("RANDOM1"));
    uint128 random2 = uint128(vm.envUint("RANDOM2"));

    function run() public {
        vm.startBroadcast(pk);
        game.receiveDice(random1, keccak256(abi.encode(random2)), uint128(vm.randomUint()));
        vm.stopBroadcast();
    }
}

contract MakeMoveScript is Script {
    BackgammonGame game = BackgammonGame(vm.envAddress("GAME_ADDRESS"));
    uint pk = vm.envUint("PRIVATE_KEY");
    uint16 move1 = uint16(vm.envUint("MOVE1"));
    uint16 move2 = uint16(vm.envUint("MOVE2"));
    uint16 move3 = uint16(vm.envUint("MOVE3"));
    uint16 move4 = uint16(vm.envUint("MOVE4"));
    uint moveNo = vm.envUint("MOVENO");

    function run() public {
        uint16[] memory moves;
        vm.startBroadcast(pk);
        if (moveNo == 1) {
            moves = new uint16[](2);
            moves[0] = move1;
            moves[1] = move2;
            game.makeMoves(moves, false);
        } else {
            moves = new uint16[](4);
            moves[0] = move1;
            moves[1] = move2;
            moves[2] = move3;
            moves[3] = move4;
            game.makeMoves(moves, false);
        }
        vm.stopBroadcast();

        // (uint256 a, uint16 b, uint16 c, uint16 d, bool e) = game.state();
        // console2.log(string.concat("\n", Utils.stateToString(Backgammon.State(a,b,c,d,e))));
    }
}
