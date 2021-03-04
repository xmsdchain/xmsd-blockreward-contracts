//SPDX-License-Identifier: AGPL 3

pragma solidity ^0.8.2;

import "../interfaces/IRewardByBlock.sol";


contract RewardByBlock is IRewardByBlock {
    address public systemAddress;
	//using SafeMath for uint256;

	address[] public bridgeAllowed;
	address[] public extraReceivers;
    uint256 public mintedTotally;
    uint256 public bridgeAmount;
	mapping(address => uint256) public extraReceiverAmount;
	mapping(address => uint256) public mintedForAccount;
	mapping(address => mapping(uint256 => uint256)) public mintedForAccountInBlock;
	mapping(uint256 => uint256) public mintedInBlock;
	mapping(address => uint256) public mintedTotallyByBridge;
   

	modifier onlySystem {
		require(msg.sender == systemAddress);
		_;
	}

	constructor(address _systemAddress)
	{
		/* systemAddress = 0xffffFFFfFFffffffffffffffFfFFFfffFFFfFFfE; */
		systemAddress = _systemAddress;
	}

	// produce rewards for the given benefactors, with corresponding reward codes.
	// only callable by `SYSTEM_ADDRESS`
	function reward(address[] calldata benefactors, uint16[] calldata kind)
		override external
		onlySystem
		returns (address[] memory, uint256[] memory)
	{
		require(benefactors.length == kind.length);
		uint256[] memory rewards = new uint256[](benefactors.length);

		for (uint i = 0; i < rewards.length; i++) {
			rewards[i] = 1000 + kind[i];
		}

		return (benefactors, rewards);
	}
}
