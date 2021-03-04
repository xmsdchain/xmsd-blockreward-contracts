//SPDX-License-Identifier: AGPL 3

pragma solidity ^0.8.2;

interface IRewardByBlock {
    // Produce rewards for the given benefactors, with corresponding reward codes.
    // Only callable by `SYSTEM_ADDRESS`
    function reward(address[] calldata, uint16[] calldata) external returns (address[] memory, uint256[] memory);
}