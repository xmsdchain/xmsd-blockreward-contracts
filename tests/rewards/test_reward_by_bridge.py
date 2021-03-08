import pytest
import brownie


def test_register_bridge(deployer, block_reward, bridge):
    block_reward.setBridgeAllowed([bridge], {"from":deployer})

    assert block_reward.bridgesAllowed(0) == bridge


def test_register_bridge_failed(deployer, block_reward, bridge):

    with brownie.reverts():
         block_reward.setBridgeAllowed([bridge], {"from":bridge})
