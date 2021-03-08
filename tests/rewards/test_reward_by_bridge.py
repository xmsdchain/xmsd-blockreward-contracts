import pytest
import brownie


def test_register_bridge(deployer, block_reward, bridge1, bridge2):
    block_reward.setBridgeAllowed([bridge1, bridge2], {"from":deployer})

    assert block_reward.bridgesAllowed(0) == bridge1


def test_register_bridge_failed(deployer, block_reward, bridge1, bridge2, bridge3):

    with brownie.reverts():
         block_reward.setBridgeAllowed([bridge1, bridge2], {"from":bridge3})
