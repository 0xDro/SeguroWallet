// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./mainWallet.sol";
import "./dependencies/ILayerZeroReceiver.sol";

contract DeploymentFactory is ILayerZeroReceiver {

    address endpoint; 

    constructor(address _endpoint){
        endpoint = _endpoint;
    }

 


    function deployContractAndSetUp( address shouldBe, bool shouldOrNot, bytes32 salt) external returns(address){
        
        bytes memory code = abi.encodePacked(type(ScWallet).creationCode);

        address proxy;
        
        assembly {
            proxy := create2(0x0, add(0x20, code), mload(code),salt )
        }
        require(address(proxy) != address(0), "adress invalid");

        if(shouldOrNot){
            require(address(proxy) == shouldBe, "address does not match should be ");
        }

        return proxy;

    }

    function computeDeploymentAddress(bytes32 salt) external view returns(address){
        bytes32 data =  keccak256(abi.encodePacked(bytes1(0xFF), address(this), salt, keccak256(type(ScWallet).creationCode)));
        return address(uint160(uint256(data)));  
    
    }

    function lzReceive(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes calldata _payload) external override {
        require(msg.sender == endpoint, "caller must be layerZero Endpoint");

        (address _shouldBe, bool _shouldOrNot, bytes32 _salt) = abi.decode(_payload, (address, bool, bytes32));

        bytes memory data = abi.encodeWithSignature("deployContractAndSetUp(address,bool,bytes32)", _shouldBe, _shouldOrNot, _salt);

        address(this).call(data);

    }


}   