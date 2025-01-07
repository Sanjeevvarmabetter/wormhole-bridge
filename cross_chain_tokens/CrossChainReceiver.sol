// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "lib/wormhole-solidity-sdk/src/WormholeRelayerSDK.sol";
import "lib/wormhole-solidity-sdk/src/interfaces/IERC20.sol";

contract CrossChainReceiver is TokenReceiver {

    constructor(
        address _wormholeRelayer,
        address _tokenBridge,
        address _wormhole
    ) TokenBase(_wormholeRelayer, _tokenBridge, _wormhole) {}

    function receivePayloadAndTokens(
        bytes memory payload,
        TokenReceived[] memory receivedTokens,
        bytes32 sourceAddress,
        uint16 sourceChain,
        bytes32 
    )
        internal
        override
        onlyWormholeRelayer
        isRegisteredSender(sourceChain, sourceAddress)
    {
        require(receivedTokens.length == 1, "Expected 1 token transfer");

        address recipient = abi.decode(payload, (address));

        // Transfer the received tokens to the intended recipient
        IERC20(receivedTokens[0].tokenAddress).transfer(
            recipient,
            receivedTokens[0].amount
        );
    }
}