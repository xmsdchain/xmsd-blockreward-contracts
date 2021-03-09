//SPDX-License-Identifier: AGPL 3

pragma solidity ^0.7.6;

import "../interfaces/IRewardByBlock.sol";
import "@ozUpgradesV3/contracts/access/OwnableUpgradeable.sol";
import "@ozUpgradesV3/contracts/utils/AddressUpgradeable.sol";
import "@ozUpgradesV3/contracts/math/SafeMathUpgradeable.sol";

contract RewardByBlock is IRewardByBlock,  OwnableUpgradeable {

    using AddressUpgradeable for address;
    using SafeMathUpgradeable for uint256;

    address public systemAddress;
	address[] public bridgesAllowed;
	address[] public extraReceivers;
    uint256 public mintedTotally;

	mapping(address => uint256) public extraReceiverAmount;
	mapping(address => uint256) public mintedForAccount;
	mapping(address => mapping(uint256 => uint256)) public mintedForAccountInBlock;
	mapping(uint256 => uint256) public mintedInBlock;
	mapping(address => uint256) public mintedTotallyByBridge;
    mapping(address => uint256) public bridgeAmount;


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


    function initialize(address _systemAddress) public initializer {
        __Ownable_init();
        systemAddress = _systemAddress;
    }

	function addExtraReceiver(uint256 _amount, address _receiver)
        external
        onlyBridgeContract
    {
        require(_amount != 0);
        require(_receiver != address(0));
        uint256 oldAmount = extraReceiverAmount[_receiver];
        if (oldAmount == 0) {
            _addExtraReceiver(_receiver);
        }
        _setExtraReceiverAmount(oldAmount.add(_amount), _receiver);
        _setBridgeAmount(bridgeAmount[msg.sender].add(_amount), msg.sender);
        emit AddedReceiver(_amount, _receiver, msg.sender);
    }

    function reward(address[] calldata benefactors, uint16[] calldata kind)
        external override
        onlySystem
        returns (address[] memory, uint256[] memory)
    {
        require(benefactors.length == kind.length);
        uint256 extraLength = extraReceivers.length;
        address[] memory receivers = new address[](extraLength.add(benefactors.length));
        uint256[] memory rewards = new uint256[](receivers.length);

        uint256 i;

        for (i = 0; i < benefactors.length; i++) {
			receivers[i] = benefactors[i];
            rewards[i] = 0;
		}

               
        for (i = benefactors.length; i < receivers.length; i++) {
            address extraAddress = extraReceivers[i-benefactors.length];
            uint256 extraAmount = extraReceiverAmount[extraAddress];
            _setExtraReceiverAmount(0, extraAddress);
            receivers[i] = extraAddress;
            rewards[i] = extraAmount;
        }

        for (i = 0; i < receivers.length; i++) {
            _setMinted(rewards[i], receivers[i]);
        }

        for (i = 0; i < bridgesAllowed.length; i++) {
            address bridgeAddress = bridgesAllowed[i];
            uint256 bridgeAmountForBlock = bridgeAmount[bridgeAddress];

            if (bridgeAmountForBlock > 0) {
                _setBridgeAmount(0, bridgeAddress);
                _addMintedTotallyByBridge(bridgeAmountForBlock, bridgeAddress);
            }
        }

        _clearExtraReceivers();
        
        emit Rewarded(receivers, rewards);

        return (receivers, rewards);
    }

    function extraReceiverLength() external view returns(uint256 length) {
        length = extraReceivers.length;
    }

    function setBridgeAllowed(address[] calldata _bridges) external onlyOwner {
        bridgesAllowed = _bridges;
    }

    function _addExtraReceiver(address _receiver) private {
        extraReceivers.push(_receiver);
    }

    function _addMintedTotallyByBridge(uint256 _amount, address _bridge) private {
        mintedTotallyByBridge[_bridge] = mintedTotallyByBridge[_bridge]+_amount;
    }

    function _clearExtraReceivers() private {
        delete extraReceivers;
    }

    function _isBridgeContract(address _addr) private  view returns(bool) {  
        for (uint256 i = 0; i < bridgesAllowed.length; i++) {
            if (_addr == bridgesAllowed[i]) {
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

        mintedInBlock[block.number] = mintedInBlock[block.number].add(_amount);

        mintedTotally = mintedTotally.add(_amount);
   
    } 
}
