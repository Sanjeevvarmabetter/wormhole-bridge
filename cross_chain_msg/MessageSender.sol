// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "lib/wormhole-solidity-sdk/src/interfaces/IWormholeRelayer.sol";

contract MessageSender {
    IWormholeRelayer public wormholeRelayer;
    uint256 constant GAS_LIMIT = 5000;

    constructor(address _wormholeRelayer) {
        wormholeRelayer = IWormholeRelayer(_wormholeRelayer);
    }

    // Calculating chain cost
    function quoteCrossChainCost(uint16 targetChain) public view returns (uint256 cost) {
        (cost,) = wormholeRelayer.quoteEVMDeliveryPrice(targetChain, GAS_LIMIT);
    }

    function sendMessage(uint16 targetChain, address targetAddress, string memory message) external payable {
        uint256 cost = quoteCrossChainCost(targetChain);

        require(msg.value >= cost, "Insufficient funds for cross-chain delivery");

        wormholeRelayer.sendPayloadToEvm{value: cost}(
            targetChain,
            targetAddress,
            abi.encode(message, msg.sender),
            0,
            GAS_LIMIT
        );
    }
}
