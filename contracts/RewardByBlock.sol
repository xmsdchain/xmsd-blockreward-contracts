//SPDX-License-Identifier: AGPL 3

pragma solidity ^0.8.2;

import "../interfaces/IRewardByBlock.sol";


contract RewardByBlock is IRewardByBlock {
    address public systemAddress;
	address[] public bridgesAllowed;
	address[] public extraReceivers;
    uint256 public mintedTotally;
    uint256 public bridgeAmount;

	mapping(address => uint256) public extraReceiverAmount;
	mapping(address => uint256) public mintedForAccount;
	mapping(address => mapping(uint256 => uint256)) public mintedForAccountInBlock;
	mapping(uint256 => uint256) public mintedInBlock;
	mapping(address => uint256) public mintedTotallyByBridge;


    event AddedReceiver(uint256 amount, address indexed receiver, address indexed bridge);
    event Rewarded(address[] receivers, uint256[] rewards);

    modifier onlyBridgeContract {
        require(_isBridgeContract(msg.sender));
        _;
    }

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
	
	function addExtraReceiver(uint256 _amount, address _receiver)
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
		

        
        uint256 extraLength = extraReceiversLength();

        address[] memory receivers = new address[](extraLength.add(benefactors.length));
        uint256[] memory rewards = new uint256[](receivers.length);

        for (uint i = 0; i < benefactors.length; i++) {
			receivers[i] = benefactors[i];
            rewards[i] = 0;
		}

        uint256 i;        
        for (i = benefactors.length; i < receivers.length; i++) {
            address extraAddress = extraReceiverByIndex(i);
            uint256 extraAmount = extraReceiverAmount(extraAddress);
            _setExtraReceiverAmount(0, extraAddress);
            receivers[i] = extraAddress;
            rewards[i] = extraAmount;
        }

        for (i = 0; i < receivers.length; i++) {
            _setMinted(rewards[i], receivers[i]);
        }

        for (i = 0; i < bridgesAllowedLength; i++) {
            address bridgeAddress = bridgesAllowed[i];
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

    function setBridgeAllowed(address[] calldata _bridges) external {
        bridgeAllowed = _bridges;
    }



    function _addExtraReceiver(address _receiver) private {
        extraReceivers.push(_receiver);
    }

    function _addMintedTotallyByBridge(uint256 _amount, address _bridge) private {
        mintedTotallyByBridge = mintedTotallyByBridge+_amount;
    }

    function _clearExtraReceivers() private {
        extraReceivers.length = 0;
    }



    function _isBridgeContract(address _addr) private internal returns(bool) {
        address[bridgesAllowedLength] memory bridges = bridgesAllowed();
        
        for (uint256 i = 0; i < bridges.length; i++) {
            if (_addr == bridges[i]) {
                return true;
            }
        }

        return false;
    }

    function _setBridgeAmount(uint256 _amount, address _bridge) private {
        bridgeAmount[_bridge] = _amount;
    }

    function _setExtraReceiverAmount(uint256 _amount, address _receiver) private {
        extraReceiverAmount[_receiver] = _amount;
    }


    function _setMinted(uint256 _amount, address _account) private {
        bytes32 hash;

        mintedForAccountInBlock[_account][block.number] = _amount;
        
        mintedForAccount[_account] = _amount;

        mintedInBlock[block.number] = _amount;

        mintedTotally = mintedTotally+_amount;
   
    } 

    function bridgesAllowedLength() external view returns(uint256) {
        return bridgesAllowed.length;
    }

}
