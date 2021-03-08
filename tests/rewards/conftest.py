import pytest
from brownie import accounts
import sys

from utils.deploy_helpers import deploy_proxy, deploy_admin


@pytest.fixture(scope="module")
def deployer():
    yield accounts[0]

@pytest.fixture(scope="module")
def bridge():
    yield accounts[1]

@pytest.fixture(scope="module")
def system():
    yield accounts[2]

@pytest.fixture(scope="module")
def proxy_admin(deployer):
    proxy_admin = deploy_admin(deployer)
    yield proxy_admin

@pytest.fixture(scope="module")
def block_reward(deployer, proxy_admin, system, RewardByBlock):
    blockRewardImplFromProxy, blockRewardProxy, blockRewardImpl = deploy_proxy(deployer, proxy_admin, RewardByBlock, system)

    assert blockRewardProxy.admin.call({"from":proxy_admin.address}) == proxy_admin.address
    assert blockRewardProxy.implementation.call({"from":proxy_admin.address}) == blockRewardImpl.address

    assert blockRewardImplFromProxy.systemAddress() == system
    yield blockRewardImplFromProxy

    
