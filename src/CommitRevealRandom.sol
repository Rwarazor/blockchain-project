// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library CommitRevealRandom {
    function getCommit(uint128 futureRevealed) internal pure returns (bytes32) {
        return keccak256(abi.encode(futureRevealed));
    }

    function verifyPart(bytes32 commited, uint128 revealed) internal pure {
        require(keccak256(abi.encode(revealed)) == commited);
    }

    function combine(
        uint128 revealed1,
        uint128 revealed2
    ) internal pure returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encode((uint256(revealed1) << 128) ^ uint256(revealed2))
                )
            );
    }
}
