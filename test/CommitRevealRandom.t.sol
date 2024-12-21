// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {CommitRevealRandom} from "../src/CommitRevealRandom.sol";
import {Utils} from "../src/Utils.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

contract Wrapper {
    function getCommit(uint128 futureRevealed) public returns (bytes32) {
        return CommitRevealRandom.getCommit(futureRevealed);
    }

    function verifyPart(bytes32 commited, uint128 revealed) public  {
        CommitRevealRandom.verifyPart(commited, revealed);
    }

    function combine(
        uint128 revealed1,
        uint128 revealed2
    ) public returns (uint256) {
        return
            CommitRevealRandom.combine(revealed1, revealed2);
    }
}

contract CommitRevealeRandomTest is Test {
    Wrapper wrapper = new Wrapper();

    function testCommitReveal() public {
        wrapper.verifyPart(wrapper.getCommit(12345), 12345);
        bytes32 commit = wrapper.getCommit(12346);
        vm.expectRevert();
        wrapper.verifyPart(commit, 12345);
    }
}
