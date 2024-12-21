// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {BackgammonGameCreator} from "../src/BackgammonGame.sol";

contract DeployScript is Script {

    uint pk = vm.envUint("PRIVATE_KEY");
    address me = vm.addr(pk);

    function setUp() public {
    }

    function run() public {
        vm.startBroadcast(pk);
        BackgammonGameCreator creator = new BackgammonGameCreator();
        vm.stopBroadcast();
    }
}
