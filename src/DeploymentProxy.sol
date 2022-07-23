// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Seguro.sol";
import "lib/LayerZero/contracts/interfaces/ILayerZeroReceiver.sol";


contract DeploymentFactory is ILayerZeroReceiver {

    address endpoint; 
    ScWallet internal wallet;

    constructor(address _endpoint){
        endpoint = _endpoint;
    }

 


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
        ) public returns(address){
        
        bytes memory code = abi.encodePacked(type(ScWallet).creationCode, abi.encode(enabledChains, payable(address(this))));

        address proxy;
        
        assembly {
            proxy := create2(0x0, add(0x20, code), mload(code),salt )
        }
        require(address(proxy) != address(0), "adress invalid");

        if(shouldOrNot){
            require(address(proxy) == shouldBe, "address does not match should be ");
        }

        wallet = ScWallet(payable(address(proxy)));
        wallet.setUp(owners, threshold, payable(opsAdr), _usdc, _stargateRouter, lzEndpoint, chainID);

    }

    function computeDeploymentAddress(bytes32 salt) external view returns(address){
        bytes32 data =  keccak256(abi.encodePacked(bytes1(0xFF), address(this), salt, keccak256(type(ScWallet).creationCode)));
        return address(uint160(uint256(data)));  
    
    }

    function lzReceive(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes calldata _payload) external override {
        require(msg.sender == endpoint, "caller must be layerZero Endpoint");

        
        (
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
        ) = abi.decode(_payload, (address,bool,bytes32,address[],uint256,uint16[],uint16,address,address,address,address));

        deployContractAndSetUp(shouldBe, shouldOrNot, salt, owners, threshold, enabledChains, chainID, lzEndpoint, opsAdr, _usdc, _stargateRouter);

    }


    receive() external payable {}


}   