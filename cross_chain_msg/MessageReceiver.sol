// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "lib/wormhole-solidity-sdk/src/interfaces/IWormholeRelayer.sol";
import "lib/wormhole-solidity-sdk/src/interfaces/IWormholeReceiver.sol";

contract MessageReceiver is IWormholeReceiver {
    IWormholeRelayer public wormholeRelayer;
    address public registrationOwner;

    mapping(uint16 => bytes32) public registeredSenders;

    event MessageReceived(string message);
    event SourceChainLogged(uint16 sourceChain);

    constructor(address _wormholeRelayer) {
        wormholeRelayer = IWormholeRelayer(_wormholeRelayer);
        registrationOwner = msg.sender;
    }

    modifier isRegisteredSender(uint16 sourceChain, bytes32 sourceAddress) {
        require(registeredSenders[sourceChain] == sourceAddress, "Not registered sender");
        _;
    }

    function setRegisterSender(uint16 sourceChain, bytes32 sourceAddress) public {
        require(msg.sender == registrationOwner, "Not allowed to set registered sender");
        registeredSenders[sourceChain] = sourceAddress;
    }

    /// Receiving wormhole messages
    function receiveWormholeMessages(
        bytes memory payload,
        bytes[] memory,
        bytes32 sourceAddress,
        uint16 sourceChain,
        bytes32
    )
    public
    payable
    override
    isRegisteredSender(sourceChain, sourceAddress)
    {
        require(msg.sender == address(wormholeRelayer), "Only the wormhole relayer can call this function");

        string memory message = abi.decode(payload, (string));

        if (sourceChain != 0) {
            emit SourceChainLogged(sourceChain);
        }

        emit MessageReceived(message);
    }
}
