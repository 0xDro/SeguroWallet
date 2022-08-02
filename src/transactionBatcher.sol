// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/stargate/contracts/interfaces/ILayerZeroEndpoint.sol";

interface IDeploymentProxy{

     function deployContractAndSetUp(
            address shouldBe,
            bool shouldOrNot,
            bytes32 salt, 
            address[] memory owners, 
            uint256 threshold,
            uint16[] memory enabledChains,
            uint16 chainID,
            address lzEndpoint,
            address opsAdr,
            address _usdc,
            address _stargateRouter
        ) external returns(address);
}

contract TransactionBatcher {

    ILayerZeroEndpoint internal endpoint;
    address internal deploymentProxy;
    constructor(address _endpoint, address _proxy) {
        endpoint = ILayerZeroEndpoint(_endpoint);
        deploymentProxy = _proxy;
    }

   

    function executeCrossChainBatch(address[] memory owners, uint256 threshold, uint16[] memory dstChainID, bytes32 salt, address[] memory endpoints, address[] memory _ops, address[] memory _usdc, address[] memory _stargateRouter) external payable {
       
        address deployedAdr;
        for(uint i=0; i<dstChainID.length; i++) {

            if(i == 0){
                deployedAdr = IDeploymentProxy(deploymentProxy).deployContractAndSetUp(address(0x0), false, salt, owners, threshold, dstChainID, dstChainID[i], endpoints[i], _ops[i], _usdc[i], _stargateRouter[i]);
            }
        
            bytes memory data = abi.encode(deployedAdr, true, salt, owners, threshold, dstChainID, dstChainID[i],endpoints[i], _ops[i], _usdc[i], _stargateRouter[i]);
            bytes memory adaptParams = abi.encodePacked(uint16(1), uint256(8000000));
            (uint fee, ) = endpoint.estimateFees(dstChainID[i],deploymentProxy, data, false, adaptParams);
            require(msg.value > fee + 100000, "insufficient funds");
            endpoint.send{value: fee + 100000}(dstChainID[i], abi.encodePacked(deploymentProxy), data, payable(address(msg.sender)), address(0x0), adaptParams);

            
        }
        
        if(address(this).balance > 0){
            (bool success, ) = msg.sender.call{value: address(this).balance}("");
            require(success);   
        }
    }
}