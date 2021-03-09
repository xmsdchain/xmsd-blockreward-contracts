import pytest
import brownie


BRIDGE_TOKENS = 10000000

def test_register_bridge(deployer, block_reward, bridge1, bridge2):
    block_reward.setBridgeAllowed([bridge1, bridge2], {"from":deployer})

    assert block_reward.bridgesAllowed(0) == bridge1


def test_register_bridge_failed(deployer, block_reward, bridge1, bridge2, bridge3):

    with brownie.reverts():
         block_reward.setBridgeAllowed([bridge1, bridge2], {"from":bridge3})

def test_reward_not_system_failed(deployer, block_reward, bridge1, bridge2, bridge3):
    with brownie.reverts():
         #address is a not system
         block_reward.reward([], [], {"from":bridge3})


def test_reward_only_system(deployer, block_reward, bridge1, bridge2, bridge3, system):
    block_reward.reward([bridge1, bridge2, bridge3], [0,1,2], {"from":system})
    assert block_reward.mintedTotally() == 0


def test_add_extra_receiver_failed(deployer, block_reward, bridge1, bridge3, regular_user):
    with brownie.reverts():
        block_reward.addExtraReceiver(BRIDGE_TOKENS, regular_user, {"from": bridge3})

def test_add_extra_receiver(chain, deployer, block_reward, bridge1, regular_user, system):
    block_reward.addExtraReceiver(BRIDGE_TOKENS, regular_user, {"from": bridge1})
    
    assert block_reward.extraReceiverAmount(regular_user) == BRIDGE_TOKENS
    assert block_reward.bridgeAmount(bridge1) == BRIDGE_TOKENS
    assert block_reward.extraReceivers(0) == regular_user
    assert block_reward.extraReceiverLength() == 1

    tx = block_reward.reward([bridge1], [0], {"from":system})

    assert block_reward.mintedTotally() == BRIDGE_TOKENS
    assert block_reward.mintedInBlock(chain.height) == BRIDGE_TOKENS
    assert block_reward.mintedForAccountInBlock(regular_user, chain.height) == BRIDGE_TOKENS
    assert block_reward.mintedTotallyByBridge(bridge1) == BRIDGE_TOKENS
    assert block_reward.extraReceiverAmount(regular_user) == 0
    assert block_reward.bridgeAmount(bridge1) == 0
    assert block_reward.extraReceiverLength() == 0



def test_add_extra_receivers(chain, deployer, block_reward, bridge1, bridge2, regular_user1, regular_user2, system):
    block_reward.addExtraReceiver(BRIDGE_TOKENS, regular_user1, {"from": bridge2})
    block_reward.addExtraReceiver(BRIDGE_TOKENS, regular_user2, {"from": bridge2})
    
    assert block_reward.extraReceiverAmount(regular_user1) == BRIDGE_TOKENS
    assert block_reward.bridgeAmount(bridge2) == 2*BRIDGE_TOKENS
    assert block_reward.extraReceivers(0) == regular_user1

    assert block_reward.extraReceiverAmount(regular_user2) == BRIDGE_TOKENS
    assert block_reward.extraReceivers(1) == regular_user2

    assert block_reward.extraReceiverLength() == 2

    tx = block_reward.reward([bridge1, bridge2], [0, 1], {"from":system})

    assert block_reward.mintedTotally() == 3*BRIDGE_TOKENS
    assert block_reward.mintedInBlock(chain.height) == 2*BRIDGE_TOKENS

    assert block_reward.mintedForAccountInBlock(regular_user1, chain.height) == BRIDGE_TOKENS
    assert block_reward.mintedForAccountInBlock(regular_user2, chain.height) == BRIDGE_TOKENS

    assert block_reward.mintedTotallyByBridge(bridge2) == 2*BRIDGE_TOKENS
    assert block_reward.extraReceiverAmount(regular_user1) == 0
    assert block_reward.extraReceiverAmount(regular_user2) == 0

    assert block_reward.bridgeAmount(bridge2) == 0
    assert block_reward.extraReceiverLength() == 0




