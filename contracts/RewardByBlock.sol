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


    //bad implementation
	
	/*function addExtraReceiver(uint256 _amount, address _receiver)
        external
        onlyBridgeContract
    {
        require(_amount != 0);
        require(_receiver != address(0));
        uint256 oldAmount = extraReceiverAmount(_receiver);
        if (oldAmount == 0) {
            _addExtraReceiver(_receiver);
        }
        _setExtraReceiverAmount(oldAmount.add(_amount), _receiver);
        _setBridgeAmount(bridgeAmount(msg.sender).add(_amount), msg.sender);
        emit AddedReceiver(_amount, _receiver, msg.sender);
    }

    function reward(address[] benefactors, uint16[] kind)
        external
        onlySystem
        returns (address[], uint256[])
    {
        require(benefactors.length == kind.length);
        require(benefactors.length == 1);
        require(kind[0] == 0);

        address miningKey = benefactors[0];

        if (miningKey == address(0)) {
            // Return empty arrays
            return (new address[](0), new uint256[](0));
        }

        uint256 extraLength = extraReceiversLength();

        address[] memory receivers = new address[](extraLength.add(2));
        uint256[] memory rewards = new uint256[](receivers.length);

        receivers[0] = _getPayoutByMining(miningKey);
        rewards[0] = blockRewardAmount;
        receivers[1] = emissionFunds;
        rewards[1] = emissionFundsAmount;

        uint256 i;
        
        for (i = 0; i < extraLength; i++) {
            address extraAddress = extraReceiverByIndex(i);
            uint256 extraAmount = extraReceiverAmount(extraAddress);
            _setExtraReceiverAmount(0, extraAddress);
            receivers[i.add(2)] = extraAddress;
            rewards[i.add(2)] = extraAmount;
        }

        for (i = 0; i < receivers.length; i++) {
            _setMinted(rewards[i], receivers[i]);
        }

        for (i = 0; i < bridgesAllowedLength; i++) {
            address bridgeAddress = bridgesAllowed()[i];
            uint256 bridgeAmountForBlock = bridgeAmount(bridgeAddress);

            if (bridgeAmountForBlock > 0) {
                _setBridgeAmount(0, bridgeAddress);
                _addMintedTotallyByBridge(bridgeAmountForBlock, bridgeAddress);
            }
        }

        _clearExtraReceivers();

        emit Rewarded(receivers, rewards);
    
        return (receivers, rewards);
    }

    function bridgesAllowed() public pure returns(address[bridgesAllowedLength]) {
        // These values must be changed before deploy
        return([
            address(0x0000000000000000000000000000000000000000),
            address(0x0000000000000000000000000000000000000000),
            address(0x0000000000000000000000000000000000000000)
        ]);
    }

    function bridgeAmount(address _bridge) public view returns(uint256) {
        return uintStorage[
            keccak256(abi.encode(BRIDGE_AMOUNT, _bridge))
        ];
    }

    function extraReceiverByIndex(uint256 _index) public view returns(address) {
        return addressArrayStorage[EXTRA_RECEIVERS][_index];
    }

    function extraReceiverAmount(address _receiver) public view returns(uint256) {
        return uintStorage[
            keccak256(abi.encode(EXTRA_RECEIVER_AMOUNT, _receiver))
        ];
    }

    function extraReceiversLength() public view returns(uint256) {
        return addressArrayStorage[EXTRA_RECEIVERS].length;
    }

    function mintedForAccount(address _account)
        public
        view
        returns(uint256)
    {
        return uintStorage[
            keccak256(abi.encode(MINTED_FOR_ACCOUNT, _account))
        ];
    }

    function mintedForAccountInBlock(address _account, uint256 _blockNumber)
        public
        view
        returns(uint256)
    {
        return uintStorage[
            keccak256(abi.encode(MINTED_FOR_ACCOUNT_IN_BLOCK, _account, _blockNumber))
        ];
    }

    function mintedInBlock(uint256 _blockNumber) public view returns(uint256) {
        return uintStorage[
            keccak256(abi.encode(MINTED_IN_BLOCK, _blockNumber))
        ];
    }

    function mintedTotally() public view returns(uint256) {
        return uintStorage[MINTED_TOTALLY];
    }

    function mintedTotallyByBridge(address _bridge) public view returns(uint256) {
        return uintStorage[
            keccak256(abi.encode(MINTED_TOTALLY_BY_BRIDGE, _bridge))
        ];
    }

    function proxyStorage() public view returns(address) {
        return addressStorage[PROXY_STORAGE];
    }

    function _addExtraReceiver(address _receiver) private {
        addressArrayStorage[EXTRA_RECEIVERS].push(_receiver);
    }

    function _addMintedTotallyByBridge(uint256 _amount, address _bridge) private {
        bytes32 hash = keccak256(abi.encode(MINTED_TOTALLY_BY_BRIDGE, _bridge));
        uintStorage[hash] = uintStorage[hash].add(_amount);
    }

    function _clearExtraReceivers() private {
        addressArrayStorage[EXTRA_RECEIVERS].length = 0;
    }

    function _getPayoutByMining(address _miningKey)
        private
        view
        returns (address)
    {
        IKeysManager keysManager = IKeysManager(
            IProxyStorage(proxyStorage()).getKeysManager()
        );
        address payoutKey = keysManager.getPayoutByMining(_miningKey);
        return (payoutKey != address(0)) ? payoutKey : _miningKey;
    }

    function _isBridgeContract(address _addr) private pure returns(bool) {
        address[bridgesAllowedLength] memory bridges = bridgesAllowed();
        
        for (uint256 i = 0; i < bridges.length; i++) {
            if (_addr == bridges[i]) {
                return true;
            }
        }

        return false;
    }

    function _isMiningActive(address _miningKey)
        private
        view
        returns (bool)
    {
        IKeysManager keysManager = IKeysManager(
            IProxyStorage(proxyStorage()).getKeysManager()
        );
        return keysManager.isMiningActive(_miningKey);
    }

    function _setBridgeAmount(uint256 _amount, address _bridge) private {
        uintStorage[
            keccak256(abi.encode(BRIDGE_AMOUNT, _bridge))
        ] = _amount;
    }

    function _setExtraReceiverAmount(uint256 _amount, address _receiver) private {
        uintStorage[
            keccak256(abi.encode(EXTRA_RECEIVER_AMOUNT, _receiver))
        ] = _amount;
    }

    function _setMinted(uint256 _amount, address _account) private {
        bytes32 hash;

        hash = keccak256(abi.encode(MINTED_FOR_ACCOUNT_IN_BLOCK, _account, block.number));
        uintStorage[hash] = _amount;

        hash = keccak256(abi.encode(MINTED_FOR_ACCOUNT, _account));
        uintStorage[hash] = uintStorage[hash].add(_amount);

        hash = keccak256(abi.encode(MINTED_IN_BLOCK, block.number));
        uintStorage[hash] = uintStorage[hash].add(_amount);

        hash = MINTED_TOTALLY;
        uintStorage[hash] = uintStorage[hash].add(_amount);
    } */


}
